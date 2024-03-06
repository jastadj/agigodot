class_name View
extends Node

static func load_views(viewdir):
		
	var entry_counter = 0
		
	for view_entry in viewdir:
		
		#print("view entry ", entry_counter, ", offset:", view_entry["o"], ", vol:", view_entry["v"], ", invalid:", view_entry["i"])
		
		
		# if entry is invalid, skip
		if view_entry["i"]:
			continue
		
		# get the view header
		var pos = view_entry["o"] + 5 # 5 bytes of volume header
		var vol = System.volumes[view_entry["v"]]
		vol.seek(pos+2)
		
		# view header (7-bytes)
		var loopcount:int = vol.get_8()
		var desc_offset:int = vol.get_8() | (vol.get_8() << 8) # lsms
		var loop_offsets = []
		var loops = []
		
		# offsets of each loop
		for l in range(0, loopcount):
			loop_offsets.append( (vol.get_8() | (vol.get_8() << 8)) + #lsms
		
		# for each loop offset, get loop header
		for loopoffset in loop_offsets:
			
			var loop_pos = vol.get_position()
			
			# move to offset and get cel count
			vol.seek(loopoffset)
			var cel_count:int = vol.get_8()
			
			# get relative offsets for each cel
			var cel_rel_offsets = []
			for celoffset in range(0, cel_count):
				cel_rel_offsets.append( vol.get_8() | (vol.get_8() << 8))
			
			# for each cel, get cel header
			for cel_offset in cel_rel_offsets:
				
				vol.seek(loopoffset + cel_offset)
				
				var width:int = vol.get_8()
				var height:int = vol.get_8()
				var transparency_and_mirror:int = vol.get_8()
		
		# increment entry counter (for diagnostics)
		entry_counter += 1
