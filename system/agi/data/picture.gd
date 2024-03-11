class_name Picture
extends Node

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
	
	var picture = []
	
	# get offset
	var pos = d_entry["o"]
		
	# get volume
	var vol = System.agi.volumes[d_entry["v"]]
	
	# seek to view entry offset in volume
	vol.seek(pos)
	
	# read picture commands from data until 0xff reached (end of picture)
	while !vol.eof_reached():
		
		# get draw command
		var cmd = vol.get_8()
		
		if cmd == DRAW_CMD.DRAW_COLOR:
			picture.append(cmd)
			picture.append(vol.get_8())
			break
		elif cmd == 0xff:
			break
		else:
			printerr("Unhandled draw command 0x%x" % cmd)
			continue
	
	# picture done
	print("Picture loaded with %d commands" % picture.size())
	return picture
