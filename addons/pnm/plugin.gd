@tool
extends EditorPlugin

var plugin_importer
var plugin_saver
var plugin_loader
var plugin_previewer
var plugin_inspector

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("PNM", "Resource", preload("pnm.gd"), null)
	
	plugin_importer = preload("plugin_importer.gd").new()
	add_import_plugin(plugin_importer)
	
	plugin_inspector = preload("plugin_inspector.gd").new()
	add_inspector_plugin(plugin_inspector)
	
	plugin_saver = preload("plugin_saver.gd").new()
	ResourceSaver.add_resource_format_saver(plugin_saver)
	
	plugin_loader = preload("plugin_loader.gd").new()
	ResourceLoader.add_resource_format_loader(plugin_loader)

	plugin_previewer = preload("plugin_previewer.gd").new()
	EditorInterface.get_resource_previewer().add_preview_generator(plugin_previewer)

	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("PNM")
	
	remove_import_plugin(plugin_importer)
	plugin_importer = null
	
	remove_inspector_plugin(plugin_inspector)
	plugin_inspector = null
	
	ResourceSaver.remove_resource_format_saver(plugin_saver)
	plugin_saver = null
	
	ResourceLoader.remove_resource_format_loader(plugin_loader)
	plugin_loader = null
	
	EditorInterface.get_resource_previewer().remove_preview_generator(plugin_previewer)
	plugin_previewer = null
	
	pass
