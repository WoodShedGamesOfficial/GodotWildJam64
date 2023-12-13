extends RigidBody3D
class_name giblet

func _ready():
	#TODO: add a variety of functions such as apply impulse so the body parts can fling everywhere, fall down, fly upwards, etf
	explode_giblets_everywhere()
	pass
	
	
func explode_giblets_everywhere():
	apply_central_impulse(Vector3(randf_range(0.50, 2.00), randf_range(0.50, 2.00), randf_range(0.50, 2.00)))
	pass
