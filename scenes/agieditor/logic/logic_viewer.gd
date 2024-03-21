extends Control

@onready var logic_list = $PanelContainer/VBoxContainer/HBoxContainer/OptionButtonLogicList

var logic = null

func _ready():
	connect("visibility_changed", _on_visibility_changed)
	
func _on_visibility_changed():
	if visible:
		_update_logic_list()
		if logic_list.item_count > 0:
			_select_logic(0)
		
func _update_logic_list():
	logic_list.clear()
	
	for i in range(0, System.agi.logdir.size()):
		logic_list.add_item(str(i))

func _select_logic(index:int):
	logic = Logic.load_logic(index)
	logic_list.select(index)

func _on_option_button_logic_list_item_selected(index):
	_select_logic(index)
	
