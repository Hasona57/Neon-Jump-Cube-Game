extends Node

var max_unlocked_level: int = 1
const SAVE_PATH := "user://save.cfg"

var score = 0
var player_health: int = 3

func _Reset_Score():
	score = 0
	reset_health()

func get_score() -> int:
	return score

func _process(_delta):
	if Input.is_action_just_pressed('Exit'):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func add_point():
	score += 1

func _ready() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err == OK:
		max_unlocked_level = int(cfg.get_value("progress","max_unlocked_level", 1))
	else:
		max_unlocked_level= 1
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
func unlock_level(level_index: int) -> void:
	if level_index > max_unlocked_level:
		max_unlocked_level = level_index
		_save_progress()
func _save_progress() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "max_unlocked_level", max_unlocked_level)
	cfg.save(SAVE_PATH)
func take_damage(amount: int = 1) -> void:
	player_health -= amount
	if player_health < 0:
		player_health = 0 
func heal(amount: int = 1) -> void:
	if player_health < 3:
		player_health += amount
		if player_health > 3:
			player_health = 3
func get_health() -> int:
	return player_health
func reset_health() -> void:
	player_health = 3
