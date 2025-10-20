extends CharacterBody2D

@export var speed : float = 300.0
@export var jump_velocity : float = -750.0
@export var acceleration_rate : float = 5.0
@export var friction_rate : float  = 3.0

@onready var sprite : Sprite2D = $Sprite2D
@onready var jumpanimation : AnimationPlayer = $JumpAnimation
@onready var walkanimation : AnimationPlayer = $WalkAnimation
@onready var attackanimation : AnimationPlayer = $AttackAnimation
@onready var heavyanimation : AnimationPlayer = $HeavyAnimation
@onready var basicanimation : AnimationPlayer = $BasicAnimation
@onready var jumpbuffertimer : Timer = $JumpBuffer
@onready var coyotetimetimer : Timer = $CoyoteTime
@onready var attacktimer : Timer = $AttackTimer
@onready var immunitytimer : Timer = $ImmunityTimer
@onready var pentagon : Node2D = $"../Pentagon"
@onready var dummypentagon : Node2D = $DummyPentagon
@onready var healthbar : TextureProgressBar = $CanvasLayer/HealthBar
@onready var energybar : TextureProgressBar = $CanvasLayer/EnergyBar

var gravity : int = 2000
var ismoving : bool = false
var canjump : bool = false
var coyotetime : bool = false
var coyotetimestarted : bool = false
var wasonfloor : bool = false
var direction : float = 0.0
var attacking : bool = false
var rotate_position : Vector2 = Vector2(0,0)
var health : float = 100.0
var energy : float = 100.0
var immunity : bool = false
var footstoolcount : int = 1

func _physics_process(delta):
	if energy < 100:
		energy += 20 * delta
	else:
		energy = 100
	energybar.value = energy
	healthbar.value = health
	
	if wasonfloor and not coyotetimestarted and not is_on_floor():
		coyotetimetimer.start()
		coyotetimestarted = true # so the timer starts only once
		coyotetime = true
	
	if Input.is_action_pressed("z"):
		speed = 100
	else:
		speed = 300
	
	if not is_on_floor():
		velocity.y += gravity * delta
		ismoving = false
		if wasonfloor == true:
			wasonfloor = false
	else:
		wasonfloor = true
	
	if not Input.is_action_pressed("z"):
		if ((Input.is_action_just_pressed("up") or canjump) and is_on_floor()) or (Input.is_action_just_pressed("up") and coyotetime and velocity.y > 0):
			jumpanimation.play("jump")
			velocity.y = jump_velocity
			coyotetime = false
			canjump = false
			footstoolcount = 1
		elif Input.is_action_just_pressed("up") and not is_on_floor():
			jumpbuffertimer.start()
			canjump = true
			footstoolcount = 1
	

	direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = lerp(velocity.x, direction * speed, acceleration_rate * delta)
		if is_on_floor():
			walkanimation.play("walk")
		else:
			walkanimation.pause()
	else:
		velocity.x = lerp(velocity.x, 0.0, friction_rate * delta)
		walkanimation.stop()

	move_and_slide()


func _on_jump_buffer_timeout() -> void:
	canjump = false

func _on_coyote_time_timeout() -> void:
	coyotetime = false
	coyotetimestarted = false

func _on_attack_timer_timeout() -> void:
	attacking = false

func damage(damage : float, knockback : float, facing : float):
	if immunity == false:
		immunitytimer.start()
		immunity = true
		health -= damage
		if health <= 0:
			pass
		if facing > 0:
			velocity.x = 100 * knockback
		elif facing < 0:
			velocity.x = -100 * knockback

func _on_immunity_timer_timeout() -> void:
	immunity = false


func _on_footstool_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Goon"):
		if footstoolcount < 4:
			body.damage(20.01, 3.1 * footstoolcount)
			velocity.y = jump_velocity / footstoolcount
			footstoolcount += 1
			body.velocity.y += 500
		else:
			damage(5,10,1)
			velocity.y = 1000
