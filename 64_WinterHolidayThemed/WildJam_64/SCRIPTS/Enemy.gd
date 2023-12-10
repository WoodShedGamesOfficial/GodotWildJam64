extends Node

#signal damage
@export var health : int = 100
@export var tool: Node
@export var walk_speed: int = 1
@export var run_speed: int = 2
enum STATE {RELAXED, SCARED, SUSPICIOUS, ALERT}
@export var starting_state : STATE
var state
# Called when the node enters the scene tree for the first time.
func _ready():
	state = starting_state
	get_tree().get_node("Player").connect("damage")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func tool_use():
	if (tool == null):
		pass
	else:
		pass
		
func set_state(new_state):
	state = new_state

func damage(severity):
	health -= severity
	if (severity <= 0): die()
	
func die():
	pass
