extends CharacterBody3D
class_name Enemy

#signal damage
@export var tool_path : Node



@export var health : int = 100
@export var damage : int = 25
@export var walk_speed: int = 1
@export var run_speed: int = 2


enum STATE {RELAXED, SCARED, SUSPICIOUS, ALERT}

@onready var state = STATE.RELAXED
var next_state
@onready var navigation_agent_3d = $NavigationAgent3D
@onready var player_pos = TheDirector.player_position_on_map
@onready var human_gibs_path = preload("res://WildJam_64/ASSETS/Toys/human_gibs.tscn")
@onready var enemy_tier = (TheDirector.player_infamy + randi_range(0, 5))

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Enemy")
	
	#/equips weapon and armor
	equip_tool() 
	
#	await (get_tree().create_timer(30.0).timeout)
	
	#/enemy navigation
	navigation_agent_3d.connect("navigation_finished", get_next_location)
	navigation_agent_3d.target_position = TheDirector.player_position_on_map
	navigation_agent_3d.get_next_path_position()
	
	#/enemy tier levels
	match enemy_tier:
		0:
			print("farmer")
		1:
			print('angry townsfolk')
		2:
			print('cop')
		3:
			print("swat")
		4:
			print("soldier")
		5:
			print("man in black")
	
#	for level in enemy_tier:
#		match level:
#			enemy_tier.0:
#				print("farmer")
#			enemy_tier == 1:
#				print('armed farmer')
#			enemy_tier[3]:
#				print('cop')
#			enemy_tier[4]:
#				print('swat')
#			enemy_tier[5]:
#				print('soldier')
	
	print(str(navigation_agent_3d.target_position), str(enemy_tier)) #/sets enemy tier based on player infamy
	
	#/
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if health < 1:
		die()
	
	
	pass


func _physics_process(delta):
	enemy_movement()
	
	
	move_and_slide()
	pass


func enemy_movement():
	var current_location = global_transform.origin
	var next_location = navigation_agent_3d.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * 5 #/walkspeed
	
	if not is_on_floor():
		velocity.y -= gravity
		print("enemy falling")
		pass
	
	velocity = velocity.move_toward(new_velocity, .25)
	
	get_next_location()
	return new_velocity


func get_next_location():
#	print('getting player location')
	navigation_agent_3d.target_position = TheDirector.player_position_on_map
	
	pass


func _on_melee_attack_radius_body_entered(body):
#	print('attack radius') #/TO-DO: check legacy code to find the proper func structure, I broke it again.  
#	#/overcomplicated it
#	if body.is_in_group("Player"):
#		if body.has_method("hurt"):
#			attack(body)
	
	if body.is_in_group("Player"):
		attack()
	
	pass

##If tool is null, the enemy is unarmed, and will act according to their character
##If tool is not null, the enemy will act depending on what tool they have.
func tool_use():

#	look_at()
	if tool_path!= null:
		pass

	if tool == null: unarmed_action()

	else:
		pass
		
func unarmed_action():
	pass
	
func set_state():
	#/if player detected etc:
	state = next_state
	#update_state()
	pass

func attack():
#	print('attacked Player')
	get_tree().call_group('Player', "hurt", damage)
	pass


func die():
	var gibs = human_gibs_path.instantiate()
	var gibbed : bool = false
	
	$MeshAndBone.visible = false
	$MeleeAttackRadius.monitoring = false
	velocity = Vector3.ZERO
	
	
	gibs.transform.origin = transform.origin #/sets gib to spawn at parent nodes location
	
	#/slo-mo
	Engine.time_scale = 0.25
#	await (get_tree().create_timer(2.0).timeout)
	if not gibbed: #/should keep enemies from turning into meat gysers
		get_tree().get_root().add_child(gibs)
		gibbed = true
		pass
	await (get_tree().create_timer(5.0))
	Engine.time_scale = 1.0
	TheDirector.player_infamy += 1
	#/TODO: if fleeing += 2 infamy
	queue_free()
	pass


func equip_tool():
	
	pass


func hurt(damage):
	health -= damage
#	print('enemy hurt: ', str(damage))
	pass
