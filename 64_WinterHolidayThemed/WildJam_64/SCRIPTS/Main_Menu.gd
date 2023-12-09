extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	$ButtonContainer/Start.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed():
	#get_tree().change_scene_to_file("res://WildJam_64/LEVELS/Dev_room/Dev_Room.tscn")
	pass # Replace with function body.


func _on_options_pressed():
	pass


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://WildJam_64/LEVELS/Credits/Credits.tscn")
	pass # Replace with function body.


func _on_exit_pressed():
	get_tree().quit()
