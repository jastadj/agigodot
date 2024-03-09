extends Node2D

@export var screen_scale:float = 4.0

func _ready():
	
	get_window().size = Vector2i(AGI.AGI_WIDTH, AGI.AGI_HEIGHT) * screen_scale
	
	scale = Vector2(1,1) * System.agi.render_scale
	
	var imgdata = PackedByteArray()
	var imgw = 64
	var imgh = 64
	
	for i in range(0, imgw*imgh):
		var cgacol = System.agi.color[randi()%16]
		imgdata.append(cgacol.r8) # r
		imgdata.append(cgacol.g8) # g
		imgdata.append(cgacol.b8) # b
		imgdata.append(0xff) # a
	
	var img = Image.create_from_data(imgw, imgh, false, Image.FORMAT_RGBA8, imgdata)
	#img.srgb_to_linear()
		
	var imgtexture = ImageTexture.create_from_image(img)
	imgtexture.set_size_override(Vector2i(imgw, imgh))
	
	
	var sprite = Sprite2D.new()
	sprite.texture = imgtexture
	sprite.centered = false
	
	add_child(sprite)
