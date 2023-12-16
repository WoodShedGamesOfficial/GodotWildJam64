extends Node3D

@onready var anim = $Main_Menu/AnimationPlayer
@onready var cam_anims = $MeshInstance3D/SubViewportContainer/SubViewport/Camera3D/CamAnims

@export var Start_Scene : PackedScene
@export var personal_Dev_Room : PackedScene

@onready var scene_to_load = Start_Scene


func _ready():
#	print(scene_to_load)
	
#	cam_anims.play("panning")
#	cam_anims.ing speed_scale = 0.05
	pass


func _on_start_pressed():
	get_tree().change_scene_to_packed(Start_Scene)
	pass # Replace with function body.


func _input(event):
	if Input.is_action_just_pressed("secretButton"):
		$AudioStreamPlayer.stream = preload("res://WildJam_64/AUDIO/p-hub-intro.mp3")
		$AudioStreamPlayer.play()
		await ($AudioStreamPlayer.finished)
		get_tree().change_scene_to_packed(personal_Dev_Room)
	pass


func _on_credits_pressed():
	#/TODO: add a user scrolling credits screen w/ links to everyones bios and sites
	
#	anim.play("credits_scale")
#	await (get_tree().create_timer(15.0).timeout)
#	anim.play_backwards("credits_scale")
	pass # Replace with function body.


func _on_exit_pressed():
	$"Thank you!".visible = true
	await (get_tree().create_timer(2.0).timeout)
	get_tree().quit()
	pass # Replace with function body.


func change_scene():
	get_tree().change_scene_to_packed(scene_to_load)
	pass
