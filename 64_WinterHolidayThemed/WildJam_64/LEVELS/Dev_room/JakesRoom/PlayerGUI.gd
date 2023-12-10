extends Control

#@onready var max_health = TheDirector.player_health
#@onready var max_mana = TheDirector.player_mana
#@onready var max_stamina = TheDirector.player_stamina
#@onready var health = max_health
#@onready var mana = max_mana
#@onready var stamina = max_stamina
#
#var current_health
#var current_mana
#var current_stamina
#
## Called when the node enters the scene tree for the first time.
#func _ready():
#	current_health = max_health
#	current_mana = max_mana
#	current_stamina = max_stamina
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	$HealthBar.value = current_health
#	$ManaBar.value  = current_mana
#	$StaminaBar.value = current_stamina
#	pass
#
#
#func _input(event):
##	if Input.is_action_just_pressed("Interact"):
##		current_health += 5
##		current_mana += 3
##		current_stamina += 2
#	pass
