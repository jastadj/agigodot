extends Control

@onready var view_list = $PanelContainer/VBoxContainer/HBoxContainer/OptionButtonViews
@onready var loop_list = $PanelContainer/VBoxContainer/HBoxContainer/OptionButtonLoop
@onready var cel_list = $PanelContainer/VBoxContainer/HBoxContainer/OptionButtonCel
@onready var cel_transparency = $PanelContainer/VBoxContainer/HBoxContainer/CheckBoxTransparency
@onready var playpause = $PanelContainer/VBoxContainer/HBoxContainer/ButtonPlayAnimation

@onready var view_sprite = $PanelContainer/VBoxContainer/MarginContainerViewSprite/Sprite2DView
@onready var container_view_sprite = $PanelContainer/VBoxContainer/MarginContainerViewSprite

var image
var image_texture
var view_scale = 4
var view_scale_factor = 0.2
var play_speed = 0.1

var view = null

func _ready():
	
	image = Image.create(64,64, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	
	$TimerAnimation.connect("timeout", _on_timer_animation_timeout)
	
	_start_playback_timer()
	
	_update_view_sprite()
	
	connect("visibility_changed", _on_show)

func _on_show():
	if visible:
		_update_view_list()

func _input(event):
	
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				view_scale -= view_scale * view_scale_factor
				_update_view_sprite()
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				view_scale += view_scale * view_scale_factor
				_update_view_sprite()

func _clear_view():
	
	# clear lists and deselect all
	view_list.clear()
	view_list.select(-1)
	loop_list.clear()
	view_list.select(-1)
	cel_list.clear()
	cel_list.select(-1)
	
	# clear image
	_clear_image()

func _clear_image():
	# clear image
	image.fill(Color.TRANSPARENT)
	_update_view_sprite()
		
func _start_playback_timer():
	$TimerAnimation.start(play_speed)

func _update_view_sprite():
	image.resize(image.get_width(), image.get_height(), 0)
	image_texture = ImageTexture.create_from_image(image)
	view_sprite.texture = image_texture	
	view_sprite.scale = Vector2(view_scale*2, view_scale)
	view_sprite.position = Vector2(0,-view_sprite.get_rect().size.y * view_scale)

func _update_view_list():
	view_list.clear()
		
	for i in range(0, System.agi.viewdir.size()):
		view_list.add_item(str(i))
	
	if view_list.item_count == 0:
		_select_view(-1)
	else:
		_select_view(0)

func _update_loop_list():
	loop_list.clear()
	
	# if no view is selected, clear
	if view == null or view_list.selected == -1:
		_update_cel_list()
		return
	
	
	for i in range(0, view["loops"].size()):
		loop_list.add_item(str(i))
	
	if loop_list.item_count:
		_select_loop(0)

func _select_loop(index):
	loop_list.select(index)
	_update_cel_list()
	

func _select_view(index):
	view = View.load_view(index)
	if view == null:
		_clear_image()
	view_list.select(index)
	_update_loop_list()

func _update_cel_list():
	cel_list.clear()
	
	if view == null or loop_list.selected == -1:
		return
	
	for i in range(0, view["loops"][loop_list.selected]["cels"].size()):
		cel_list.add_item(str(i))
	
	if cel_list.item_count:
		_select_cel(0)

func _select_cel(index):	
	cel_list.select(index)
	
	var cel = view["loops"][loop_list.selected]["cels"][index]
	var curloop = view["loops"][loop_list.selected]
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
