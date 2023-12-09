extends Node3D

#Seed Variable:
@export var Seed : String = "SeedMeSeymour"
var current_seed = 0

#Procedurally Placed Item Variables:
@export var rock : PackedScene
@export var rock_count = 30
@export var tree : PackedScene
@export var tree_count = 50

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
	for i in range(mdt.get_vertex_count()):
		var vertex = mdt.get_vertex(i)
		vertex.y += randf() * MAX_HEIGHT
		mdt.set_vertex(i,vertex)
	mdt.commit_to_surface(amesh)
	terrain.mesh = amesh
	terrain.create_trimesh_collision()
	complete_land = true
