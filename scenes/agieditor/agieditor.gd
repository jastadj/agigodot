extends Node2D

@onready var view_list = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/HBoxContainer/OptionButtonViews
@onready var loop_list = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/HBoxContainer/OptionButtonLoop
@onready var cel_list = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/HBoxContainer/OptionButtonCel
@onready var cel_texture_rect = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/TextureRectCel
@onready var playpause = $CanvasLayer/ui/Control/PanelContainer/VBoxContainer/HBoxContainer/ButtonPlayAnimation

var image
var image_texture
var view_scale = 4

func _ready():
	
	image = Image.create(64,64, false, Image.FORMAT_RGBA8)
	image.fill(Color.RED)
	_update_texture_rect()
	
	# testing
	_on_file_dialog_game_dir_dir_selected("res://testdata/pq1")

func _input(event):
	
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				view_scale += 1
				_update_texture_rect()
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				view_scale -= 1
				_update_texture_rect()


func _update_texture_rect():
	image.resize(image.get_width()*view_scale*2, image.get_height()*view_scale, 0)
	image_texture = ImageTexture.create_from_image(image)
	cel_texture_rect.texture = image_texture	

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
		_update_texture_rect()
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
	var pixeldata = PackedByteArray()
	var curview = System.agi.views[view_list.selected]
	var curloop = curview["loops"][loop_list.selected]
	var curcel = curloop["cels"][cel_list.selected]
	
	#print("offset: 0x%x" % curview["offset"], " loops:", curview["loops"].size())
	#print("loop:", loop_list.selected, ", cel:", cel_list.selected, ", w:", curcel["w"], ", h:", curcel["h"], ", t:", curcel["t"] )
	
	var cur_x = 0
	var line_counter = 0
	for d in cel["d"]:
		if d != 0:
			var runlen = d & 0x0f
			var color = System.agi.color[ (d & 0xf0) >> 4]
			cur_x += runlen
			for run in range(0, runlen):
				pixeldata.append(color.r8)
				pixeldata.append(color.g8)
				pixeldata.append(color.b8)
				pixeldata.append(color.a8)
		if d == 0:
			var color = System.agi.color[ cel["t"]]
			for run in range(0, cel["w"] - cur_x):
				pixeldata.append(color.r8)
				pixeldata.append(color.g8)
				pixeldata.append(color.b8)
				pixeldata.append(color.a8)
			cur_x = 0
			line_counter += 1
	#print("h:", cel["h"], ", w:", cel["w"], ", pixels:", pixeldata.size())
	
	image = Image.create_from_data( cel["w"], cel["h"], false, Image.FORMAT_RGBA8, pixeldata)
	
	if cel["m"] & 0x8:
		if loop_list.selected != (cel["m"] & 0x7):
			image.flip_x()
	_update_texture_rect()

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


func _on_button_play_animation_toggled(button_pressed):
	pass # Replace with function body.
