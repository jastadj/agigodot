extends Node

@onready var agi = load("res://system/agi/agi.gd").new()

func _ready():
	
	# add agi to tree
	add_child(agi)
