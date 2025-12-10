extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var health1: TextureRect = get_node("../CanvasLayer/HBoxContainer/Health")
@onready var health2: TextureRect = get_node("../CanvasLayer/HBoxContainer/Health2")
@onready var health3: TextureRect = get_node("../CanvasLayer/HBoxContainer/Health3")
@onready var attack_area: Area2D =$AttackArea
var in_speed_zone = false
var zone_direction = Vector2.ZERO
var zone_boost = 0.0
var damage_cooldown: float = 0.0
const DAMAGE_COOLDOWN_TIME: float = 1.0
var is_attacking: bool = false
var attack_cooldown: float = 0.0
const ATTACK_COOLDOWN_TIME: float = 0.5
var is_dead: bool = false
var is_taking_damage: bool = false
var damage_flash_timer: float = 0.0
const DAMAGE_FLASH_TIME: float = 0.3
var death_handled: bool = false

func update_health_display() -> void:
	var current_health = GameState.get_health()
	health1.visible = (current_health >= 1)
	health2.visible = (current_health >= 2)
	health3.visible = (current_health >= 3)
func _ready() -> void:
	update_health_display()
	animated_sprite.animation_finished.connect(_on_animation_finished)
func take_damage_from_enemy() -> void:
	if damage_cooldown <= 0 and not is_dead:
		GameState.take_damage(1)
		damage_cooldown = DAMAGE_COOLDOWN_TIME
		update_health_display()
		is_taking_damage = true
		damage_flash_timer = DAMAGE_FLASH_TIME
		velocity.y = -200.0
		animated_sprite.modulate = Color.RED
		
func attack() -> void:
	if is_attacking or attack_cooldown > 0 or is_dead:
		return
	is_attacking = true
	attack_cooldown = ATTACK_COOLDOWN_TIME
	animated_sprite.play("Meelee attack animation")
	if attack_area:
		attack_area.monitoring = true
		attack_area.monitorable = false
	var attack_range = 100.0
	var slimes = get_tree().get_nodes_in_group("enemies")
	if slimes.is_empty():
		var all_nodes = get_tree().get_nodes_in_group("")
		for node in get_tree().get_nodes_in_group(""):
			if node.name.begins_with("Slime"):
				slimes.append(node)
	for slime in get_tree().get_nodes_in_group(""):
		if slime.name.begins_with("Slime") or slime.name == "Slime":
			var distance = global_position.distance_to(slime.global_position)
			if distance <= attack_range:
				slime.queue_free()
				break
	if is_attacking:
		var areas = attack_area.get_overlapping_areas()
		var bodies = attack_area.get_overlapping_bodies()
		for area in areas:
			if area.name == "DamageZone":
				var slime = area.get_parent()
				if slime and slime.name == "Slime":
					slime.queue_free()
					break
		for body in bodies:
			if body.name == "Slime":
				body.queue_free()
				break
			elif body.get_parent() and body.get_parent().name == "Slime":
				body.get_parent().queue_free()
				break
func _physics_process(delta: float) -> void:
	if GameState.get_health() <= 0 and not is_dead:
		die()
	if is_dead:
		return
	if damage_cooldown > 0:
		damage_cooldown -= delta
	if attack_cooldown > 0:
		attack_cooldown -= delta
	if is_taking_damage:
		damage_flash_timer -= delta
		if damage_flash_timer <= 0:
			is_taking_damage = false
			animated_sprite.modulate = Color.WHITE
		else:
			var flash_speed = 10.0
			if int(damage_flash_timer * flash_speed) % 2 == 0:
				animated_sprite.modulate = Color.RED
			else:
				animated_sprite.modulate = Color.WHITE
	if Input.is_action_just_pressed("attack"):
		attack()
	if is_attacking and attack_area and attack_area.monitoring:
		var areas = attack_area.get_overlapping_areas()
		var bodies = attack_area.get_overlapping_bodies()
		for area in areas:
			if area.name == "DamageZone":
				var slime = area.get_parent()
				if slime and slime.name == "Slime":
					slime.queue_free()
					break
		for body in bodies:
			if body.name == "Slime":
				body.queue_free()
				break
			elif body.get_parent() and body.get_parent().name == "Slime":
				body.get_parent().queue_free()
				break
	if is_attacking and animated_sprite.animation == "Meelee attack animation":
		var current_frame = animated_sprite.frame
		var total_frames = animated_sprite.sprite_frames.get_frame_count("Meelee attack animation")
		if current_frame >= total_frames - 1:
			is_attacking = false
			attack_area.monitoring = false
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("UP") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var direction := Input.get_axis("LEFT", "RIGHT")
	if in_speed_zone:
		if direction == 0:
			velocity.x = zone_direction.x * (SPEED + zone_boost)
		else:
			velocity.x = direction * (SPEED + zone_boost)
	else:
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	move_and_slide()
	if not is_attacking and not is_dead:
		if not is_on_floor() and velocity.y > 0:
			animated_sprite.play("Falling")
		elif direction != 0 or in_speed_zone:
			animated_sprite.play("Runing")
			animated_sprite.flip_h = velocity.x < 0
		else:
			animated_sprite.play("Idle")
	if Input.is_action_just_pressed("heal"):
		if GameState.get_score() >= 10 and GameState.get_health() < 3:
			GameState.score -= 10
			GameState.heal(1)
			update_health_display()
func die() -> void:
	if is_dead:
		return
	is_dead = true
	death_handled = false
	velocity = Vector2.ZERO
	animated_sprite.modulate = Color.WHITE
	animated_sprite.play("Death")
func _on_animation_finished() -> void:
	if is_dead and animated_sprite.animation == "Death":
		death_handled = true
		await get_tree().create_timer(0.2).timeout
		get_tree().reload_current_scene()
		GameState._Reset_Score()


func _on_attack_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if is_attacking:
		if area.name == "DamageZone":
			var slime = area.get_parent()
			if slime and slime.name == "Slime":
				slime.queue_free()
