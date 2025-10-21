extends Area2D

@onready var player = $"../Player"
@onready var trail = $"../Trail"
@onready var cooldowntimer = $AttackCooldown
@onready var combotimer = $ComboTimer
@onready var heavycooldowntimer = $HeavyAttackCooldown
@onready var heavyattacktimer = $HeavyAttackTimer
@onready var basicattacktimer = $BasicAttackTimer
@onready var heavyparticle = $HeavyParticle
@onready var basicparticle = $BasicParticle

var speed: float = 20
var offset: Vector2 = Vector2(60, 15)
var attacking : String = "none"
var attacktargetposition : Vector2 = Vector2(0,0)
var targetposition: Vector2
var didinput : bool = false
var combo : int = 0
var cooldown : bool = false
#var currenttrail : Trail

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Sprite2D.rotation += 2 * delta
	
	if Input.is_action_pressed("z") and not cooldown:
		combo += 1
		if cooldowntimer.is_stopped():
			cooldowntimer.start()
		cooldown = true
		combotimer.stop()
		combotimer.start() # to reset the timer
		basic_attack()
	
	if Input.is_action_pressed("x") and not cooldown and player.energy >= 50:
		if heavycooldowntimer.is_stopped():
			heavycooldowntimer.start()
		cooldown = true
		heavy_attack()

	if player.direction == 1:
		offset = Vector2(60, 15)
	elif player.direction == -1:
		offset = Vector2(-60, 15)
	targetposition = player.position - offset
	
	if attacking == "none":
		position = position.lerp(targetposition, speed * delta)
	else:
		position = position.lerp(attacktargetposition, speed * delta)

func heavy_attack():
	heavyparticle.emitting = true
	player.energy -= 50
	attacking = "heavy"
	trail.show()
	player.heavyanimation.play("heavy")
	trail.maxlength = 0.05 * Engine.get_frames_per_second()
	if heavyattacktimer.is_stopped():
		heavyattacktimer.start()
	attacktargetposition.y = player.position.y - 15
	attacktargetposition.x = player.position.x
	
	speed = 5
	scale = Vector2(2,2)
	
	var input_direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("right"):
		input_direction.x += 1
		player.velocity.x = -1000
	if Input.is_action_pressed("left"):
		input_direction.x -= 1
		player.velocity.x = 1000
	if Input.is_action_pressed("up"):
		input_direction.y -= 1
		player.velocity.y = 800
	if Input.is_action_pressed("down"):
		input_direction.y += 1
		player.velocity.y = -800
	
	if input_direction.length() > 0:
		var normalized_direction: Vector2 = input_direction.normalized()
		var attack_offset: Vector2 = normalized_direction * 250
		attacktargetposition.y = player.global_position.y + attack_offset.y - 15
		attacktargetposition.x = player.global_position.x + attack_offset.x
		didinput = true
	else:
		didinput = false
	
	if not didinput:
		if offset == Vector2(60, 15):
			attacktargetposition.x = player.position.x + 250
			player.velocity.x = -800
		else:
			attacktargetposition.x = player.position.x - 250
			player.velocity.x = 800
	didinput = false
	if combo >= 3:
		combo = 0

func basic_attack():
	basicparticle.emitting = true
	attacking = "basic"
	player.basicanimation.play("basic")
	trail.maxlength = 0.04 * Engine.get_frames_per_second()
	trail.show()
	#make_trail()
	if basicattacktimer.is_stopped():
		basicattacktimer.start()
	attacktargetposition.y = player.position.y - 15
	attacktargetposition.x = player.position.x
	
	var input_direction: Vector2 = Vector2.ZERO

	if Input.is_action_pressed("left"):
		input_direction.x -= 1
	if Input.is_action_pressed("right"):
		input_direction.x += 1
	if Input.is_action_pressed("up"):
		input_direction.y -= 1
	if Input.is_action_pressed("down"):
		input_direction.y += 1
	
	if input_direction.length() > 0:
		var normalized_direction: Vector2 = input_direction.normalized()
		var attack_offset: Vector2 = normalized_direction * 200
		attacktargetposition.y = player.global_position.y + attack_offset.y - 15
		attacktargetposition.x = player.global_position.x + attack_offset.x
		didinput = true
	else:
		didinput = false
	
	if not didinput:
		if offset == Vector2(60, 15):
			attacktargetposition.x = player.position.x + 200
		else:
			attacktargetposition.x = player.position.x - 200
	didinput = false
	if combo >= 3:
		combo = 0

func _on_basic_attack_timer_timeout() -> void:
	trail.hide()
	attacking = "none"
	speed = 20
	scale = Vector2(1,1)
	trail.maxlength = 0.04 * Engine.get_frames_per_second()
	

func _on_heavy_attack_timer_timeout() -> void:
	trail.hide()
	attacking = "none"
	speed = 20
	scale = Vector2(1,1)
	trail.maxlength = 0.04 * Engine.get_frames_per_second()

func _on_attack_cooldown_timeout() -> void:
	cooldown = false


func _on_combo_timer_timeout() -> void:
	combo = 0

func _on_heavy_attack_cooldown_timeout() -> void:
	cooldown = false


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Goon"):
		match attacking:
			"basic":
				body.damage(15, 0.5)
			"heavy":
				body.damage(30, 2)


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Goon"):
		match attacking:
			"basic":
				area.damage(15, 1)
			"heavy":
				area.damage(30, 2)
