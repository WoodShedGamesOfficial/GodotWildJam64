extends CharacterBody3D

#signal damage
@export var tool: Node

@export var health : int = 100
@export var damage : int = 25
@export var walk_speed: int = 1
@export var run_speed: int = 2


enum STATE {RELAXED, SCARED, SUSPICIOUS, ALERT}
@onready var state = STATE.RELAXED
var next_state

@onready var player_pos = TheDirector.player_position_on_map


# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Enemy")
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if health < 1:
		die()
	
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


func tool_use():
	
	if (tool == null):
		pass
	else:
		pass
	
	pass
	

func set_state():
	#/if player detected etc:
	state = next_state
	#update_state()
	pass

func attack():
	print('attacked Player')
	get_tree().call_group('Player', "hurt", damage)
	pass


func die():
	TheDirector.player_infamy += 1
	#/TODO: if fleeing += 2
	pass

