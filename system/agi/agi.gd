class_name AGI
extends Node

var wordgroups

var volumes = []
var color = []

var logdir
var viewdir
var picdir
var snddir

const AGI_WIDTH = 320
const AGI_HEIGHT = 200

var views = {}

func _ready():
	
	# init color palette
	print("Initializing color palette.")
	_init_colors()
	
	# open volumes
	load_volume("res://testdata/pq1/VOL.0")
	load_volume("res://testdata/pq1/VOL.1")
	load_volume("res://testdata/pq1/VOL.2")
	
	# load words
	wordgroups = Words.load_words("res://testdata/pq1/WORDS.TOK")
	
	# load directory files
	viewdir = Directory.load_directory("res://testdata/pq1/VIEWDIR", Directory.DIR_TYPE.VIEWDIR, 2.0)
		
	# load resources
	views = View.load_views(viewdir)	

func _init_colors():
	color.append(Color.hex(0x000000FF)) # 0 - black
	color.append(Color.hex(0x0000AAFF)) # 1 - blue
	color.append(Color.hex(0x00AA00FF)) # 2 - green
	color.append(Color.hex(0x00AAAAFF)) # 3 - cyan
	color.append(Color.hex(0xAA0000FF)) # 4 - red
	color.append(Color.hex(0xAA00AAFF)) # 5 - magenta
	color.append(Color.hex(0xAA5500FF)) # 6 - brown
	color.append(Color.hex(0xAAAAAAFF)) # 7 - light gray
	color.append(Color.hex(0x555555FF)) # 8 - gray
	color.append(Color.hex(0x5555FFFF)) # 9 - light blue
	color.append(Color.hex(0x55FF55FF)) #10 - light green
	color.append(Color.hex(0x55FFFFFF)) #11 - light cyan
	color.append(Color.hex(0xFF5555FF)) #12 - light red
	color.append(Color.hex(0xFF55FFFF)) #13 - light magenta
	color.append(Color.hex(0xFFFF55FF)) #14 - yellow
	color.append(Color.hex(0xFFFFFFFF)) #15 - white

func load_volume(filename:String):
	
	var ifile = FileAccess.open(filename, FileAccess.READ)
	
	if !ifile or !ifile.is_open():
		printerr("Error loading volume ", filename)
		return
	
	print("Loaded volume ", filename)
	volumes.append(ifile)
