extends Control

##@onready var max_health = TheDirector.player_health
##@onready var max_mana = TheDirector.player_mana
##@onready var max_stamina = TheDirector.player_stamina
##@onready var health = max_health
##@onready var mana = max_mana
##@onready var stamina = max_stamina
#@onready var pause_menu = $pause_menu
#
##
##var current_health
##var current_mana
##var current_stamina
#var paused = false
##
### Called when the node enters the scene tree for the first time.
#func _ready():
#
#	pass # Replace with function body.
##
##
### Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if Input.is_action_just_pressed("pause_game"):
#		toggle_pause_menu()
#	pass
##
##
#func toggle_pause_menu():
#	if paused:
#		pause_menu.hide()
#	else:
#		pause_menu.show
