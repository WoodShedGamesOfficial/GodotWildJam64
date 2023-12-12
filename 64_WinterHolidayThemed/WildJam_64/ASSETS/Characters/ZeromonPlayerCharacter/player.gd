extends CharacterBody3D
@onready var crt_shader = $PlayerOrigin/WorldCam/PlayerGUI/CRT_Shader/Container

@export var PLAYERSTATS = {
	"Health" : 100,
	"HealthMax" : 100,
	"Mana" : 100,
	"Stamina" : 100,
	'WalkSpeed' : 20,
	"RotationSpeed" : 0.5,
}

@onready var health = PLAYERSTATS.Health
@onready var healthmax = PLAYERSTATS.HealthMax
@onready var mana = PLAYERSTATS.Mana
@onready var stamina = PLAYERSTATS.Stamina
@onready var walk_speed = PLAYERSTATS.WalkSpeed
@onready var rotation_speed = PLAYERSTATS.RotationSpeed

@onready var mesh = $TheShadowInTheDark2


const JUMP_VELOCITY = 4.5


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	add_to_group("Player")
	
	
	pass


func _input(event):
	if InputEventMouseMotion:
		control_camera() #/ takes player mouse input for camera control
	
	
	pass

func _physics_process(delta):

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
#		rotation.y = atan2(-velocity.x,-velocity.z)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
	
	
	
	move_and_slide()
	
	
	pass

func control_camera():
	var space_state = get_world_3d().direct_space_state
	var mousePos = get_viewport().get_mouse_position()
	var camera = $PlayerOrigin/WorldCam
	var mouseCast = $PlayerOrigin/WorldCam/MouseCast
	var rayOrigin = camera.project_ray_origin(mousePos)
	var rayEnd = camera.project_ray_normal(mousePos) * 1000
	var query = PhysicsRayQueryParameters3D.create(rayOrigin, rayEnd)
	
	query.collide_with_areas = true
	var result = space_state.intersect_ray(query)
	
	if result != null:
		mouseCast.set_target_position(result.position)
	
	$MeshInstance3D.global_transform.origin = $PlayerOrigin/WorldCam/MouseCast.get_collision_point()
	$TheShadowInTheDark2.look_at(Vector3(mouseCast.get_collision_point().x,(mouseCast.get_collision_point().y + 90), mouseCast.get_collision_point().z))

	print(str($PlayerOrigin/WorldCam/MouseCast.get_collision_point()))
	print(str($MeshInstance3D.global_transform.origin))
			
#	$PlayerOrigin.transform.basis.rotate_y(0.01)

	pass
	
func _process(delta):
	#When player's health is low, the CRT_Shader gets stronger
	crt_shader.material.set_shader_parameter("crt_white_noise", 1.0 - (float(health) / float(healthmax)))


func hurt(damage):
	health -= damage
	
	print(str(damage)) #/test player functionality
	pass
