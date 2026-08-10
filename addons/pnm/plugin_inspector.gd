@tool
extends EditorInspectorPlugin

func _can_handle(object: Object) -> bool:
	return object is PNM

func _parse_begin(object: Object) -> void:
	var pnm := object as PNM
	
	if !is_instance_valid(pnm):
		return
	
	var i := Image.create_from_data(pnm._width, pnm._height, false, pnm.image_format, pnm._pixels)
	
	var tr = TextureRect.new()
	tr.texture = ImageTexture.create_from_image(i)
	
	self.add_custom_control(tr)
