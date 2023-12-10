extends Node3D

#Seed Variable:
@export var Seed : String = "SeedMeSeymour"
var current_seed = 0

#Procedurally Placed Item Variables:
@export var rock : PackedScene = preload("res://WildJam_64/ASSETS/Enviromental/Rocks/rock.res")
@export var rock_count = 30
@export var tree : PackedScene = preload("res://WildJam_64/ASSETS/Enviromental/Trees/tree.res")
@export var tree_count = 50
@export var town : PackedScene
@export var town_count = 1

#Environment Variables:
@onready var terrain = $Terrain/Terrain
@export var world_size = 700
@export var subdivisions = 20
var complete_land = false
var offset = Vector3(0,2.5,0) 
#Material Exports:
@export var land_mat : Material


#Forced Max World Size Constants
const MIN_X = -250
const MAX_X = 250
const MIN_Z = -250
const MAX_Z = 250
const MAX_HEIGHT = 10

func _ready():
	current_seed = Seed.hash()
	seed(current_seed)
	generate_world()

func _process(delta):
	if complete_land:
		generate_trees()
		generate_rocks()
		generate_town()
		set_process(false)
		complete_land = false

func generate_trees():
	for i in tree_count:
		var treei = tree.instantiate()
		add_child(treei)
		var pos = Vector3(randf_range(MIN_X, MAX_X),100,randf_range(MIN_Z,MAX_Z))
		var fnl_pos = get_down_ray(pos)
		treei.global_transform.origin = fnl_pos


func generate_rocks():
	for i in rock_count:
		var rocki = rock.instantiate()
		add_child(rocki)
		var pos = Vector3(randf_range(MIN_X, MAX_X),100,randf_range(MIN_Z,MAX_Z))
		var fnl_pos = get_down_ray(pos)
		rocki.global_transform.origin = fnl_pos
		

func generate_town():
	pass

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
	else:
		return pos

func generate_world():
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
		vertex.y += randf() * MAX_HEIGHT
		mdt.set_vertex(i,vertex)
	
	for face in mdt.get_face_count(): # Set Face Normals
		var vertex = mdt.get_face_vertex(face, 0)
		var normal = mdt.get_face_normal(face)
		mdt.set_vertex_normal(vertex,normal)
	
	mdt.commit_to_surface(amesh)
	terrain.mesh = amesh
	terrain.create_trimesh_collision() #Adds Collision to the Terrain

	complete_land = true
