extends CharacterBody2D

@onready var player = $"../Player"

@export var  SPEED : float = 50.0
const JUMP_VELOCITY : float = -400.0
const GRAVITY : float = 900.0
var targetting : bool = false
var direction_to_player : float
var direction_x : float
var health : float = 50
var facing : String = "left"
var shieldhealth : float = 100
var inside : bool = false

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
		velocity.x = direction_x * SPEED
	else:
		$WalkAnimation.stop()
		velocity.x = lerp(velocity.x, 0.0, 0.1) # thanks gemini
	move_and_slide()

func _on_update_position_timer_timeout() -> void:
	targetting = abs(player.global_position.x - global_position.x) < 500 and abs(player.global_position.x - global_position.x) > 100 and abs(player.global_position.y - global_position.y) < 300
	if inside:
		direction_to_player = player.global_position.x - global_position.x
		player.damage(5,20,direction_to_player)
	if abs(player.global_position.x - global_position.x) < 100:
		if direction_to_player > 0:
			$AttackAnimation.play("attack")
		else:
			$AttackAnimation.play("attack_left")

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
		scorecount.score += 50
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


func _on_shield_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		inside = true
		direction_to_player = player.global_position.x - global_position.x
		body.damage(5,10,direction_to_player)


func _on_shield_area_entered(area: Area2D) -> void:
	if area.is_in_group("Pentagon"):
		if area.attacking != "none":
			area.attacking = "none"
			$Shield/ShieldBar.show()
			shieldhealth -= 15
			if shieldhealth <= 0:
				$ShieldDestroyAnimation.play("shieldbreak")
				$Shield/CollisionShape2D.queue_free()
				$Shield/ShieldBar.value = 0
				await $ShieldDestroyAnimation.animation_finished
				$Shield.queue_free()
			else:
				$ShieldDamage.play("shielddamage")
		$Shield/ShieldBar.value = shieldhealth


func _on_shield_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		inside = false
