extends Node
tool
# ------ Voxel Factory -----
#
# I recommend putting this script in your autoloads
# You can them access the factory by doing : 
# 	onready var VoxelFactory = get_node("/root/VoxelFactory")
#
# After that you have access to the factory through this node.
# For exemple:
#	self.mesh = VoxelFactory.create_mesh_from_image_file("res://icon.png")
#
# Thank you for downloading Voxel factory.
# If you need help you can message me on the discord: 
#                                                     @Kreptic
var VoxelSize = 1.0
var DefaultMaterial = SpatialMaterial.new()
var Voxels = {} # Data in the factory
var Surfacetool = SurfaceTool.new()

# Vertices of a cube
var Vertices = [
	Vector3(0,0,0), Vector3(VoxelSize,0,0),
	Vector3(VoxelSize,0,VoxelSize), Vector3(0,0,VoxelSize),
	Vector3(0,VoxelSize,0), Vector3(VoxelSize,VoxelSize,0),
	Vector3(VoxelSize,VoxelSize,VoxelSize), Vector3(0,VoxelSize,VoxelSize) ]

func update_vertices():
	Vertices = [
		Vector3(0,0,0), Vector3(VoxelSize,0,0),
		Vector3(VoxelSize,0,VoxelSize), Vector3(0,0,VoxelSize),
		Vector3(0,VoxelSize,0), Vector3(VoxelSize,VoxelSize,0),
		Vector3(VoxelSize,VoxelSize,VoxelSize), Vector3(0,VoxelSize,VoxelSize) 
	]

func _ready():
	# Making sure that vertex color are used
	DefaultMaterial.vertex_color_use_as_albedo = true
	DefaultMaterial.vertex_color_is_srgb = true
	DefaultMaterial.flags_transparent = true
	
# Adds a voxel to the dict.
func add_voxel(position, color):
	if color.a == 0:
		return
	Voxels[position] = color

func clear_voxels():
	Voxels.clear()

# From image file.
func create_mesh_from_image_file(path) -> Mesh:
	var image = Image.new()
	image.load(path)
	return create_mesh_from_image(image)

# From image data-type
func create_mesh_from_image(image) -> Mesh:
	Voxels.clear()
	var imageSize = image.get_size()
	
	# Image is upside down by default.
	image.flip_y()
	image.lock()
	
	# For each pixel add a voxel.
	for x in imageSize.x:
		for y in imageSize.y:
			add_voxel(Vector3(x, y, 0), image.get_pixel(x, y))
	
	image.unlock()
	return create_mesh()


# Starts the creation of the mesh
func create_mesh() -> ArrayMesh:
	Surfacetool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	DefaultMaterial.vertex_color_use_as_albedo = true
	DefaultMaterial.vertex_color_is_srgb = true
	Surfacetool.set_material(DefaultMaterial)
	
	# Creating the mesh...
	for vox in Voxels:
		create_voxel(Voxels[vox], vox)

	# Finalise the mesh and return.
	Surfacetool.index()
	var mesh = Surfacetool.commit()

	# add meta data to resource for the editor.
	for vox in Voxels:
		mesh.set_meta(str(vox), Voxels[vox])
	mesh.set_meta("voxel_size", VoxelSize)
	Surfacetool.clear()
	return mesh 

# Decides where to put faces on the mesh.
# Checks if there is an adjacent block before place a face.
func create_voxel(color, position):
	var left = Voxels.get(position - Vector3(1, 0, 0)) == null
	var right = Voxels.get(position + Vector3(1, 0, 0)) == null
	var back = Voxels.get(position - Vector3(0, 0, 1)) == null
	var front = Voxels.get(position + Vector3(0, 0, 1)) == null
	var bottom = Voxels.get(position - Vector3(0, 1, 0)) == null
	var top = Voxels.get(position + Vector3(0, 1, 0)) == null
	
	# Stop if the block is completly hidden.
	if(!left and !right and !top and !bottom and !front and !back):
		return
	
	Surfacetool.add_color(color)
	
	if top:
		Surfacetool.add_normal(Vector3(0, -1, 0))
		Surfacetool.add_vertex(Vertices[4] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[5] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[7] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[5] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[6] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[7] + position * VoxelSize)
	if right:
		Surfacetool.add_normal(Vector3(1, 0, 0))
		Surfacetool.add_vertex(Vertices[2] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[5] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[1] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[2] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[6] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[5] + position * VoxelSize)
	if left:
		Surfacetool.add_normal(Vector3(-1, 0, 0))
		Surfacetool.add_vertex(Vertices[0] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[7] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[3] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[0] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[4] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[7] + position * VoxelSize)
	if front:
		Surfacetool.add_normal(Vector3(0, 0, 1))
		Surfacetool.add_vertex(Vertices[6] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[2] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[3] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[3] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[7] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[6] + position * VoxelSize)
	if back:
		Surfacetool.add_normal(Vector3(0, 0, -1))
		Surfacetool.add_vertex(Vertices[0] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[1] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[5] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[5] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[4] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[0] + position * VoxelSize)
	if bottom:
		Surfacetool.add_normal(Vector3(0, 1, 0))
		Surfacetool.add_vertex(Vertices[1] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[3] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[2] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[1] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[0] + position * VoxelSize)
		Surfacetool.add_vertex(Vertices[3] + position * VoxelSize)

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	