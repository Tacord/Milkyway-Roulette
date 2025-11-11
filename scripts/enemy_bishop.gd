extends CharacterBody2D

@onready var player = $"../Player"

@export var SPEED : float = 50.0
const JUMP_VELOCITY : float = -400.0
const GRAVITY : float = 900.0
var targetting : bool = false
var direction_to_player : float
var direction_x : float
@export var  health : float = 75
var facing : String = "left"
var retreat : bool = false
var cooldown : bool = false
const projectile = preload("res://scenes/bishop_projectile.tscn")

func _ready():
	$Spawn.play("spawn")

func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if targetting:
		$WalkAnimation.play("walk")
		direction_to_player = player.global_position.x - global_position.x
		direction_x = 0
		if direction_to_player > 0:
			direction_x = 1
		elif direction_to_player < 0:
			direction_x = -1
		if retreat:
			velocity.x = direction_x * -SPEED
		else:
			velocity.x = direction_x * SPEED
	else:
		$WalkAnimation.stop()
		velocity.x = lerp(velocity.x, 0.0, 0.1) # thanks gemini
	move_and_slide()

func _on_update_position_timer_timeout() -> void:
	targetting = abs(player.global_position.x - global_position.x) < 700 and abs(player.global_position.x - global_position.x) > 500 or abs(player.global_position.x - global_position.x) < 200
	if abs(player.global_position.x - global_position.x) < 200:
		retreat = true
	elif abs(player.global_position.x - global_position.x) < 500 and not cooldown:
		cooldown = true
		$AttackCooldown.start()
		retreat = false
		var instance = projectile.instantiate()
		if direction_to_player > 0:
			$AttackAnimation.play("attack")
			instance.direction = -1
			get_tree().root.add_child(instance)
			instance.global_position = global_position
		else:
			$AttackAnimation.play("attack_left")
			instance.direction = 1
			get_tree().root.add_child(instance)
			instance.global_position = global_position

func damage(damage: float, knockback : float):
	direction_to_player = player.global_position.x - global_position.x
	if direction_to_player > 0:
		velocity.x = -300 * knockback
	elif direction_to_player < 0:
		velocity.x = 300 * knockback
	targetting = false
	health -= damage
	$HealthBar.value = health
	$HealthBar.show()
	if health <= 0:
		scorecount.kills += 1
		scorecount.score += 30
		$DeathAnimation.play("death")
		await $DeathAnimation.animation_finished
		queue_free()
	# 20.1 knockback = footstool (im so smart)
	if damage == 20.01:
		$FootstoolAnimation.play("footstool")
	else:
		$HurtAnimation.play("hurt")
	$UpdatePositionTimer.stop()
	$UpdatePositionTimer.start()


func _on_hurtbox_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		body.damage(10, 1, direction_to_player)


func _on_attack_cooldown_timeout() -> void:
	cooldown = false
