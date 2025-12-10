extends Control

@onready var level1_button: Button = $VBoxContainer/GridContainer/Level1Button
@onready var level2_button: Button = $VBoxContainer/GridContainer/Level2Button
@onready var level3_button: Button = $VBoxContainer/GridContainer/Level3Button
@onready var level4_button: Button = $VBoxContainer/GridContainer/Level4Button
@onready var level5_button: Button = $VBoxContainer/GridContainer/Level5Button
@onready var level6_button: Button = $VBoxContainer/GridContainer/Level6Button
@onready var level7_button: Button = $VBoxContainer/GridContainer/Level7Button
@onready var level8_button: Button = $VBoxContainer/GridContainer/Level8Button
@onready var level9_button: Button = $VBoxContainer/GridContainer/Level9Button
@onready var level10_button: Button = $VBoxContainer/GridContainer/Level10Button
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	level1_button.disabled = false
	level2_button.disabled = (GameState.max_unlocked_level < 2)
	level3_button.disabled = (GameState.max_unlocked_level < 3)
	level4_button.disabled = (GameState.max_unlocked_level < 4)
	level5_button.disabled = (GameState.max_unlocked_level < 5)
	level6_button.disabled = (GameState.max_unlocked_level < 6)
	level7_button.disabled = (GameState.max_unlocked_level < 7)
	level8_button.disabled = (GameState.max_unlocked_level < 8)
	level9_button.disabled = (GameState.max_unlocked_level < 9)
	level10_button.disabled = (GameState.max_unlocked_level < 10)
	if level2_button.disabled:
		level2_button.text = "Level 2 (Locked)"
	else:
		level2_button.text = "Level 2"
	if level3_button.disabled:
		level3_button.text = "Level 3 (Locked)"
	else:
		level3_button.text = "Level 3"
	if level4_button.disabled:
		level4_button.text = "Level 4 (Locked)"
	else:
		level4_button.text = "Level 4"
	if level5_button.disabled:
		level5_button.text = "Level 5 (Locked)"
	else:
		level5_button.text = "Level 5"
	if level6_button.disabled:
		level6_button.text = "Level 6 (Locked)"
	else:
		level6_button.text = "Level 6"
	if level7_button.disabled:
		level7_button.text = "Level 7 (Locked)"
	else:
		level7_button.text = "Level 7"
	if level8_button.disabled:
		level8_button.text = "Level 8 (Locked)"
	else:
		level8_button.text = "Level 8"
	if level9_button.disabled:
		level9_button.text = "Level 9 (Locked)"
	else:
		level9_button.text = "Level 9"
	if level10_button.disabled:
		level10_button.text = "Level 10 (Locked)"
	else:
		level10_button.text = "Level 10"

func _on_Level1Button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/Level1.tscn")


func _on_Level2Button_pressed() -> void:
		if level2_button.disabled:
			return
		get_tree().change_scene_to_file("res://scenes/Level2.tscn")


func _on_Level3Button_pressed() -> void:
		if level3_button.disabled:
			return
		get_tree().change_scene_to_file("res://scenes/Level3.tscn")


func _on_BackButton_pressed() -> void:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_Level4Button_pressed() -> void:
	if level4_button.disabled:
		return
	get_tree().change_scene_to_file("res://scenes/Level4.tscn")


func _on_Level5Button_pressed() -> void:
	if level5_button.disabled:
		return
	get_tree().change_scene_to_file("res://scenes/Level5.tscn")


func _on_Level6Button_pressed() -> void:
	if level6_button.disabled:
		return
	get_tree().change_scene_to_file("res://scenes/Level6.tscn")


func _on_Level7Button_pressed() -> void:
	if level7_button.disabled:
		return
	get_tree().change_scene_to_file("res://scenes/Level7.tscn")


func _on_Level8Button_pressed() -> void:
	if level8_button.disabled:
		return
	get_tree().change_scene_to_file("res://scenes/Level8.tscn")


func _on_Level9Button_pressed() -> void:
	if level9_button.disabled:
		return
	get_tree().change_scene_to_file("res://scenes/Level9.tscn")


func _on_Level10Button_pressed() -> void:
	if level10_button.disabled:
		return
	get_tree().change_scene_to_file("res://scenes/Level10.tscn")
