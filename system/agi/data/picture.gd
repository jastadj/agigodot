class_name Picture
extends Node

const PICTURE_BG_COLOR = 15
const PRIORITY_BG_COLOR = 4

var _pos:int = 0
var _data:PackedByteArray

var _img_picture:Image = null
var _img_priority:Image = null

var _draw_picture_enabled:bool = false
var _draw_priority_enabled:bool = false

var _picture_color:Color = System.agi.colors[0]
var _priority_color:Color = System.agi.colors[0]

var _draw_pos:Vector2i = Vector2i(0,0)

enum DRAW_CMD{
	
	# enable/disable modes/colors
	DRAW_COLOR = 0xf0			, # change color and enable draw
	DISABLE_DRAW = 0xf1			, # disable picture draw
	PRIORITY_DRAW_COLOR = 0xf2	, # change priority color and enable priorty draw
	DISABLE_PRIORITY_DRAW = 0xf3, # disable priority draw
	
	# draw functions
	DRAW_Y_CORNER = 0xf4		,
	DRAW_X_CORNER = 0xf5		,
	DRAW_LINE_ABSOLUTE = 0xf6	, # long lines
	DRAW_LINE_RELATIVE = 0xf7	, # short lines
	DRAW_FILL = 0xf8			,
	
	PEN_SIZE_STYLE = 0xf9		, # change pen size and style
	PEN_PLOT = 0xfa				,
	
	# ... xFB - 0xF				  # unused in most games
}

enum PEN_STYLE { SOLID, SPLATTER}
enum PEN_SHAPE {CIRCLE, RECTANGLE}

var _pen_size:int = 0
var _pen_style:PEN_STYLE = PEN_STYLE.SOLID
var _pen_shape:PEN_SHAPE = PEN_SHAPE.RECTANGLE

static func load_picture(picdir_index):
	
	# picture dictionary description
	# TBD
	
	# is index valid?
	if picdir_index >= System.agi.picdir.size():
		return null
	
	# get directory entry
	var d_entry = System.agi.picdir[picdir_index]
	
	# is entry valid?
	if !Directory.is_entry_valid(d_entry):
		return null
	
	###########
	# DIR ENTRY
	
	var picture = PackedByteArray()
	
	# get offset
	var pos = d_entry["o"]
		
	# get volume
	var vol = System.agi.volumes[d_entry["v"]]
	
	# seek to view entry offset in volume
	vol.seek(pos)
	
	# read picture commands from data until 0xff reached (end of picture)
	while !vol.eof_reached():
		
		var byte:int = vol.get_8()
		
		if byte == 0xff:
			break
		
		# add bytes to picture buffer
		picture.append(byte)
	
	# picture done
	print("Loaded picture %d " % picdir_index, "with %d bytes" % picture.size())
	return picture

func _is_next_eof():
	return (_pos + 1 >= _data.size())

func _is_next_cmd():
	if _is_next_eof():
		return false
	return (_data[_pos+1] >= 0xf0)

func _get_next():
	if _is_next_eof():
		return null
	_pos += 1
	return int(_data[_pos])
		

func get_images_from_picture(picture:PackedByteArray):

	# init variables
	_pos = -1
	_data = picture
	_picture_color = System.agi.colors[0]
	_priority_color = System.agi.colors[0]
	_draw_picture_enabled = false
	_draw_priority_enabled = false
	_draw_pos = Vector2i(0,0)
	
	# init images
	_img_picture = Image.create(AGI.AGI_WIDTH/2, AGI.AGI_HEIGHT, false, Image.FORMAT_RGBA8)
	_img_priority = Image.create(AGI.AGI_WIDTH/2, AGI.AGI_HEIGHT, false, Image.FORMAT_RGBA8)
	_img_picture.fill(System.agi.colors[PICTURE_BG_COLOR])
	_img_priority.fill(System.agi.colors[PRIORITY_BG_COLOR])
	
	# run picture draw commands
	while _pos < _data.size():
		
		# advance position for next command
		if _is_next_eof():
			break
		_get_next()
		
		var cmd:int = _data[_pos] # command byte
		
		# DRAW ENABLE/DISABLE
		if cmd == DRAW_CMD.DRAW_COLOR:
			_draw_picture_enabled = true
			_picture_color = System.agi.colors[_get_next()]
		elif cmd == DRAW_CMD.DISABLE_DRAW:
			_draw_picture_enabled = false
		elif cmd == DRAW_CMD.PRIORITY_DRAW_COLOR:
			_draw_priority_enabled = true
			_priority_color = System.agi.colors[_get_next()]
		elif cmd == DRAW_CMD.DISABLE_PRIORITY_DRAW:
			_draw_priority_enabled = false
		
		# DRAW CORNERS (TURTLE STYLE)
		elif cmd == DRAW_CMD.DRAW_Y_CORNER or cmd == DRAW_CMD.DRAW_X_CORNER:
			var draw_y:bool = cmd == DRAW_CMD.DRAW_Y_CORNER # start with y or x dir?
			_draw_pos = Vector2i(_get_next(), _get_next())
			
			# draw lines in alternating axis until a new draw cmd is found (>= 0xf0)
			while 1:
				
				# if eof or next cmd
				if _is_next_eof() or _is_next_cmd():
					break
				
				if draw_y:
					_draw_line(_draw_pos, Vector2(_draw_pos.x, _get_next()))
					draw_y = false
				else:
					_draw_line(_draw_pos, Vector2(_get_next(), _draw_pos.y))
					draw_y = true
		
		# DRAW ABSOLUTE LINES (x1,y1,x2,y2)
		elif cmd == DRAW_CMD.DRAW_LINE_ABSOLUTE:
			var draw_lines:bool = true
			_draw_pos = Vector2i(_get_next(), _get_next())
			
			while 1:
				
				# end of data or end of cmd?
				if _is_next_eof() or _is_next_cmd():
					break
				
				# draw line to next two bytes (x,y)
				var pos2 = Vector2i(_get_next(), _get_next())
				_draw_line(_draw_pos, pos2)
		
		# draw relative commands (offset from starting position, coords have -7 to 7 range)
		elif cmd == DRAW_CMD.DRAW_LINE_RELATIVE:
			var draw_lines:bool = true
			_draw_pos = Vector2i(_get_next(), _get_next())
			
			while 1:
				
				# end of data or end of cmd?
				if _is_next_eof() or _is_next_cmd():
					break
				
				# get relative line byte info (rel offsets are -7 to 7)
				var byte:int = _get_next()
				var rel_x:int = (byte & 0x70) >> 4
				var rel_y:int = byte & 0x7
				
				# apply sign bit
				if byte & 0x80:
					rel_x = -rel_x
				if byte & 0x08:
					rel_y = -rel_y
				
				
		# FLOOD FILL
		elif cmd == DRAW_CMD.DRAW_FILL:
			pass
		
		
		# PEN SIZE/STYLE
		elif cmd == DRAW_CMD.PEN_SIZE_STYLE:
			var byte:int = _get_next()
			
			# configure pen
			_pen_style = (byte & 0x20) >> 5
			_pen_shape = (byte & 0x10) >> 4
			_pen_size = byte & 0x7
		
		# PEN PLOT
		elif cmd == DRAW_CMD.PEN_PLOT:
			
			var draw_pen: = true
			
			while 1:
				
				# end of data or end of cmd?
				if _is_next_eof() or _is_next_cmd():
					break
				
				# solid pen style has 2 args (x/y)
				if _pen_style == PEN_STYLE.SOLID:
					_draw_pos = Vector2i(_get_next(), _get_next())
					_draw_pen(_draw_pos)
					
				# splatter style has 3 args(x/y/texture)
				else:
					var texturenum = _get_next()
					_draw_pos = Vector2i(_get_next(), _get_next())
					_draw_pen(_draw_pos, texturenum)
			
		else:
			#printerr("Picture unrecognized draw cmd: 0x%x" % cmd)
			pass
		
	
	return [_img_picture, _img_priority]

# draws a pixel at current draw_pos & current color
# applied to both priority and picture images (if enabled)
func _draw_pixel(pos:Vector2i):
	
	if _draw_picture_enabled:
		_img_picture.set_pixel(pos.x, pos.y, _picture_color)
	
	if _draw_priority_enabled:
		_img_priority.set_pixel(pos.x, pos.y, _priority_color)
		
	# set the current draw position here
	_draw_pos = pos

func _round(aNumber:float, dirn:float):
	if dirn < 0:
		if aNumber - floor(aNumber) <= 0.501:
			return floor(aNumber)
		else:
			return ceil(aNumber)
	# else
	elif aNumber - floor(aNumber) < 0.499:
		return floor(aNumber)
	# otherwise
	return ceil(aNumber)

# draw a line from p1 to p2
func _draw_line(p1:Vector2i, p2:Vector2i):
	
	var height:int = p2.y - p1.y
	var width:int = p2.x - p1.x
	var x:float
	var y:float
	var addX:float = float(height)
	var addY:float = float(width)
	
	if height != 0:
		addX = float(width) / float(abs(height))
	
	if width != 0:
		addY = float(height) / float(abs(width))
		
	if abs(width) > abs(height):
		y = p1.y
		if width == 0:
			addX = 0
		else:
			addX = float(width) / float(abs(width))
		x = p1.x
		while x != p2.x:
			_draw_pixel(Vector2i(_round(x, addX), _round(y, addY)))
			x += addX
		_draw_pixel(Vector2i(p2.x, p2.y))
	else:
		x = p1.x
		if height == 0:
			addY = 0
		else:
			addY = float(height) / float(abs(height))
		y = p1.y
		while y != p2.y:
			_draw_pixel(Vector2i(_round(x, addX), _round(y,addY)))
			y += addY
		_draw_pixel(Vector2i(p2.x, p2.y))

func _draw_pen(pos:Vector2i, texture_id:int = -1):
	
	_draw_pixel(pos)
