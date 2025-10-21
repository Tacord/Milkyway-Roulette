extends CharacterBody2D

@onready var player = $"../Player"

const SPEED : float = 170.0
const jump_velocity : float = -450.0
const GRAVITY : float = 1000.0
var targetting : bool = false
var direction_to_player : float
var direction_x : float
var health : float = 100
var facing : String = "left"

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
		velocity.x = direction_x * SPEED
	else:
		$WalkAnimation.stop()
		velocity.x = lerp(velocity.x, 0.0, 0.1) # thanks gemini
	move_and_slide()

func _on_update_position_timer_timeout() -> void:
	targetting = abs(player.global_position.x - global_position.x) < 500 and abs(player.global_position.x - global_position.x) > 100
	if abs(player.global_position.x - global_position.x) < 270 and is_on_floor() and abs(player.global_position.x - global_position.x) >= 100:
		velocity.y = jump_velocity
	if abs(player.global_position.x - global_position.x) < 100 and is_on_floor():
		if direction_to_player > 0:
			$AttackAnimation.play("attack")
		else:
			$AttackAnimation.play("attack_left")
	if abs(player.global_position.x - global_position.x) < 50 and abs(player.global_position.y - global_position.y) < 100:
		if direction_to_player > 0:
			velocity.x = -1000
		else:
			velocity.x = 1000
		velocity.y = -300

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
		body.damage(15, 5, direction_to_player)
