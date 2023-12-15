@tool
extends MeshInstance3D
#Basic Procederal Terrain based Level Generator 
#Coded by Kenneth White (OnlySmartSometimes)
#SnowShaderIntegrationCode by QbieShay


#environment variables
@onready var terrain = $"."
@export var land_mat = Material
@export var freq : float = 0.1

#Terrain Size Variables
@export var xSize: int = 30 
@export var zSize: int = 30
@export var ySize: int = 5
var vert_count: int = 0.0

#More variables
@export var Seed : String = "SeedMeSeymour"
var current_seed = 0
var town_loc = Vector3()
@export var t_radius = 100

#snow variables
const FOOTPRINT_SCENE = preload("res://WildJam_64/LEVELS/Dev_room/QbiesRoom/Trail.tscn")
@export
var pixel_per_unit = 10.0
@export
var cam: Camera3D
@export
var snow_material : ShaderMaterial
var footprint_objs = {}

#Procedurally Placed Item Variables:
@export var rock : PackedScene 
@export var rock_count = 500
@export var tree : PackedScene 
@export var tree_count = 1000
@export var town : PackedScene
@export var town_count = 1

#Editor Terrain Tool Variables
@export var update = false
@export var clear_vert_vis = false

#Constants
const MIN_X = 0
const MAX_X = 500
const MIN_Z = 0
const MAX_Z = 500

func _ready():
	#Terrain Code:
	if Engine.is_editor_hint():
		set_seed(Seed)
		generate_terrain()
		print("terrain Generated")
		generate_trees()
		print("trees Generated")
		pass

	generate_terrain()
	generate_trees()

#Snow Code:

	$SubViewport2/WorldRoot/Camera2D.make_current()
#	$SubViewport2.own_world_2d = true
	get_surface_override_material(0).set_shader_parameter("mask_texture", $SubViewport2.get_texture())
	for c in get_tree().get_nodes_in_group("footprint"):
		add_footprint(c)

func set_seed(val:String)->void:
	current_seed = Seed.hash()
	seed(current_seed)
	pass

func generate_terrain():
	var a_mesh:ArrayMesh
	var st = SurfaceTool.new()
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_smooth_group(-1)
	var n = FastNoiseLite.new()
	n.noise_type = FastNoiseLite.TYPE_PERLIN
	n.frequency = freq
	for z in range(zSize+1):
		for x in range(xSize+1):
			var y = n.get_noise_2d(x,z)*5
			var vertexs = Vector3(x,y,z)
#			print("vertex:" + str(vertexs))
			var uv = Vector2()
			uv.x = inverse_lerp(0,xSize,x)
			uv.y = inverse_lerp(0,zSize,z)
			st.set_uv(uv)
			st.add_vertex(vertexs)
#			st.add_uv(Vector3(x,y,z))
			if xSize < 30:
				if zSize < 30:
					draw_sphere(Vector3(x,y,z))
			vert_count += 1
	var vert = 0
	for z in zSize:
		for x in xSize:
			st.add_index(vert+0)
			st.add_index(vert+1)
			st.add_index(vert+xSize+1)
			st.add_index(vert+xSize+1)
			st.add_index(vert+1)
			st.add_index(vert+xSize+2)
			vert+=1
		vert+=1
	st.generate_normals()
	#st.generate_tangents()
	a_mesh = st.commit()
	terrain.mesh = a_mesh
	terrain.create_trimesh_collision()
	print("terrain Generated")


func draw_sphere(pos:Vector3):
	var ins = MeshInstance3D.new()
	add_child(ins)
	ins.position = pos
	var sphere = SphereMesh.new()
	sphere.radius = 0.2
	sphere.height = 0.3
	ins.mesh = sphere
	pass
	
func generate_trees():
	print("starting Tree Gen")
	var tree_seed = Seed.hash()
	seed(tree_seed*25.129873)
	
	for i in tree_count:
		var tpos = Vector3(randf_range(MIN_X, MAX_X),0,randf_range(MIN_Z,MAX_Z))
		tpos.y = 500
		var treei = tree.instantiate()
		add_child(treei)
		var fnl_tpos = get_down_ray(tpos)
		var rot = Vector3(0,randf_range(0,360),0)
		treei.global_transform.origin = fnl_tpos
		treei.rotation_degrees = rot
	pass
	
func get_down_ray(pos: Vector3) -> Vector3: #/snaps assets to ground
	var length = 1000
	var to = Vector3(pos.x, pos.y - length, pos.z)
	var space_state = get_world_3d().direct_space_state
	var param = PhysicsRayQueryParameters3D.new()
	param.from = pos
	param.to = to
	var result = space_state.intersect_ray(param)
	if result:
		return result.position
		print(result)
	else:
		return pos
		print (pos)
	pass

#SnowRelated Code:
func add_footprint(obj):
	var footprint = FOOTPRINT_SCENE.instantiate()
	obj.connect("tree_exited", Callable(self, "remove_footprint").bind([obj]))
	$SubViewport2/WorldRoot.add_child(footprint)
	footprint_objs[obj] = footprint

func remove_footprint(obj):
	footprint_objs[obj].queue_free()
	footprint_objs.erase(obj)

func _process(_delta):
	#Terrain Code:
	if update:
		generate_terrain()
		update = false 
	if clear_vert_vis:
		for i in get_children():
			i.free()
			clear_vert_vis = false

	#Snow Code:
	$SubViewport2/WorldRoot/Camera2D.position = Vector2(cam.global_position.x, cam.global_position.z) * pixel_per_unit 
	var anchor_pos = cam.global_transform.origin
	snow_material.set_shader_parameter("world_xy_anchor", Vector2(anchor_pos.x, anchor_pos.z))
	for obj in footprint_objs.keys():
		footprint_objs[obj].global_position = Vector2(obj.global_position.x, obj.global_position.z) * pixel_per_unit + Vector2(0.0,350)
#		print("setting trail pos to ",footprint_objs[obj].position, "from object ", Vector2(obj.global_position.x, obj.global_position.y) * pixel_per_unit )

	
	

	pass
