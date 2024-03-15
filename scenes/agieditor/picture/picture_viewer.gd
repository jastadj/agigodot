extends Control

@onready var picture_list = $PanelContainer/VBoxContainer/HBoxContainer/OptionButtonPictures
@onready var picture_texturerect = $PanelContainer/VBoxContainer/TextureRectPicture
@onready var priority_check_box = $PanelContainer/VBoxContainer/HBoxContainer/CheckBoxPriority

# picture data
var picture = null

# picture image/texture
var picture_texture:ImageTexture
var priority_texture:ImageTexture
var picture_image:Image
var priority_image:Image


var picture_scale:float = 8.0

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
	
	_update_picture_image()
		
func _update_picture_image():
	if picture:
		var pic = Picture.new()
		var images = pic.get_images_from_picture(picture)
		
		for image in images:
			image.resize(AGI.AGI_WIDTH * picture_scale, AGI.AGI_HEIGHT * picture_scale, Image.INTERPOLATE_NEAREST)
		
		picture_image = images[0]
		priority_image = images[1]
		
		picture_texture = ImageTexture.create_from_image(picture_image)
		priority_texture = ImageTexture.create_from_image(priority_image)
		
	else:
		picture_texture = null
		priority_texture = null
		
	_update_picture_layer_view()

func _on_option_button_pictures_item_selected(index):
	_select_picture(index)

func _update_picture_layer_view():
	
	if !priority_check_box.button_pressed:
		picture_texturerect.texture = picture_texture
	else:
		picture_texturerect.texture = priority_texture
	

func _on_check_box_priority_toggled(button_pressed):
	_update_picture_layer_view()
