extends MeshInstance3D

const FOOTPRINT_SCENE = preload("res://WildJam_64/LEVELS/Dev_room/QbiesRoom/Trail.tscn")

@export
var pixel_per_unit = 10.0

@export
var cam: Camera3D

@export
var snow_material : ShaderMaterial

var footprint_objs = {}

func add_footprint(obj):
	var footprint = FOOTPRINT_SCENE.instantiate()
	obj.connect("tree_exited", Callable(self, "remove_footprint").bind([obj]))
	$SubViewport2/WorldRoot.add_child(footprint)
	footprint_objs[obj] = footprint

func remove_footprint(obj):
	footprint_objs[obj].queue_free()
	footprint_objs.erase(obj)

func _ready():
	if !is_instance_valid(snow_material):
		## IF YOU CRASH HERE ASSIGN A VALID SNOW MATERIAL
		printerr("Please assign a snow material to the node " + str(get_path()))
		breakpoint
	$SubViewport2/WorldRoot/Camera2D.make_current()
#	$SubViewport2.own_world_2d = true
	snow_material.set_shader_parameter("mask_texture", $SubViewport2.get_texture())
	for c in get_tree().get_nodes_in_group("footprint"):
		add_footprint(c)

func _process(delta):
	$SubViewport2/WorldRoot/Camera2D.position = Vector2(cam.global_position.x, cam.global_position.z) * pixel_per_unit 
	var anchor_pos = cam.global_transform.origin
	snow_material.set_shader_parameter("world_xy_anchor", Vector2(anchor_pos.x, anchor_pos.z))
	for obj in footprint_objs.keys():
		footprint_objs[obj].global_position = Vector2(obj.global_position.x, obj.global_position.z) * pixel_per_unit + Vector2(0.0,350)
#		print("setting trail pos to ",footprint_objs[obj].position, "from object ", Vector2(obj.global_position.x, obj.global_position.y) * pixel_per_unit )
