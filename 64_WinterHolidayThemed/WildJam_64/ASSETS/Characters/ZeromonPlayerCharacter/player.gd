extends CharacterBody3D

#/declerations
@onready var crt_shader = $PlayerOrigin/WorldCam/PlayerGUI/CRT_Shader/Container
@onready var playercam = $PlayerOrigin/WorldCam
#@onready var world_cursor = $Cursor

@export var PLAYERSTATS = {
	"Health" : 100,
	"HealthMax" : 100,
	"Mana" : 100,
	"Stamina" : 100,
	'WalkSpeed' : 20,
	'Damage' : 25
}

@onready var health = PLAYERSTATS.Health
@onready var healthmax = PLAYERSTATS.HealthMax
@onready var mana = PLAYERSTATS.Mana
@onready var stamina = PLAYERSTATS.Stamina
@onready var walk_speed = PLAYERSTATS.WalkSpeed
@onready var damage = PLAYERSTATS.Damage

@onready var player_hitbox = $TheShadowInTheDark2/Skeleton3D/HandAttachment/HitBox
@onready var mesh_anim = $TheShadowInTheDark2/ShadowAnimations
@onready var player_mesh = $TheShadowInTheDark2

@onready var pointer_path = preload("res://WildJam_64/UNCUTASSETS/pointer.tscn")
@onready var cursor_path = preload("res://WildJam_64/ASSETS/Toys/cursor.tscn")
@onready var cursor = cursor_path.instantiate()
@onready var old_diff : Vector3 = Vector3.ZERO
@onready var total_diff : Vector3 = Vector3.ZERO

const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


#/Functions
func _ready():
	add_to_group("Player")
	TheDirector.player_position_on_map = transform.origin
	mesh_anim.play("Idle")
	
	var pointer = pointer_path.instantiate()
	
	get_tree().get_root().add_child(cursor)
	
	for towns in TheDirector.town_count:
		$Compass.add_child(pointer)
		pointer
	
	pass


func _input(event):
#	if InputEventMouseMotion:
#		control_camera() #/ takes player mouse input for camera control
	
	if Input.is_action_just_pressed("LMB"):
		player_attack(damage) #/I need to replace green text but 2 days left on development so.. If we get to it
		await (mesh_anim.animation_finished)
	
	if Input.is_action_just_pressed('ui_end'): #/TODO: on player finishes level
		if TheDirector.player_infamy > 2:
			print("you got the lethal ending")
		else:
			print("you got the good guy ending")
		
		get_tree().quit()
	pass


func _process(delta):
	report_to_the_director()
	
	#When player's health is low, the CRT_Shader gets stronger
	crt_shader.material.set_shader_parameter("crt_white_noise", 1.0 - (float(health) / float(healthmax)))
	if velocity.z != 0:
		mesh_anim.play("Walk_Combat")
	else:
		if mesh_anim.is_playing() == false:
			mesh_anim.play("Idle")
	
	camera_control()
	$Compass.look_at(TheDirector.next_town_location[0])
#	print(str(TheDirector.next_town_location))
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
	
	
#	look_at(ScreenPointToRay(), Vector3.UP)
#	camera_control()
	move_and_slide()
	
	
	pass

func camera_control():
#	#/vars
#	var mousePos = get_viewport().get_mouse_position()
#	var camera = $PlayerOrigin/WorldCam
#	var mouseCast = $PlayerOrigin/WorldCam/MouseCast
#	var target = mouseCast.get_collision_point()
#
#	var rayOrigin = mouseCast.transform.origin
#	var rayEnd = mouseCast.target_position
#	var midpoint = rayOrigin + camera.project_ray_origin(mousePos) * rayEnd
#
#	#/syntax:
#	mouseCast.get_collision_point() #/get raycast collision location on map
#	#/TODO: update raycast endpoint rotation via mouse poistion
#
#
#	$TheShadowInTheDark2.look_at(Vector3(target)) #/player mesh looks at mouse position
#
#	print(str(mouseCast.get_collision_point())) #/test
##	$PlayerOrigin/WorldCam/MouseCast.look_at(target)
##   $PlayerOrigin.transform.basis.rotate_y(0.01)
	
	#/vars:
	var player_pos = transform.origin
	var drop_plane = Plane(Vector3(0, 1, 0), player_pos.y)
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = playercam.project_ray_origin(mouse_pos)
	var to = from + playercam.project_ray_normal(mouse_pos) * ray_length
	var cursor_pos = drop_plane.intersects_ray(from, to)
#	print("Cursor - Player: " + str(cursor_pos - player_pos))
	#/syntax
	#world_cursor.global_transform.origin = cursor_pos + Vector3(0, 1, 0)
	$TheShadowInTheDark2.look_at(cursor_pos, Vector3.UP)
	var degrees = deg_to_rad(-90)
	$TheShadowInTheDark2.rotate_y(degrees)

	cursor.transform.origin = cursor_pos + Vector3(0, 1, 0)
#	player_mesh.look_at(cursor_pos, Vector3.UP)
	
	
	pass


func report_to_the_director():
	TheDirector.player_position_on_map = global_transform.origin
	pass


func player_attack(damage):
	player_hitbox.monitoring = true
	mesh_anim.play("Lethal_Attack")
	await (mesh_anim.animation_finished)
	player_hitbox.monitoring = false
	pass


func hurt(damage):
	health -= damage
#	print(str(damage)) #/test player functionality
	
	pass




func _on_hit_box_body_entered(body):
	if body.is_in_group("Enemy"):
		body.hurt(damage)
	pass # Replace with function body.
