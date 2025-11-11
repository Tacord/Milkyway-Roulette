extends CharacterBody2D

@onready var player = $"../Player"
const projectile = preload("res://scenes/queen_projectile.tscn")
const bladeprojectile = preload("res://scenes/queen_blade_projectile.tscn")

@export var  SPEED : float = 100.0
const JUMP_VELOCITY : float = -400.0
var GRAVITY : float = 900.0
var targetting : bool = false
var direction_to_player : float
var direction_x : float
@export var health : float = 1000
var facing : String = "left"
var targetting_x : float = 0
var dashing : float = 0
var projectile_attacking : bool = false
var target_pos : Vector2 = Vector2(0,0)
var rng = RandomNumberGenerator.new()
var decide : int = 0
var spawning = true

func _ready():
	player.camerashake.play("queenintro")
	$Hurtbox.monitoring = false
	$SpawnAnimation.play("spawn")
	await $SpawnAnimation.animation_finished
	spawning = false
	$Hurtbox.monitoring = true
	dash_attack()

func _physics_process(delta: float) -> void:
	
	if $Overlay/CanvasLayer/HealthBarSmooth.value > health:
		$Overlay/CanvasLayer/HealthBarSmooth.value -= 40 * delta
	if $Overlay/CanvasLayer/HealthBarSmooth.value < health:
		$Overlay/CanvasLayer/HealthBarSmooth.value = health
	
	if projectile_attacking:
		target_pos.x = player.position.x
		target_pos.y = -300
		position = position.lerp(target_pos, 1 * delta)
	
	if dashing != 0:
		velocity.x += dashing * 5000 * delta
		
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	#if targetting:
		#$WalkAnimation.play("walk")
		#direction_to_player = player.global_position.x - global_position.x
		#direction_x = 0
		#if direction_to_player > 0:
			#direction_x = 1
		#elif direction_to_player < 0:
			#direction_x = -1
		#velocity.x = direction_x * SPEED
	#else:
		#$WalkAnimation.stop()
		#velocity.x = lerp(velocity.x, 0.0, 0.1) # thanks gemini
	move_and_slide()

func dash_attack():
	for i in range(2):
		direction_to_player = player.global_position.x - global_position.x
		direction_x = 1
		$DashSound.play()
		player.camerashake.play("heavy")
		if direction_to_player > 0:
			targetting_x = 1
			$DashAttack.play("dash_warning")
		elif direction_to_player < 0:
			targetting_x = -1
			$DashAttack.play("dash_warning_left")
		await $DashAttack.animation_finished
		$DotParticle.emitting = true
		dashing = targetting_x
		await get_tree().create_timer(0.5).timeout
		$DotParticle.emitting = false
		velocity.x = 0
		dashing = 0
		if targetting_x == 1:
			$DashAttack.play("slip")
		elif targetting_x == -1:
			$DashAttack.play("slip_left")
	$AttackTimer.start()

func projectile_attack():
	$Vanish.play("vanish_appear")
	GRAVITY = 0
	await get_tree().create_timer(0.5).timeout
	position.y = -300
	projectile_attacking = true
	await get_tree().create_timer(0.5).timeout
	for i in range(20):
		var y_offset = rng.randf_range(-200, -50)
		var x_offset = rng.randf_range(-200, 200)
		var instance = projectile.instantiate()
		get_parent().add_child(instance)
		instance.global_position.x = global_position.x + x_offset
		instance.global_position.y = global_position.y + y_offset
		await get_tree().create_timer(0.05).timeout
	$ProjectileSound.play()
	$AttackTimer.start()
	
func blade_attack():
	velocity.y = 1000
	for i in range(2):
		$HomingBladeAttack.play("blade")
		await $HomingBladeAttack.animation_finished
		player.camerashake.play("heavy")
		var instance = bladeprojectile.instantiate()
		get_parent().add_child(instance)
		instance.global_position.x = global_position.x
		instance.global_position.y = global_position.y - 100
	$AttackTimer.start()
	

func _on_update_position_timer_timeout() -> void:
	targetting = abs(player.global_position.x - global_position.x) < 500 and abs(player.global_position.x - global_position.x) > 100 and abs(player.global_position.y - global_position.y) < 300

func damage(damage: float, knockback : float):
	if not spawning:
		direction_to_player = player.global_position.x - global_position.x
		targetting = false
		health -= damage
		$Overlay/CanvasLayer/HealthBar.value = health
		$Overlay/CanvasLayer/HealthBar.show()
		if health <= 0:
			scorecount.kills += 1
			scorecount.score += 90
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
		if dashing != 0:
			body.damage(10, 20, direction_to_player)
		else:
			body.damage(10, 1, direction_to_player)


func _on_attack_timer_timeout() -> void:
	projectile_attacking = false
	decide = randi_range(1,3)
	targetting = false
	GRAVITY = 900
	match decide:
		2:
			projectile_attack()
		1:
			dash_attack()
		3:
			blade_attack()
