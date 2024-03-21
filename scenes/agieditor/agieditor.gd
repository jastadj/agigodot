extends Node2D

@onready var view_viewer = $CanvasLayer/ui/Tools/view_viewer
@onready var picture_viewer = $CanvasLayer/ui/Tools/picture_viewer
@onready var logic_viewer = $CanvasLayer/ui/Tools/logic_viewer

func _ready():
	
	# adjust window size (temporarily for testing)
	get_window().size = Vector2i(1500, 1000)
	
	_hide_tools()
	
	# testing
	_on_file_dialog_game_dir_dir_selected("res://testdata/pq1")

func _on_button_load_game_dir_pressed():
	$CanvasLayer/ui/FileDialogGameDir.popup_centered()

func _on_file_dialog_game_dir_dir_selected(dir):
	System.agi.load_game_dir(dir)
	view_viewer._update_view_list()

func _hide_tools():
	for tool in $CanvasLayer/ui/Tools.get_children():
		tool.hide()

func _on_button_view_pressed():
	_hide_tools()
	view_viewer.show()

func _on_button_picture_pressed():
	_hide_tools()
	picture_viewer.show()

func _on_button_logic_pressed():
	_hide_tools()
	logic_viewer.show()
