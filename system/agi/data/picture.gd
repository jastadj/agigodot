class_name Picture
extends Node


static func load_pictures(viewdir):
	
	var pictures = []
	
	for dentry in viewdir:
		print("v:", dentry["v"], ", offset: 0x%x" % dentry["o"])
	
	return pictures
