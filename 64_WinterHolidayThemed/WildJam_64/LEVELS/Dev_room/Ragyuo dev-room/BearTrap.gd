extends MeshInstance3D

@export var damage : int = 10

@onready var trap_sound = $Trap
@onready var break_sound = $Break
var saved_walkspeed : int


func _on_area_touch_body_entered(body):
	if body.is_in_group("Player"):
		if body.has_method("hurt"):
			body.hurt(damage)
			saved_walkspeed = body.walk_speed
			body.walk_speed = 0
			body.global_position.x = self.global_position.x
			body.global_position.z = self.global_position.z
			trap_sound.play()
			self.get_surface_override_material(0).albedo_color = Color(Color.CRIMSON)
			await get_tree().create_timer(4).timeout
			body.walk_speed = saved_walkspeed
			break_sound.play()
			await break_sound.finished
			self.queue_free()
			
