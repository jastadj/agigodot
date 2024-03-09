extends Node2D

@onready var view_list = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/HBoxContainer/OptionButtonViews
@onready var loop_list = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/HBoxContainer/OptionButtonLoop
@onready var cel_list = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/HBoxContainer/OptionButtonCel
@onready var cel_transparency = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/HBoxContainer/CheckBoxTransparency
@onready var playpause = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/HBoxContainer/ButtonPlayAnimation

@onready var view_sprite = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/MarginContainerViewSprite/Sprite2DView
@onready var container_view_sprite = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/MarginContainerViewSprite

var image
var image_texture
var view_scale = 4
var view_scale_factor = 0.2

func _ready():
	
	image = Image.create(64,64, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	_update_view_sprite()
	
	# testing
	_on_file_dialog_game_dir_dir_selected("res://testdata/pq1")

func _input(event):
	
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				view_scale -= view_scale * view_scale_factor
				_update_view_sprite()
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				view_scale += view_scale * view_scale_factor
				_update_view_sprite()


func _update_view_sprite():
	image.resize(image.get_width(), image.get_height(), 0)
	image_texture = ImageTexture.create_from_image(image)
	view_sprite.texture = image_texture	
	view_sprite.scale = Vector2(view_scale*2, view_scale)
	view_sprite.position = Vector2(0,-view_sprite.get_rect().size.y * view_scale)

func _update_view_list():
	view_list.clear()
	
	if System.agi.views:
		if !System.agi.views.is_empty():
			for vi in range(0, System.agi.views.size()):
				view_list.add_item(str(vi))
			_select_view(0)

func _update_loop_list():
	loop_list.clear()
	
	# if invalid, clear
	if(view_list.selected < 0 or !System.agi.views[view_list.selected]):
		cel_list.clear()
		image.fill(Color.TRANSPARENT)
		_update_view_sprite()
		return
	
	for i in range(0, System.agi.views[view_list.selected]["loops"].size()):
		loop_list.add_item(str(i))
	
	if loop_list.item_count:
		_select_loop(0)

func _select_loop(index):
	loop_list.select(index)
	_update_cel_list()

func _on_button_load_game_dir_pressed():
	$CanvasLayer/ui/FileDialogGameDir.popup_centered()

func _on_file_dialog_game_dir_dir_selected(dir):
	System.agi.load_game_dir(dir)
	_update_view_list()

func _select_view(index):
	view_list.select(index)
	_update_loop_list()

func _update_cel_list():
	cel_list.clear()
	
	if(loop_list.selected < 0):
		return
	
	for i in range(0, System.agi.views[view_list.selected]["loops"][loop_list.selected]["cels"].size()):
		cel_list.add_item(str(i))
	
	if cel_list.item_count:
		_select_cel(0)

func _select_cel(index):	
	cel_list.select(index)
	
	var cel = System.agi.views[view_list.selected]["loops"][loop_list.selected]["cels"][index]
	var curview = System.agi.views[view_list.selected]
	var curloop = curview["loops"][loop_list.selected]
	var curcel = curloop["cels"][cel_list.selected]

	var pixeldata = View.cel_data_to_pixels(curcel, cel_transparency.button_pressed)
	
	image = Image.create_from_data( cel["w"], cel["h"], false, Image.FORMAT_RGBA8, pixeldata)
	
	if cel["m"] & 0x8:
		if loop_list.selected != (cel["m"] & 0x7):
			image.flip_x()
	_update_view_sprite()

func _on_option_button_views_item_selected(index):
	_select_view(index)

func _on_option_button_loop_item_selected(index):
	_select_loop(index)
	
func _on_option_button_cel_item_selected(index):
	_select_cel(index)

func _advance_cel():
	var cel = cel_list.selected
	if cel >= 0:
		cel = cel +1
		if cel >= cel_list.item_count:
			cel = 0
		_select_cel(cel)

func _on_timer_animation_timeout():
	if playpause.button_pressed:
		_advance_cel()

