class_name View
extends Node

const VIEW_HEADER_SIZE = 7
const LOOP_HEADER_SIZE = 3
const CEL_HEADER_SIZE = 3

static func load_views(viewdir):
	
	var views = []
	
	# load the the view from each view entry
	for res_entry in viewdir:
		
		################
		# RESOURCE ENTRY
		
		# get resource entry offset
		var pos = res_entry["o"]
		
		# check resource validity
		var invalid_resource = res_entry["i"]
		# if entry is invalid, skip
		if invalid_resource:
			views.append(null)
			continue
		else:
			views.append({"offset":pos,"loops":[], "sequences":[]})
		
		# get volume
		var vol = System.agi.volumes[res_entry["v"]]
		
		# seek to view entry offset in volume
		vol.seek(pos)

		######
		# VIEW
		
		# view header (7-bytes)
		var _unkbyte1:int = vol.get_8() # always 1 or 2
		var _unkbyte2:int = vol.get_8() # always 1
		var loopcount:int = vol.get_8()
		var _desc_offset:int = vol.get_8() | (vol.get_8() << 8) # lsms, offset of view description (text description of item)
		var loop_offsets = []
		var _loops = []
		
		# offsets of each loop (relative to view data pos)
		for l in range(0, loopcount):
			# convert to absolute offset
			loop_offsets.append( int((vol.get_8() | (vol.get_8() << 8))) + pos)#lsms
		
		######
		# LOOP
		for loopoffset in loop_offsets:
			
			# seek to loop offset
			vol.seek(loopoffset)
			
			# get loop header		
			var cel_count:int = vol.get_8()
			# get relative offsets for each cel
			var cel_rel_offsets = []
			for celoffset in range(0, cel_count):
				cel_rel_offsets.append( (vol.get_8() | (vol.get_8() << 8)) + loopoffset)
			
			var loop = {"o":loopoffset, "cels":[]}
			
			#####
			# CEL
			# for each cel, get cel header
			for cel_offset in cel_rel_offsets:
				
				vol.seek(cel_offset)
				
				var width:int = vol.get_8()
				var height:int = vol.get_8()
				var transparency_and_mirror:int = vol.get_8()
				var transparency:int = transparency_and_mirror & 0x0f
				var mirroring:int = (transparency_and_mirror & 0xf0) >> 4
				
				var cel = {"w":width, "h":height, "t":transparency, "m":mirroring, "d":[]}
				
				# read cel data
				# each byte = line chunk : ms nib = color, ls nib = pixel run length, 0x00 = EOL
				# if last line chunk is transparent color, no need to store that byte
				for y in range(0, height):
					while 1:
						var byte:int = vol.get_8()
						cel["d"].append(byte)
						if byte == 0x00:
							break
				
				loop["cels"].append(cel)
			
			views.back()["loops"].append(loop)	
	
	return views

static func cel_data_to_pixels(cel:Dictionary, transparency:bool = true):
	var pixeldata = PackedByteArray()
	
	#print("offset: 0x%x" % curview["offset"], " loops:", curview["loops"].size())
	#print("loop:", loop_list.selected, ", cel:", cel_list.selected, ", w:", curcel["w"], ", h:", curcel["h"], ", t:", curcel["t"] )
	
	var transparent_color = System.agi.color[cel["t"]]
	if transparency:
		transparent_color.a = 0
	
	var cur_x = 0
	var _line_counter = 0
	for d in cel["d"]:
		if d != 0:
			var runlen = d & 0x0f
			
			# pixel color
			var color_index = (d & 0xf0) >> 4
			var color
			if color_index == cel["t"]:
				color = transparent_color
			else:
				color = System.agi.color[color_index]
			
			cur_x += runlen
			for run in range(0, runlen):
				pixeldata.append(color.r8)
				pixeldata.append(color.g8)
				pixeldata.append(color.b8)
				pixeldata.append(color.a8)
		if d == 0:
			var color = transparent_color
			for run in range(0, cel["w"] - cur_x):
				pixeldata.append(color.r8)
				pixeldata.append(color.g8)
				pixeldata.append(color.b8)
				pixeldata.append(color.a8)
			cur_x = 0
			_line_counter += 1
		
	return pixeldata
