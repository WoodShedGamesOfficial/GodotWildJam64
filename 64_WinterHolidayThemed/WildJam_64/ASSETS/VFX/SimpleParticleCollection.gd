extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var lifetime = 0
	for c in get_children():
		lifetime = max(lifetime, c.lifetime)
		c.emitting = true
		c.one_shot = true
		c.process_material.scale_min *= get_scale().x
		c.process_material.scale_max *= get_scale().x
	await get_tree().create_timer(lifetime).timeout
	
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
