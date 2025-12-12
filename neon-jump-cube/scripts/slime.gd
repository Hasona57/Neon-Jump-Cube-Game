extends Node2D

const SPEED = 60
var direction = 1
var is_dead = false
var state = "patrol"
var home_position = Vector2.ZERO
var chase_radius = 200.0

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var damage_zone: Area2D = $DamageZone

var player: Node2D = null

func _ready() -> void:
	home_position = global_position
	add_to_group("enemies")
	ray_cast_left.collision_mask = 1
	ray_cast_right.collision_mask = 1
	ray_cast_left.exclude_parent = true
	ray_cast_right.exclude_parent = true
	
	player = get_tree().get_first_node_in_group("player")
	if not player:
		player = get_tree().get_first_node_in_group("Player")

func _process(delta: float) -> void:
	if is_dead:
		return
		
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if not player:
			player = get_tree().get_first_node_in_group("Player")
		if not player:
			return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	var distance_to_home = global_position.distance_to(home_position)
	if distance_to_player < chase_radius:
		state = "chase"
		var dir_to_player = (player.global_position - global_position).normalized()
		direction = 1 if dir_to_player.x > 0 else -1
		animated_sprite.flip_h = direction < 0
	elif distance_to_home > 50.0:
		state = "return"
		var dir_to_home = (home_position - global_position).normalized()
		direction = 1 if dir_to_home.x > 0 else -1
		animated_sprite.flip_h = direction < 0
	else:
		state = "patrol"
	if state == "patrol":
		if ray_cast_left.is_colliding():
			var collider_left = ray_cast_left.get_collider()
			if collider_left and not (collider_left is CharacterBody2D and collider_left.name == "CharacterBody2D") and not collider_left.is_in_group("player"):
				direction = 1
				animated_sprite.flip_h = true
		if ray_cast_right.is_colliding():
			var collider_right = ray_cast_right.get_collider()
			if collider_right and not (collider_right is CharacterBody2D and collider_right.name == "CharacterBody2D") and not collider_right.is_in_group("player"):
				direction = -1
				animated_sprite.flip_h = false
	position.x += direction * SPEED * delta
func die() -> void:
	if is_dead:
		return
	is_dead = true
	if damage_zone:
		damage_zone.monitoring = false
	if ray_cast_left:
		ray_cast_left.enabled = false
	if ray_cast_right:
		ray_cast_right.enabled = false
	animated_sprite.play("death")
	await animated_sprite.animation_finished
	queue_free()
