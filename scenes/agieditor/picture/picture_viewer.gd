extends Control

@onready var picture_list = $PanelContainer/VBoxContainer/HBoxContainer/OptionButtonPictures
var picture = null

func _ready():
	
	connect("visibility_changed", _on_visibility_changed)
	
func _on_visibility_changed():
	if visible:
		_update_picture_list()
		
func _update_picture_list():
	picture_list.clear()
	
	for i in range(0, System.agi.picdir.size()):
		picture_list.add_item(str(i))
	
	if picture_list.item_count == 0:
		_select_picture(-1)
	else:
		_select_picture(0)

func _select_picture(index):
	
	picture = Picture.load_picture(index)
	picture_list.select(index)

func _on_option_button_pictures_item_selected(index):
	_select_picture(index)
