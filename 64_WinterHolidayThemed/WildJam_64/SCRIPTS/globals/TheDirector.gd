extends Node


@onready var player_position_on_map : Vector3

@onready var player_infamy : int   #/every enemy kill +1, every fleeing enemy kill +2?

@onready var next_town_location : PackedVector3Array

@onready var current_wave : int 

@onready var enemies_to_pass : int

@onready var town_count : int

@onready var visible_cursor_pos : Vector3
