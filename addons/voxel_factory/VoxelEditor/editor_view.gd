tool
extends Spatial

onready var factory = preload("res://addons/voxel_factory/voxel_factory.gd").new()
onready var camera = get_node("Camera")
onready var meshInstance = get_node("MeshInstance")

var vox_size = 1.0
var Voxels = {} # Data dictionnary

# Called when the node enters the scene tree for the first time.
func _ready():
	draw_axis()
	
	
	var Vertices = factory.Vertices
	var ig = get_node("cursor/cursorOutline")
	ig.begin(Mesh.PRIMITIVE_LINE_STRIP)
	ig.set_color(Color(1,0,0))
	
	# Making cube outline
	ig.add_vertex(Vertices[0])
	ig.add_vertex(Vertices[1])
	ig.add_vertex(Vertices[2])
	ig.add_vertex(Vertices[3])
	
	ig.add_vertex(Vertices[3])
	ig.add_vertex(Vertices[0])
	
	ig.add_vertex(Vertices[4])
	ig.add_vertex(Vertices[5])
	ig.add_vertex(Vertices[1])
	
	ig.add_vertex(Vertices[5])
	ig.add_vertex(Vertices[6])
	ig.add_vertex(Vertices[2])
	
	ig.add_vertex(Vertices[6])
	ig.add_vertex(Vertices[7])
	ig.add_vertex(Vertices[3])
	
	ig.add_vertex(Vertices[7])
	ig.add_vertex(Vertices[4])
	ig.end()

# Makes the axis
func draw_axis():
	# X
	var ig = get_node("Axis/X")
	ig.begin(Mesh.PRIMITIVE_LINE_STRIP)
	ig.set_color(Color(1, 0, 0))
	ig.add_vertex(Vector3(-999, 0, 0))
	ig.add_vertex(Vector3(999, 0, 0))
	ig.end()
	# Y
	ig = get_node("Axis/Y")
	ig.begin(Mesh.PRIMITIVE_LINE_STRIP)
	ig.set_color(Color(0, 1, 0))
	ig.add_vertex(Vector3(0 ,-999, 0))
	ig.add_vertex(Vector3(0, 999, 0))
	ig.end()
	# Z
	ig = get_node("Axis/Z")
	ig.begin(Mesh.PRIMITIVE_LINE_STRIP)
	ig.set_color(Color(0, 0, 1))
	ig.add_vertex(Vector3(0, 0, -999))
	ig.add_vertex(Vector3(0, 0, 999))
	ig.end()
# Reads voxels meta-data from mesh resource.
func updateVoxels():
	var mesh = meshInstance.mesh
	
	if mesh == null:
		return
		
	var meta = mesh.get_meta_list()
	var key 
	var value 
	for data in meta:
		if data == "voxel_size":
			vox_size = mesh.get_meta(data)
			continue
			
		key = str2vector3(data)
		value = mesh.get_meta(data)
		Voxels[key] = value
	
# Converts a string to a Vector3
func str2vector3(string) -> Vector3:
	var array = string.split(',')
	var result = Vector3(array[0].right(1), array[1], array[2].left(array[2].length()))
	return result

# Converts global position to a voxel position.
func world_to_vox(mouse_pos):
	if meshInstance.mesh == null:
		return null
	return mouse_pos - meshInstance.global_transform.origin / vox_size

# Adds a voxel to the mesh
func add_voxel(position, color):
	Voxels[position] = color
	updateMesh()

# Removes a voxel to the mesh
func remove_voxel(position):
	print("removed vox at: ", position)
	Voxels[position] = Color(0, 0, 0, 0)
	updateMesh()
	
# Update and reconstruct the mesh
func updateMesh():
	factory.clear_voxels()
	factory.VoxelSize = vox_size
	factory.update_vertices()
	
	for vox in Voxels:
		factory.add_voxel(vox, Voxels.get(vox))

	meshInstance.mesh = null
	meshInstance.mesh = factory.create_mesh()
	
	for c in meshInstance.get_children():
		c.queue_free()
		
	meshInstance.create_trimesh_collision()

func resetCam():
	camera.translation = Vector3(0,0,20)
	camera.rotation_degrees = Vector3(0,0,0)
	
# Centers the mesh.
func updatePos(position):
	meshInstance.global_transform.origin = -position
	for c in meshInstance.get_children():
		c.queue_free()
	meshInstance.create_trimesh_collision()
	print(position)