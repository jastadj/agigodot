class_name Logic
extends Node

static func load_logic(logdir_index):
	# logic dictionary description
	# TBD
	
	# is index valid?
	if logdir_index >= System.agi.logdir.size():
		return null
	
	# get directory entry
	var d_entry = System.agi.logdir[logdir_index]
	
	# is entry valid?
	if !Directory.is_entry_valid(d_entry):
		return null
	
	###########
	# DIR ENTRY
	
	# get offset
	var pos:int = d_entry["o"]
		
	# get volume
	var vol:FileAccess = System.agi.volumes[d_entry["v"]]
	
	# seek to view entry offset in volume
	vol.seek(pos)
	
	# Logic Header
	var text_offset:int = (vol.get_8() & (vol.get_8() << 8)) + 5
	var script_data = PackedByteArray()
	
	print("logic text offset:", text_offset, ", pos:", pos)
	
	# read script data (until start of text offset)
	while pos < text_offset:
		print(pos)
		script_data.append(vol.get_8())
		pos += 1
	
	print("Loaded ", script_data.size(), " bytes for logic ", logdir_index)
