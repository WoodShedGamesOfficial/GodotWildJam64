extends Node3D

#Seed Variable:
@export var Seed : String = "SeedMeSeymour"
var current_seed = 0
var town_loc = Vector3()
@export var t_radius = 100
#Procedurally Placed Item Variables:
@export var rock : PackedScene 
@export var rock_count = 500
@export var tree : PackedScene 
@export var tree_count = 1000
@export var town : PackedScene
@export var town_count = 1

#Environment Variables:
@onready var terrain = $Terrain/Terrain
@export var world_size = 1000
@export var subdivisions = 20
var complete_land = false
var offset = Vector3(0,-.5,0) 

#Material Exports:
@export var land_mat : Material

#Forced Max World Size Constants
const MIN_X = -1000
const MAX_X = 1000
const MIN_Z = -1000
const MAX_Z = 1000
const MAX_HEIGHT = 10

func set_seed(val:String)->void:
	current_seed = Seed.hash()
	seed(current_seed)

func _ready():
	set_seed(Seed)
	generate_world()


func _process(delta):
	if complete_land:
		generate_town()
		generate_trees()
		generate_rocks()
		set_process(false)
		complete_land = false

 
func generate_trees():
	var tree_seed = Seed.hash()
	seed(tree_seed*25.129873)
	for i in tree_count:
		var tpos = Vector3(randf_range(MIN_X, MAX_X),0,randf_range(MIN_Z,MAX_Z))
		var distance_to_position = tpos.distance_to(town_loc)
		if distance_to_position < t_radius:
			pass
		elif distance_to_position > t_radius:
			tpos.y = 500
			var treei = tree.instantiate()
			add_child(treei)
			var fnl_tpos = get_down_ray(tpos)
			var rot = Vector3(0,randf_range(0,360),0)
			treei.global_transform.origin = fnl_tpos
			treei.rotation_degrees = rot

func generate_rocks():
	var rock_seed = Seed.hash()
	seed(rock_seed*91.1237913)
	for i in rock_count:
		var rpos = Vector3(randf_range(MIN_X, MAX_X),0,randf_range(MIN_Z,MAX_Z))
		var distance_to_position = rpos.distance_to(town_loc)
		if distance_to_position < t_radius:
			pass
		elif distance_to_position > t_radius:
			rpos.y = 500
			var rocki = rock.instantiate()
			add_child(rocki)
			var fnl_rpos = get_down_ray(rpos)
			var rot = Vector3(0,randf_range(0,360),0)
			rocki.global_transform.origin = fnl_rpos
			rocki.rotation_degrees = rot
		#print("Rock Location")
		#print(fnl_pos)

func generate_town():
	var town_seed = Seed.hash()
	seed(town_seed*81.1237913)
	for i in town_count:
		var towni = town.instantiate()
		add_child(towni)
		var pos = Vector3(randf_range(-500, 600),500,randf_range(-400,500))
		var fnl_pos = get_down_ray(pos)
		var rot = Vector3(0,randf_range(0,360),0)
		fnl_pos.y = 0
		level_terrain(fnl_pos,t_radius,0)
		towni.global_transform.origin = fnl_pos
		towni.rotation_degrees = rot
		town_loc = fnl_pos
		print("Town Location: " + str(town_loc))

func get_down_ray(pos: Vector3) -> Vector3:
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

func generate_world():
	set_seed(Seed)
	var amesh = ArrayMesh.new()
	var mesh = PlaneMesh.new()
	var mdt = MeshDataTool.new()

	
	mesh.size = Vector2(world_size,world_size)
	mesh.subdivide_depth = subdivisions
	mesh.subdivide_width = subdivisions
	
	amesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,mesh.get_mesh_arrays())
	amesh.surface_set_material(0,land_mat)
	mdt.create_from_surface(amesh,0)
	
	for i in range(mdt.get_vertex_count()): #Generate Terrain Mesh
		var vertex = mdt.get_vertex(i)
		vertex.y += randf_range(0,MAX_HEIGHT)
		mdt.set_vertex(i,vertex)

	for face in mdt.get_face_count(): # Set Face Normals
		var vertex = mdt.get_face_vertex(face, 0)
		var normal = mdt.get_face_normal(face)
		mdt.set_vertex_normal(vertex,normal)
	
	mdt.commit_to_surface(amesh)
	terrain.mesh = amesh
	terrain.create_trimesh_collision() #Adds Collision to the Terrain

	complete_land = true

func level_terrain(position: Vector3, radius: int, level: float):
	var amesh = terrain.mesh
	var mdt = MeshDataTool.new()
	mdt.create_from_surface(amesh,1)
	
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		var distance_to_position = position.distance_to(vertex)
		if distance_to_position < radius:
			vertex.y = level
			mdt.set_vertex(i,vertex)

	for face in mdt.get_face_count(): # Set Face Normals
		var vertex = mdt.get_face_vertex(face, 0)
		var normal = mdt.get_face_normal(face)
		mdt.set_vertex_normal(vertex,normal)

	amesh.clear_surfaces()
	mdt.commit_to_surface(amesh)
	terrain.mesh = amesh
	terrain.create_trimesh_collision()
