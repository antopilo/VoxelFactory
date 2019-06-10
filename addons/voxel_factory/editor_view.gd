extends Spatial
tool

onready var cam = get_node("Camera")
onready var meshInstance = get_node("MeshInstance")

# Called when the node enters the scene tree for the first time.
func _ready():
	updatePos()

func updatePos():
	var aabb = meshInstance.get_aabb()
	meshInstance.global_transform.origin = -aabb.size / 2 
	print("moved: " + str(-aabb.size / 2))