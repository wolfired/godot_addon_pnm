@tool
extends EditorImportPlugin

func _get_importer_name() -> String:
	return "pnm.importer"

func _get_visible_name() -> String:
	return "PNM"

func _get_recognized_extensions() -> PackedStringArray:
	return PackedStringArray(["pbm", "pgm", "ppm"])

func _get_save_extension() -> String:
	return "pnm"

func _get_resource_type() -> String:
	return "PNM"

func _get_import_options(path: String, preset_index: int) -> Array[Dictionary]:
	return []

func _get_option_visibility(path: String, option_name: StringName, options: Dictionary) -> bool:
	return true

func _import(source_file: String, save_path: String, options: Dictionary, platform_variants: Array[String], gen_files: Array[String]) -> Error:
	var f := FileAccess.open(source_file, FileAccess.READ)
	
	var buf := f.get_buffer(f.get_length())
	f.close()
	
	var pnm := PNM.create_from_data(buf)
	
	return ResourceSaver.save(pnm,  "%s.%s" % [save_path, _get_save_extension()])
	
