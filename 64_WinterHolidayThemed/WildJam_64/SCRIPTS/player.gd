extends Node

@export var health : int = 50
@export var healthMax : int = 100
@export var mana : int = 50
@export var manaMax : int = 100

var growth_rate : float = 0.5
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_lit_up():
		growth_rate += delta
		if (growth_rate > 1):
			growth_rate = 0.5
			if (health < healthMax):
				health += 1
			else:
				health = healthMax
			if (mana > 0):
				mana -= 1
			else:
				mana = 0
	else:
		growth_rate -= delta
		if (growth_rate < 0):
			growth_rate = 0.5
			if (health > 1):
				health -= 1
			else:
				die()
			if (mana < manaMax):
				mana += 1
			else:
				mana = manaMax

func is_lit_up():
	pass
	
func die():
	pass
