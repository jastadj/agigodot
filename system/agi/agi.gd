class_name AGI
extends Node

const AGI_WIDTH = 320
const AGI_HEIGHT = 200

var colors = []

# resources
var volumes = []
var logdir
var viewdir
var picdir
var snddir
var views = []
var pictures = []
var wordgroups



func _ready():
	
	# init color palette
	print("Initializing color palette.")
	_init_colors()

func _init_colors():
	colors.append(Color.hex(0x000000FF)) # 0 - black
	colors.append(Color.hex(0x0000AAFF)) # 1 - blue
	colors.append(Color.hex(0x00AA00FF)) # 2 - green
	colors.append(Color.hex(0x00AAAAFF)) # 3 - cyan
	colors.append(Color.hex(0xAA0000FF)) # 4 - red
	colors.append(Color.hex(0xAA00AAFF)) # 5 - magenta
	colors.append(Color.hex(0xAA5500FF)) # 6 - brown
	colors.append(Color.hex(0xAAAAAAFF)) # 7 - light gray
	colors.append(Color.hex(0x555555FF)) # 8 - gray
	colors.append(Color.hex(0x5555FFFF)) # 9 - light blue
	colors.append(Color.hex(0x55FF55FF)) #10 - light green
	colors.append(Color.hex(0x55FFFFFF)) #11 - light cyan
	colors.append(Color.hex(0xFF5555FF)) #12 - light red
	colors.append(Color.hex(0xFF55FFFF)) #13 - light magenta
	colors.append(Color.hex(0xFFFF55FF)) #14 - yellow
	colors.append(Color.hex(0xFFFFFFFF)) #15 - white

func _load_volume(filename:String):
	
	var ifile = FileAccess.open(filename, FileAccess.READ)
	
	if !ifile or !ifile.is_open():
		printerr("Error loading volume ", filename)
		return
	
	print("Loaded volume ", filename)
	volumes.append(ifile)

func load_game_dir(_gamedir:String):
	
	# open directory
	var gamedir = DirAccess.open(_gamedir)
	if(!gamedir):
		printerr("Unable to open game directory:", _gamedir)
		return false
	var gamedirfiles = gamedir.get_files()

	#######
	# WORDS
	var wordsfilename = _gamedir + "/WORDS.TOK"
	wordgroups = Words.load_words(wordsfilename)
	
	#########
	# VOLUMES
	print(gamedirfiles)
	volumes = []
	var volumefiles = []
	for gfile in gamedirfiles:
		if gfile.contains("VOL."):
			volumefiles.append(_gamedir + "/" + gfile)
	volumefiles.sort()
	for vfile in volumefiles:
		_load_volume(vfile)
	
	#############
	# DIRECTORIES
	
	# viewdir
	var viewdirfilename = _gamedir + "/VIEWDIR"
	viewdir = Directory.load_directory(viewdirfilename, 2.0)
	views = View.load_views(viewdir)	
	
	# picdir
	var picdirfilename = _gamedir + "/PICDIR"
	picdir = Directory.load_directory(picdirfilename, 2.0)
	pictures = Picture.load_pictures(picdir)
	
