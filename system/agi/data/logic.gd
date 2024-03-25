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
	var text_offset:int = (vol.get_8() | (vol.get_8() << 8)) + 7
	var script_data = PackedByteArray()

	pos += 2

	while pos < text_offset:
		script_data.append(vol.get_8())
		pos += 1

	print("logic data size:", script_data.size(), " bytes")
	
	# Logic Strings
	var encrypt_len = AGI.AGI_ENCRYPTION_STRING.length()
	var logic_strings = []
	var logic_string_offsets = []
	var logic_strings_count:int = vol.get_8()
	pos += 1
	var logic_strings_end_ptr:int = (vol.get_8() | (vol.get_8() << 8)) + pos
	
	# collect the offsets
	for i in range(0, logic_strings_count):
		logic_string_offsets.append( (vol.get_8() | (vol.get_8() << 8)) + pos) 
	
	# read logic strings
	vol.seek(logic_string_offsets[0])
	var logicstring:String
	for offset in range(logic_string_offsets[0], logic_strings_end_ptr):
		var index = offset - logic_string_offsets[0]
		var schar:int = vol.get_8() ^ (AGI.AGI_ENCRYPTION_STRING[index % encrypt_len].to_ascii_buffer()[0])
		logicstring += char(schar)
		if schar == 0:
			logic_strings.append(logicstring)
			logicstring = String()
	
	for lstring in logic_strings:
		print(lstring)
	print("stored string count = ", logic_strings.size(), ", expected string count = ", logic_strings_count)
