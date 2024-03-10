extends Node2D

@onready var view_viewer = $CanvasLayer/ui/ViewViewer

func _ready():
	
	# testing
	_on_file_dialog_game_dir_dir_selected("res://testdata/pq1")

func _on_button_load_game_dir_pressed():
	$CanvasLayer/ui/FileDialogGameDir.popup_centered()

func _on_file_dialog_game_dir_dir_selected(dir):
	System.agi.load_game_dir(dir)
	view_viewer._update_view_list()

