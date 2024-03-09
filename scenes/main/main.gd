extends Node2D

func _ready():
	pass
	
func _on_button_agi_editor_pressed():
	get_tree().change_scene_to_file("res://scenes/agieditor/agieditor.tscn")
