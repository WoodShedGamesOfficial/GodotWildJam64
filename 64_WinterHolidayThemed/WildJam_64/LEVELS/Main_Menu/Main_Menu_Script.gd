extends Control

@onready var anim = $AnimationPlayer

@export var Start_Scene : PackedScene
@onready var scene_to_load = Start_Scene


func _ready():
	print(scene_to_load)
	pass


func _on_start_pressed():
	change_scene()
	pass # Replace with function body.


func _on_credits_pressed():
	anim.play("credits_scale")
	await (get_tree().create_timer(15.0).timeout)
	anim.play_backwards("credits_scale")
	pass # Replace with function body.


func _on_exit_pressed():
	pass # Replace with function body.


func change_scene():
	get_tree().change_scene_to_packed(scene_to_load)
	pass
