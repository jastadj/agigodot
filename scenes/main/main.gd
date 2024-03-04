extends Node2D

func _ready():
	
	# wordgroups
	if System.wordgroups:
		var keys = System.wordgroups.keys()
		keys.sort()
		
		var treeroot = $CanvasLayer/ui/wordgrouptree.create_item()
		
		for key in keys:
			var keyitem = $CanvasLayer/ui/wordgrouptree.create_item(treeroot)
			keyitem.set_text(0, str(key))
			for word in System.wordgroups[key]:
				var worditem = $CanvasLayer/ui/wordgrouptree.create_item(keyitem)
				worditem.set_text(0, word)
			keyitem.set_collapsed_recursive(true)
		
