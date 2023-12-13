extends CharacterBody3D
@onready var crt_shader = $PlayerOrigin/WorldCam/PlayerGUI/CRT_Shader/Container

@export var PLAYERSTATS = {
	"Health" : 100,
	"HealthMax" : 100,
	"Mana" : 100,
	"Stamina" : 100,
	"WalkSpeed" : 20,
	"Damage" : 25,
}

@onready var health = PLAYERSTATS.Health
@onready var healthmax = PLAYERSTATS.HealthMax
@onready var mana = PLAYERSTATS.Mana
@onready var stamina = PLAYERSTATS.Stamina
@onready var walk_speed = PLAYERSTATS.WalkSpeed
@onready var damage = PLAYERSTATS.Damage


const JUMP_VELOCITY = 4.5


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():
	add_to_group("Player")
	$PlayerOrigin/WorldCam/MouseCast.target_position.z = -2000
	
	pass


func _input(event):
#	if InputEventMouseMotion:
#		control_camera() #/ takes player mouse input for camera control
	
	if Input.is_action_just_pressed("LMB"):
		player_attack(damage) #/I need to replace green text but 2 days left on development so.. If we get to it
		await ($TheShadowInTheDark2/ShadowAnimations.animation_finished)
	
	if Input.is_action_just_pressed('ui_end'): #/TODO: on player finishes level
		if TheDirector.player_infamy > 2:
			print("you got the lethal ending")
		else:
			print("you got the good guy ending")
		
		get_tree().quit()
	pass

func player_attack(damage):
	$TheShadowInTheDark2/Skeleton3D/BoneAttachment3D/HitBox.monitoring = true
	$TheShadowInTheDark2/ShadowAnimations.play("Lethal_Attack")
	await ($TheShadowInTheDark2/ShadowAnimations.animation_finished)
	$TheShadowInTheDark2/Skeleton3D/BoneAttachment3D/HitBox.monitoring = false
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
		rotation.y = atan2(-velocity.x,-velocity.z)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
	
	
	
	move_and_slide()
	
	control_camera()
	
	pass


func control_camera():
	#var mousePos = get_viewport().get_mouse_position()
	#var camera = $PlayerOrigin/WorldCam
	#var mouseCast = $PlayerOrigin/WorldCam/MouseCast
	#var rayOrigin = mouseCast.transform.origin
	#var rayEnd = rayOrigin + camera.project_ray_normal(mousePos) * 1000
	
	#mouseCast.target_position = rayEnd
	
	#var testMesh = $MouseMesh
	#testMesh.transform.position = mouseCast.get_collision_point()
#	$PlayerOrigin.transform.basis.rotate_y(0.01)
	#$TheShadowInTheDark2.look_at(Vector3(mouseCast.get_collision_point()), Vector3.UP)
	pass
	
	#/vars:
	var playercam = $PlayerOrigin/WorldCam
	#var world_cursor = $MouseMesh
	var player_pos = global_transform.origin
	var drop_plane = Plane(Vector3(0, 1, 0), player_pos.y)
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = playercam.project_ray_origin(mouse_pos)
	var to = from + playercam.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos = drop_plane.intersects_ray(from, to)
	
	
	#/syntax
	#world_cursor.global_transform.origin = cursor_pos + Vector3(0, 1, 0)
	$TheShadowInTheDark2.look_at(cursor_pos, Vector3.UP)
	var degrees = deg_to_rad(-90)
	$TheShadowInTheDark2.rotate_y(degrees)
	
func _process(delta):
	#When player's health is low, the CRT_Shader gets stronger
	crt_shader.material.set_shader_parameter("crt_white_noise", 1.0 - (float(health) / float(healthmax)))


func hurt(damage):
	health -= damage
	pass
