extends Node

@onready var label: Label = $Label
var score = 0

func _process(_delta):
	if Input.is_action_just_pressed('Exit'):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func add_point():
	score += 1
	label.text = "Congratulation you collected " + str(score) + " amount of Money"


func _on_goal_area_body_entered(body: Node2D) -> void:
	get_tree().change_scene_to_file("res://scenes/level_win.tscn")
