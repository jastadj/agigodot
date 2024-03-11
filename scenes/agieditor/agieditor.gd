extends Node2D

@onready var view_viewer = $CanvasLayer/ui/Tools/ViewViewer

func _ready():
	
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
	$CanvasLayer/ui/Tools/ViewViewer.show()

func _on_button_picture_pressed():
	_hide_tools()
	$CanvasLayer/ui/Tools/PictureViewer.show()
