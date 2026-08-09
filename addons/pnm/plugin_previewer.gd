@tool
extends EditorResourcePreviewGenerator

func _handles(type: String) -> bool:
	return "PNM" == type

func _can_generate_small_preview() -> bool:
	return true

func _generate(resource: Resource, size: Vector2i, metadata: Dictionary) -> Texture2D:
	var pnm := resource as PNM
	
	if null == pnm:
		return null
	
	var i := Image.create_from_data(pnm._width, pnm._height, false, pnm.image_format, pnm._pixels)
	
	return ImageTexture.create_from_image(i)
