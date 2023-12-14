extends Node3D

@onready var main_menu = preload("res://WildJam_64/LEVELS/Main_Menu/MainMenu3D.tscn")


func _ready():
#	await (get_tree().create_timer(5.0).timeout)
	$Geometry/NavigationRegion3D.bake_navigation_mesh()
	print("Ding, done baking")
	pass

func _input(event):
	if Input.is_action_just_pressed('ui_end'):
		get_tree().change_scene_to_packed(main_menu)
	pass

#/TODO: fill in basic level functionality i.e: any gameplay tweaks, etc that the player would use in final build
