tool
extends Control 

var fs = null
var current_file = null
onready var preview = get_node("Panel/VBoxContainer/MarginContainer2/TextureRect")
onready var openButton = get_node("Panel/VBoxContainer/MarginContainer/Button")
onready var exportButton = get_node("Panel/VBoxContainer/MarginContainer3/Button")
onready var fileDialog = get_node("FileDialog")
onready var exportDialog = get_node("SaveDialog")
onready var voxelFactory = get_node("VoxelFactory")

# Load button
func _on_OpenButton_Pressed():
	fileDialog.popup_centered_minsize()

# C# call
func exportMesh(dir):
	var mesh = voxelFactory.create_mesh_from_image_file(current_file)
	print("saved at: " + dir)
	for vox in voxelFactory.Voxels:
		mesh.set_meta(str(vox), voxelFactory.Voxels[vox])
	
	mesh.set_meta("voxel_size", voxelFactory.VoxelSize)
	ResourceSaver.save(dir, mesh)
	
# Load Dialog
func _on_FileDialog_file_selected(path):
	current_file = path
	updatePreview()

# Update the preview window
func updatePreview():
	var image = Image.new() 
	image.load(current_file)
	
	var tex = ImageTexture.new()
	tex.create_from_image(image,0)
	tex.flags = 0
	
	preview.texture = tex
	
# Export Button
func _on_Button_pressed():
	exportDialog.popup_centered_minsize()
	if fs != null:
		print('Scanned file system.')
		fs.scan()
		
func _on_SaveDialog_file_selected(path):
	exportMesh(path)
