class_name Directory
extends Node

const VOLUME_HEADER_SIZE = 5

enum DIR_TYPE{LOGDIR, PICDIR, VIEWDIR, SNDDIR}

static func load_directory(filename:String, _version:float):
	
	var bytes = FileAccess.get_file_as_bytes(filename)
	var pos = 0
	var offsetcount = 0
	var dir = []
	var _ifile = FileAccess.open(filename, FileAccess.READ)
	
	if bytes.is_empty():
		printerr("Error opening dir file:", filename)
		return null
	
	while pos < bytes.size():
		var vol:int = (bytes[pos] & 0xf0) >> 4
		var offset:int = ( (bytes[pos] & 0x0f) << 16) | (bytes[pos+1] << 8) | (bytes[pos+2])
		# add the volume header size to the offset (5 bytes)
		offset += VOLUME_HEADER_SIZE
		# [v]ol num, [o]ffset pos, [i]nvalid entry
		dir.append({"v":vol, "o":offset}) 
		# if all 3 entry bytes = 0xff, resource does not exist
		dir.back()["i"] = (bytes[pos] == 0xff and bytes[pos+1] == 0xff and bytes[pos+2] == 0xff)
		offsetcount += 1
		pos += 3
	
	print("Loaded directory file ", filename, ", entries=", offsetcount)
	
	return dir

static func is_entry_valid(d_entry:Dictionary):
	
	# if entry doesn't contain the invalid flag, return false
	if !d_entry.has("i") or !d_entry.has("o") or !d_entry.has("v"):
		printerr("Directory entry missing dict keys!")
		return false
	
	# if entry is invalid, return false
	if d_entry["i"]:
		return false
		
	# ok
	return true
