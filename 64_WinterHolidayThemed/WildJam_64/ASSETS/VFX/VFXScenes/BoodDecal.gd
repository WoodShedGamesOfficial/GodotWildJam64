extends Decal

var hold_time = 2.0;
var dissolve_time = 0.5;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	await get_tree().create_timer(hold_time).timeout
	var t = create_tween()
	t.tween_property(self, "modulate", Color(0.0,0.0,0.0,0.0), dissolve_time)
	t.play()
	await t.finished
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
