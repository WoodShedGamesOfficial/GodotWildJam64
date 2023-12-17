extends CharacterBody3D


@onready var crt_shader = $PlayerOrigin/WorldCam/PlayerGUI/CRT_Shader/Container

@export var PLAYERSTATS = {
	"Health" : 100,
	"HealthMax" : 100,
	"Mana" : 100,
	"Stamina" : 100,
	'WalkSpeed' : 20

}

@onready var health = PLAYERSTATS.Health
@onready var mana = PLAYERSTATS.Mana
@onready var stamina = PLAYERSTATS.Stamina
@onready var walk_speed = PLAYERSTATS.WalkSpeed
@onready var sprint_speed = PLAYERSTATS.SprintSpeed
@onready var sneak_speed = PLAYERSTATS.SneakSpeed

@onready var healthmax = health
@onready var manamax = mana
@onready var staminamax = stamina
@onready var crt_shader = $PlayerOrigin/WorldCam/PlayerGUI/CRT_Shader
@onready var pause_menu = $PlayerOrigin/WorldCam/PlayerGUI/pause_menu

#Sprinting
var is_sprinting = false
var speed = walk_speed
var game_is_paused = false


const JUMP_VELOCITY = 4.5


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready():

	$PlayerOrigin/WorldCam/PlayerGUI/HealthBar.value = health
	$PlayerOrigin/WorldCam/PlayerGUI/ManaBar.value = mana
	$PlayerOrigin/WorldCam/PlayerGUI/StaminaBar.value = stamina
	pass
	

	add_to_group("Player")
	
	
	pass



func _input(event):
	if InputEventMouseMotion:
		control_camera() #/ takes player mouse input for camera control
	
	
	set_player_stats(event)
	
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		var pos = self.global_position.y
		var moveIt = Vector3((global_position.x-10),4, (global_position.z-10))
		if pos <-5:
			self.global_transform.origin = moveIt

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# Handle Sprint
	if Input.is_action_just_pressed("Toggle Sprint"):
		if stamina >= 1:
			toggle_sprint()
	
	# Handle Sneak
	if Input.is_action_just_pressed("Toggle Sneak"):
		toggle_sneak()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * walk_speed
		velocity.z = direction.z * walk_speed
#		rotation.y = atan2(-velocity.x,-velocity.z)
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
		velocity.z = move_toward(velocity.z, 0, walk_speed)
	
	# Handle Jaunt
	if Input.is_action_just_pressed("Cast"):
		jaunt()
	
	move_and_slide()
	
	
	pass


func control_camera():
	var mousePos = get_viewport().get_mouse_position()
	var camera = $PlayerOrigin/WorldCam
	var mouseCast = $PlayerOrigin/WorldCam/MouseCast
	var rayOrigin = camera.project_ray_origin(mousePos)
#	$PlayerOrigin.transform.basis.rotate_y(0.01)
	pass
	
func _process(delta):

	report_to_director()
	#When player's health is low, the CRT_Shader gets stronger
	
	#HP Regen, MP Regen, and Stamina Regen
	regen_health()
	regen_mana()
	#Sprinting drains stamina when active
	if is_sprinting:
		stamina -= 1.0
		if stamina < 1.0:
			stamina = 0.0
			stop_sprinting()
	else:
		regen_stamina()
	#Update Shader and UI
	crt_shader.material.set_shader_parameter("crt_white_noise", 1.0 - (float(health) / float(healthmax)))
	$PlayerOrigin/WorldCam/PlayerGUI/HealthBar.value = health
	$PlayerOrigin/WorldCam/PlayerGUI/ManaBar.value = mana
	$PlayerOrigin/WorldCam/PlayerGUI/StaminaBar.value = stamina
	
	
	pass
	
	

func report_to_director():
	TheDirector.player_health = health
	TheDirector.player_mana = mana
	TheDirector.player_stamina = stamina
	pass
	
func set_player_stats(event):
	if Input.is_action_just_pressed("Interact"):
		health -= 5
		mana -= 3
		stamina -= 2
	pass
	
func die():
	
	pass
	
func stop_sprinting():
	is_sprinting = false
	walk_speed = PLAYERSTATS.WalkSpeed

func toggle_sprint():
	# Check if we are sprinting, if we are, stop
	if is_sprinting:
		stop_sprinting()
	else:
		is_sprinting = true
		walk_speed = sprint_speed
	#If we aren't sprinting, start
	
	pass
	

func toggle_sneak():
		# Check if we are sneaking, if we are, stop
	
	#If we aren't sneaking, start
	
	pass
	
func regen_health():
	if health < PLAYERSTATS.Health:
		health += 1
	pass
	
func regen_mana():
	if mana < PLAYERSTATS.Mana:
		mana += 1.0
	pass
	
func regen_stamina():
	if stamina < PLAYERSTATS.Stamina:
		stamina += 1.0
	pass
	

func attack():
	
	pass
#When the player eats something, regain health, mana, and stamina
func devour():
	
	pass
	
func jaunt():
	self.position.z -= 1


	pass
	#When player's health is low, the CRT_Shader gets stronger
	#crt_shader.material.set_shader_parameter("crt_white_noise", 1.0 - (float(health) / float(healthmax)))


func hurt(damage):
	health -= damage
	pass

