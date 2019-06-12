tool
extends EditorPlugin

var dock
var editor
func _enter_tree():
    # Initialization of the plugin goes here
    # Add the new type with a name, a parent type, a script and an icon
	add_custom_type("VoxelFactory", "Spatial", preload("voxel_factory.gd"), preload("icon.png"))
	dock = preload("res://addons/voxel_factory/Pix2Vox/dock_exporter.tscn").instance()
	dock.fs = get_editor_interface().get_resource_filesystem()
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_UR, dock)
	
	editor = preload("res://addons/voxel_factory/VoxelEditor/voxel_editor.tscn").instance()
	add_control_to_bottom_panel(editor, "Voxel editor")
	
func _exit_tree():
    # Clean-up of the plugin goes here
    # Always remember to remove it from the engine when deactivated
	remove_custom_type("voxel_factory")
	remove_control_from_docks(dock)
	remove_control_from_bottom_panel(editor)