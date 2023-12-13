extends Node
class_name Tool

##If this number is less than or equal to 0, then it is not a combat tool, and is_combat_tool() will return false.
@export var damage : int = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func is_combat_tool():
	return (damage <= 0)

func action():
	pass
