class_name Words
extends Node

static func load_words(filename:String):
	var bytes = FileAccess.get_file_as_bytes(filename)
	var pos:int = 0
	var letteroffsets = []
	var wordgroups = {}
	var wordstr = ""
	var prevword = ""
	
	if bytes.is_empty():
		push_error("Error reading word file: " + filename)
		return null
	
	print("Loaded word file: ",filename,", size: ", bytes.size()," bytes" )
	
	# read letter offsets (2 bytes per letter, a-z)
	for i in range(0,26):
		letteroffsets.append( int( bytes[pos] << 8) | bytes[pos+1])
		pos += 2
	
	# jump to 'a' offset
	pos = letteroffsets[0]
	
	# read till position reaches EOF
	while pos+1 < bytes.size():
		
		# how many characters to use from prev word?
		var chars_from_prev = bytes[pos]
		
		# copy n chars from previous word
		if chars_from_prev:
			wordstr = prevword.left(chars_from_prev)
		# if 0, clear the word
		else:
			wordstr = ""
		
		pos += 1
		
		# read word
		while pos < bytes.size():
			var extended_byte = 0
			
			# if extended character marker
			if bytes[pos] == 0:
				# get next byte
				pos += 1
				extended_byte = 128
			
			# if bit7 is clear, invert the bits to get the ascii code
			if bytes[pos] < 0x80:
				wordstr += char(bytes[pos] ^ 0x7f + extended_byte)
			# otherwise, bit 7 flag is high, terminates word
			else:
				break
			# next byte
			pos += 1
		
		# finish reading word
		wordstr += char(bytes[pos] ^ 0xff)
		
		# get the group id
		pos += 1
		var groupid:int = (bytes[pos] << 8) | (bytes[pos+1])
		
		# add word to word group
		if !wordgroups.has(groupid):
			wordgroups[groupid] = []
		wordgroups[groupid].append(wordstr)
		
		# copy to previous word
		prevword = wordstr
		#print(wordstr)
		
		# next word
		pos += 2
		
		
	#print(wordgroups)
	#print(wordgroups.keys())
	print("Successfully loaded word file from ", filename)
	return wordgroups
