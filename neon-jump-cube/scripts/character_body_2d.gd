extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var health1: TextureRect = get_node("../CanvasLayer/HBoxContainer/Health")
@onready var health2: TextureRect = get_node("../CanvasLayer/HBoxContainer/Health2")
@onready var health3: TextureRect = get_node("../CanvasLayer/HBoxContainer/Health3")
@onready var attack_area: Area2D =$AttackArea
@onready var hit_sound: AudioStreamPlayer2D
@onready var heal_hint: Label = get_node_or_null("../CanvasLayer/HealHint")
@onready var damage_vignette: ColorRect = get_node("../CanvasLayer/DamageVignette")
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound
var landing_particles_scene = null
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
var camera_shake_strength: float = 0.0
var camera_shake_timer: float = 0.0
var camera_base_position: Vector2 = Vector2.ZERO
var time_slow_timer: float = 0.0
var coyote_time: float = 0.12
var coyote_timer: float = 0.0
var jump_buffer_time: float = 0.12
var jump_buffer_timer: float = 0.0
var was_on_floor: bool = false
var heal_cooldown: float = 0.0
const HEAL_COOLDOWN_TIME: float = 0.3
var original_sprite_scale: Vector2 = Vector2(0.1, 0.1)

func shake_camera(strength: float = 5.0, duration: float = 0.1) -> void:
	camera_shake_strength = strength
	camera_shake_timer = duration

func update_health_display() -> void:
	var current_health = GameState.get_health()
	health1.visible = (current_health >= 1)
	health2.visible = (current_health >= 2)
	health3.visible = (current_health >= 3)
func _ready() -> void:
	original_sprite_scale = animated_sprite.scale
	update_health_display()
	camera_base_position = $Camera2D.position
	animated_sprite.animation_finished.connect(_on_animation_finished)
	add_to_group("player")
	if ResourceLoader.exists("res://scenes/landing_dust.tscn"):
		landing_particles_scene = load("res://scenes/landing_dust.tscn")
func take_damage_from_enemy() -> void:
	if damage_cooldown <= 0 and not is_dead:
		GameState.take_damage(1)
		damage_cooldown = DAMAGE_COOLDOWN_TIME
		update_health_display()
		is_taking_damage = true
		damage_flash_timer = DAMAGE_FLASH_TIME
		velocity.y = -200.0
		animated_sprite.modulate = Color.RED
	if damage_vignette:
		var tween = create_tween()
		damage_vignette.color.a = 0.3
		tween.tween_property(damage_vignette, "color:a", 0.0, 0.3)
		if hit_sound: hit_sound.play()
		
func attack() -> void:
	if is_attacking or attack_cooldown > 0 or is_dead:
		return
	is_attacking = true
	attack_cooldown = ATTACK_COOLDOWN_TIME
	animated_sprite.play("Meelee attack animation")
	if attack_area:
		attack_area.monitoring = true
		attack_area.monitorable = false
	print("Attack starting; monitoring:", attack_area and attack_area.monitoring)
	var attack_offset_x = 40.0
	if animated_sprite.flip_h:
		attack_offset_x = -40.0
	attack_area.position = Vector2(attack_offset_x, -2)
	if attack_area:
		print("AttackArea layer:", attack_area.collision_layer, "Mask:", attack_area.collision_mask)
	var attack_range = 100.0
	var slimes = get_tree().get_nodes_in_group("enemies")
	if slimes.is_empty():
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
		print("Overlap check: area=", areas.size(), "bodies=", bodies.size())
		for area in areas:
			if area.name == "DamageZone":
				var slime = area.get_parent()
				if slime and slime.name == "Slime":
					slime.queue_free()
					break
			var a_parent = area.get_parent()
			var a_parent_name = a_parent.name if a_parent else "none"
			print(" area:", area.name, "parent:", a_parent_name)
		for body in bodies:
			if body.name == "Slime":
				body.queue_free()
				break
			elif body.get_parent() and body.get_parent().name == "Slime":
				body.get_parent().queue_free()
				break
			var b_parent = body.get_parent()
			var b_parent_name = b_parent.name if b_parent else "none"
			print(" body:", body.name, " parent:", b_parent_name)
	if hit_sound: hit_sound.play()
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
		print("Attack input fired")
		attack()
	if is_attacking and attack_area and attack_area.monitoring:
		var areas = attack_area.get_overlapping_areas()
		var bodies = attack_area.get_overlapping_bodies()
		for area in areas:
			if area.name == "DamageZone":
				var slime = area.get_parent()
				if slime and (slime.name == "Slime" or slime.name.begins_with("Slime")):
					if slime.has_method("die"):
						slime.die()
					else:
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
	if Input.is_action_just_pressed("UP"):
		jump_buffer_timer = jump_buffer_time
	if jump_buffer_timer > 0 and (is_on_floor() or coyote_timer > 0):
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		if jump_sound: jump_sound.play()
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
	if not was_on_floor and is_on_floor():
		var squash_scale = original_sprite_scale * Vector2(1.1, 0.9)
		animated_sprite.scale = squash_scale
		var tween = create_tween()
		tween.tween_property(animated_sprite, "scale", original_sprite_scale, 0.1)
	was_on_floor = is_on_floor()
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		if coyote_timer > 0:
			coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	if not is_attacking and not is_dead:
		if not is_on_floor() and velocity.y > 0:
			animated_sprite.play("Falling")
		elif direction != 0 or in_speed_zone:
			animated_sprite.play("Runing")
			if direction != 0:
				animated_sprite.flip_h = direction < 0
			
		else:
			animated_sprite.play("Idle")
	if heal_hint:
		if GameState.get_score() >= 10 and GameState.get_health() < 3:
			heal_hint.visible = true
		else:
			heal_hint.visible = false
		if heal_cooldown > 0:
			heal_cooldown -= delta
	if Input.is_action_just_pressed("heal") and heal_cooldown <= 0:
		if GameState.get_score() >= 10 and GameState.get_health() < 3:
			GameState.score -= 10
			GameState.heal(1)
			heal_cooldown = HEAL_COOLDOWN_TIME
			update_health_display()
			for heart in [health1, health2, health3]:
				if heart.visible:
					var tween = create_tween()
					tween.tween_property(heart, "modulate", Color.GREEN, 0.2)
					tween.tween_property(heart, "modulate", Color.WHITE, 0.2)
	if camera_shake_timer > 0:
		camera_shake_timer -= delta
		var shake_offset = Vector2(
			randf_range(-camera_shake_strength, camera_shake_strength),
			randf_range(-camera_shake_strength, camera_shake_strength)
		)
		$Camera2D.position = camera_base_position + shake_offset
		if camera_shake_timer <= 0:
			$Camera2D.position = camera_base_position
			camera_shake_strength = 0.0
	if time_slow_timer > 0:
		time_slow_timer -= delta
		if time_slow_timer <= 0:
			Engine.time_scale = 1.0
func die() -> void:
	if is_dead:
		return
	is_dead = true
	death_handled = false
	velocity = Vector2.ZERO
	animated_sprite.modulate = Color.WHITE
	animated_sprite.play("Death")
	if death_sound: death_sound.play()
func _on_animation_finished() -> void:
	if is_dead and animated_sprite.animation == "Death":
		death_handled = true
		var game_over_scene = load("res://scenes/game_over.tscn")
		if game_over_scene:
			var game_over = game_over_scene.instantiate()
			get_tree().current_scene.add_child(game_over)
		else:
			await get_tree().create_timer(0.2).timeout
			get_tree().reload_current_scene()
			GameState._Reset_Score()
func spawn_hit_particles(pos: Vector2) -> void:
	var spark_scene = load("res://scenes/HitSpark.tscn")
	if spark_scene:
		var spark = spark_scene.instantiate()
		get_tree().current_scene.add_child(spark)
		spark.global_position = pos
		var particles = spark.get_node("Particles")
		if particles:
			particles.emitting = true
		await get_tree().create_timer(0.5).timeout
		spark.queue_free()

func _on_attack_area_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	if not is_attacking:
		print("area_entered:", area.name, "is_attacking:", is_attacking)
		return
	if area.name == "DamageZone":
		var slime = area.get_parent()
		print("DamageZone parent:", slime.name if slime else "none")
		if slime and (slime.name == "Slime" or slime.name.begins_with("Slime")):
			print("Killing slime via area signal")
			shake_camera(8.0, 0.15)
			Engine.time_scale = 0.7
			time_slow_timer = 0.1
			if hit_sound:
				hit_sound.play()
			spawn_hit_particles(slime.global_position)
			if slime.has_method("die"):
				slime.die()
			else:
				slime.queue_free()
