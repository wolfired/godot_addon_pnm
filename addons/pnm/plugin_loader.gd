@tool
extends ResourceFormatLoader

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["pnm"])

func _get_resource_type(path: String) -> String:
	return "PNM"

func _handles_type(type: StringName) -> bool:
	return "PNM" == type

func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int) -> Variant:
	var f := FileAccess.open(path, FileAccess.READ)
	
	var pnm := PNM.new()
	pnm._magic = f.get_16()
	pnm._width = f.get_32()
	pnm._height = f.get_32()
	pnm._maxval = f.get_16()
	pnm._pixels = f.get_buffer(pnm.pixel_count * pnm.byte_count_per_pixel)
	
	f.close()
	
	return pnm
