@tool
extends ResourceFormatSaver

func _get_recognized_extensions(resource: Resource) -> PackedStringArray:
	return PackedStringArray(["pnm"])

func _recognize(resource: Resource) -> bool:
	return resource is PNM

func _save(resource: Resource, path: String, flags: int) -> Error:
	var pnm := resource as PNM
	
	var f := FileAccess.open(path, FileAccess.WRITE)
	f.store_16(pnm._magic)
	f.store_32(pnm._width)
	f.store_32(pnm._height)
	f.store_16(pnm._maxval)
	f.store_buffer(pnm._pixels)
	f.close()
	
	return OK
