extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResourceLoader.add_resource_format_loader(
		preload("res://addons/pnm/plugin_loader.gd").new()
	)
	
	self.position = self.get_viewport().get_visible_rect().size * 0.5
	
	var pnm := load("res://addons/pnm/example/sample_640x426.ppm") as PNM
	
	var image := Image.create_from_data(
		pnm._width,
		pnm._height,
		false,
		pnm.image_format,
		pnm._pixels
	)
	
	self.texture = ImageTexture.create_from_image(image)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
