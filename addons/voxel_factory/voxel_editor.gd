extends Control
tool
# buttons
onready var open_button = get_node("VBoxContainer/MarginContainer/HBoxContainer/Button")
onready var save_button = get_node("VBoxContainer/MarginContainer/HBoxContainer/Button2")
onready var open_dialog = get_node("OpenDialog")
onready var save_dialog = get_node("SaveDialog")
onready var zoom_slider = get_node("VBoxContainer/MarginContainer3/HBoxContainer/ZoomSlider")
onready var viewport = get_node("VBoxContainer/MarginContainer2/ViewportContainer/Viewport/Spatial")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ZoomSlider_value_changed(value):
	viewport.cam.fov = value

func _on_Open_pressed():
	open_dialog.popup_centered()

func _on_Save_pressed():
	save_dialog.popup_centered()


func _on_OpenDialog_file_selected(path):
	var mesh = load(path)
	if !mesh.is_class("ArrayMesh"):
		printerr("Resource must be a Mesh")
		return
	
	viewport.meshInstance.mesh = mesh
	viewport.updatePos()
