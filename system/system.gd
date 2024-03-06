extends Node

var wordgroups

var volumes = []

var logdir
var viewdir
var picdir
var snddir

var views = {}

func _ready():
	
	# open volumes
	load_volume("res://pqdata/VOL.0")
	load_volume("res://pqdata/VOL.1")
	load_volume("res://pqdata/VOL.2")
	
	# load words
	wordgroups = Words.load_words("res://pqdata/WORDS.TOK")
	
	# load directory files
	viewdir = Directory.load_directory("res://pqdata/VIEWDIR", Directory.DIR_TYPE.VIEWDIR, 2.0)
		
	# load resources
	views = View.load_views(viewdir)

func load_volume(filename:String):
	
	var ifile = FileAccess.open(filename, FileAccess.READ)
	
	if !ifile or !ifile.is_open():
		printerr("Error loading volume ", filename)
		return
	
	print("Loaded volume ", filename)
	volumes.append(ifile)
