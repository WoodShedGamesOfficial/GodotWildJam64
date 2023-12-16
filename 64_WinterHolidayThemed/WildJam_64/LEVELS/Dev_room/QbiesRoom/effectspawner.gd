extends Node3D

@export
var effect_to_test : PackedScene

func _input(evt):
	if evt is InputEventKey and evt.pressed and evt.keycode == KEY_K:
		var scn = effect_to_test.instantiate()
		add_child(scn)
