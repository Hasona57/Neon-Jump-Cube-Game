extends Node

var max_unlocked_level: int = 1
var best_time: Dictionary = {}
var coins_collected: Dictionary = {}
var level_start_time: int = 0
var coins_this_run: int = 0
var current_level_name: String = ""
const SAVE_PATH := "user://save.cfg"

var score = 0
var player_health: int = 3

func _Reset_Score():
	score = 0
	reset_health()

func get_score() -> int:
	return score

func _process(_delta):
	pass
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
func start_level(level_name: String) -> void:
	current_level_name = level_name
	level_start_time = Time.get_ticks_msec()
	coins_this_run = 0
func finish_level() -> void:
	if current_level_name == "":
		return
	var elapsed = Time.get_ticks_msec() - level_start_time
	var elapsed_seconds = elapsed / 1000.0
	if not best_time.has(current_level_name) or elapsed_seconds < best_time[current_level_name]:
		best_time[current_level_name] = elapsed_seconds
	if not coins_collected.has(current_level_name) or coins_this_run > coins_collected[current_level_name]:
		coins_collected[current_level_name] = coins_this_run
func get_best_time(level_name: String) -> float:
	if best_time.has(level_name):
		return best_time[level_name]
	return -1.0
func get_coins_collected(level_name: String) -> int:
	if coins_collected.has(level_name):
		return coins_collected[level_name]
	return 0
