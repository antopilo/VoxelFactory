tool
extends Control

# references
onready var open_button = get_node("VBoxContainer/MarginContainer/HBoxContainer/Button")
onready var save_button = get_node("VBoxContainer/MarginContainer/HBoxContainer/Button2")
onready var saveas_button = get_node("VBoxContainer/MarginContainer/HBoxContainer/Button3")
onready var open_dialog = get_node("OpenDialog")
onready var save_dialog = get_node("SaveDialog")
onready var eraser_button = get_node("VBoxContainer/MarginContainer/HBoxContainer/EraseTool")
onready var pen_button = get_node("VBoxContainer/MarginContainer/HBoxContainer/PenTool")
onready var move_button = get_node("VBoxContainer/MarginContainer/HBoxContainer/MoveTool")
onready var zoom_slider = get_node("VBoxContainer/MarginContainer3/HBoxContainer/ZoomSlider")
onready var color_button = get_node("VBoxContainer/MarginContainer/HBoxContainer/ColorPickerButton")
onready var viewport = get_node("VBoxContainer/MarginContainer2/ViewportContainer/Viewport/Spatial")
onready var position_label = get_node("VBoxContainer/MarginContainer3/HBoxContainer/VoxPosition")
onready var name_edit = get_node("VBoxContainer/MarginContainer/HBoxContainer/NameEdit")
onready var camera = viewport.get_node("Camera")

enum TOOLS { pen, eraser, move, color }

var current_file
var current_path = "res://"

var aim_position = Vector3()
var delete_position = Vector3()
var can_place_voxel = false
var current_color = Color(0,0,0)
var current_tool = TOOLS.pen
var last_tool = current_tool


func _ready():
	$VBoxContainer/MarginContainer/HBoxContainer/new.emit_signal("pressed")
	

func _physics_process(delta):
	if viewport == null:
		return
		
	var mouse_position = viewport.get_parent().get_mouse_position()

	# Raycasts to detect which voxel we are aiming at.
	var from = camera.project_ray_origin(mouse_position) # from camera.
	var to = from + camera.project_ray_normal(mouse_position) * 300 # ray length 30
	var space_state = viewport.get_world().direct_space_state  # get space state
	var result = space_state.intersect_ray(from, to) # perform raycast.
	can_place_voxel = result.get("collider") != null # if we hit something
	
	# SPACE SHORTCUT
	if Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(BUTTON_MIDDLE):
		pen_button.pressed = false
		eraser_button.pressed = false
		move_button.pressed = true
		current_tool = TOOLS.move
	elif (!Input.is_key_pressed(KEY_SPACE) or !Input.is_mouse_button_pressed(BUTTON_MIDDLE)) and current_tool != last_tool:
		if last_tool == TOOLS.pen: # resume to pen
			move_button.pressed = false
			pen_button.pressed = true
		elif last_tool == TOOLS.eraser: # resume to eraser
			move_button.pressed = false
			eraser_button.pressed = true
		current_tool = last_tool
	
	if can_place_voxel:
		var position = result.get("position") # hit position
		# placing position
		aim_position = Vector3(stepify(position.x - 0.5 + (result["normal"].x / 2), 1), 
							stepify(position.y - 0.5 + (result["normal"].y / 2), 1), 
							stepify(position.z - 0.5 + (result["normal"].z / 2), 1))
		# remove position
		delete_position = aim_position - (result["normal"])
		
		# set correct color
		viewport.get_node("cursor/cursor").material.albedo_color = current_color
		
		# Move cursor
		if current_tool == TOOLS.pen:
			position_label.text = "Current voxel: " + str(viewport.world_to_vox(aim_position))
			viewport.get_node("cursor").global_transform.origin = aim_position + Vector3(0.5, 0.5, 0.5)
		elif current_tool == TOOLS.eraser:
			position_label.text = "Current voxel: " + str(viewport.world_to_vox(delete_position))
			viewport.get_node("cursor").global_transform.origin = delete_position + Vector3(0.5, 0.5, 0.5)
		elif current_tool == TOOLS.color:
			position_label.text = "Current voxel: " + str(viewport.world_to_vox(delete_position))
			viewport.get_node("cursor/cursor").material.albedo_color = Color(0, 0, 0, 0)
		else: # make transparent
			viewport.get_node("cursor/cursor").material.albedo_color = Color(0, 0, 0, 0)
		
		viewport.camera.mouseEnabled = current_tool == TOOLS.move
	else:
		viewport.get_node("cursor/cursor").material.albedo_color = Color(0, 0, 0, 0)
		
		
func _input(event):
	if viewport == null:
		return
		
	# Updating camera _input manually.
	camera._input(event) 
	
 	# Making sure that we are editing something.
	if viewport.meshInstance.mesh == null:
		return
		
	# Placing voxel
	if can_place_voxel:
		# Pen tool
		if Input.is_mouse_button_pressed(1) && current_tool == TOOLS.pen:
			viewport.add_voxel(viewport.world_to_vox(aim_position), current_color)
		# Eraser tool
		if Input.is_mouse_button_pressed(1) && current_tool == TOOLS.eraser:
			viewport.remove_voxel(viewport.world_to_vox(delete_position))
		# Color picker
		if Input.is_mouse_button_pressed(1) && current_tool == TOOLS.color:
			current_color = viewport.Voxels[viewport.world_to_vox(delete_position)]
			$VBoxContainer/MarginContainer/HBoxContainer/ColorPickerButton.color = current_color
			print("color picked")
func _on_ZoomSlider_value_changed(value):
	viewport.camera.translation = Vector3(0, 0, value)
	viewport.camera.rotation_degrees = Vector3(0,0,0) 

func _on_OpenDialog_file_selected(path):
	current_path = path
	
	var mesh = load(path)
	current_file = mesh
	
	
	viewport.get_node("cursor").scale = Vector3(viewport.vox_size,
												viewport.vox_size,
												viewport.vox_size)
	# Update name on top for the path.
	name_edit.text = path
	
	# Make sure file is an arraymesh
	if !mesh.is_class("ArrayMesh"):
		printerr("Resource must be a Mesh")
		return
		
	viewport.Voxels.clear()
	viewport.get_node("MeshInstance").mesh = mesh
	
	viewport.updatePos() # center mesh
	viewport.updateVoxels() # fill dict with vox
	viewport.updateMesh() # create the mesh.
	$VBoxContainer/MarginContainer/HBoxContainer/VoxelSize.text = str(viewport.vox_size)

func _on_ColorPickerButton_color_changed(color):
	current_color = color

func _on_PenTool_pressed():
	current_tool = TOOLS.pen
	last_tool = TOOLS.pen

func _on_EraseTool_pressed():
	current_tool = TOOLS.eraser
	last_tool = TOOLS.eraser

func _on_MoveTool_pressed():
	current_tool = TOOLS.move 
	last_tool = current_tool
	
func _on_Open_pressed():
	open_dialog.popup_centered_ratio()

func _on_Save_pressed():
	save()
	
func _on_SaveAs_pressed():
	save_dialog.popup_centered_ratio()
	
func save():
	if current_path == "":
		save_dialog.popup_centered_ratio()
		return
	current_file = viewport.meshInstance.mesh
	# add new meta
	for vox in viewport.Voxels:
		current_file.set_meta(str(vox), viewport.Voxels[vox])
	
	current_file.set_meta("voxel_size", viewport.vox_size)

	ResourceSaver.save(current_path, current_file)
	


func _on_voxSizeSlider_value_changed(value):
	var line_edit = get_node("VBoxContainer/MarginContainer/HBoxContainer/VoxelSize")
	var voxsize = 1
	if value == 6:
		line_edit.text = "1"
	elif value == 5:
		line_edit.text = "1/2"
		voxsize = 1.0 / 2
	elif value == 4:
		line_edit.text = "1/4"
		voxsize = 1.0 / 4
	elif value == 3:
		line_edit.text = "1/8"
		voxsize = 1.0 / 8
	elif value == 2:
		line_edit.text = "1/16"
		voxsize = 1.0 / 16
	elif value == 1:
		line_edit.text = "1/32"
		voxsize = 1.0 / 32
	viewport.vox_size = voxsize
	
func _on_ColorPickerButton_pressed():
	pen_button.pressed = false
	eraser_button.pressed = false
	move_button.pressed = true
	move_button.emit_signal("pressed")
	current_tool = TOOLS.move           

# Remove fullbright
func _on_1_toggled(button_pressed):
	if !button_pressed:
		viewport.get_parent().debug_draw = 0
	else:
		viewport.get_parent().debug_draw = 1

# AO
func _on_2_toggled(button_pressed):
	viewport.camera.environment.ssao_enabled = !button_pressed


func _on_ColorPickerTool_pressed():
	current_tool = TOOLS.color
	last_tool = current_tool


func _on_sky_color_changed(color):
	viewport.camera.environment.background_color = color


func _on_new_pressed():
	current_path = ""

	viewport.factory.clear_voxels()
	viewport.factory.add_voxel(Vector3(0, 0, 0), Color(1,0,0))
	var mesh = viewport.factory.create_mesh()

	current_file = ArrayMesh.new()
	
	viewport.get_node("cursor").scale = Vector3(viewport.vox_size,
												viewport.vox_size,
												viewport.vox_size)
												
	# Update name on top for the path.
	name_edit.text = "unsaved mesh"
		
	viewport.Voxels.clear()
	viewport.get_node("MeshInstance").mesh = mesh
	
	viewport.updatePos() # center mesh
	viewport.updateVoxels() # fill dict with vox
	viewport.updateMesh() # create the mesh.
	$VBoxContainer/MarginContainer/HBoxContainer/VoxelSize.text = str(viewport.vox_size)


func _on_SaveDialog_file_selected(path):
	current_path = path
	name_edit.text = path
	save()
	
