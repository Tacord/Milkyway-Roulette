extends CharacterBody2D

@export var speed : float = 300.0
@export var jump_velocity : float = -750.0
@export var acceleration_rate : float = 5.0
@export var friction_rate : float  = 3.0
@export var cam_bound_y_top : float = -10000000
@export var cam_bound_y_bottom : float = 10000000
@export var cam_bound_x_left : float = -10000000
@export var cam_bound_x_right : float = 10000000

@onready var sprite : Sprite2D = $Sprite2D
@onready var jumpanimation : AnimationPlayer = $JumpAnimation
@onready var walkanimation : AnimationPlayer = $WalkAnimation
@onready var attackanimation : AnimationPlayer = $AttackAnimation
@onready var heavyanimation : AnimationPlayer = $HeavyAnimation
@onready var basicanimation : AnimationPlayer = $BasicAnimation
@onready var hurtanimation : AnimationPlayer = $HurtAnimation
@onready var camerashake : AnimationPlayer = $CameraShake
@onready var cameratransition : AnimationPlayer = $CameraTransition

@onready var jumpbuffertimer : Timer = $JumpBuffer
@onready var coyotetimetimer : Timer = $CoyoteTime
@onready var attacktimer : Timer = $AttackTimer
@onready var immunitytimer : Timer = $ImmunityTimer
@onready var pentagon : Node2D = $"../Pentagon"
@onready var healthbar : TextureProgressBar = $CanvasLayer/HealthBar
@onready var healthbarsmoothed : TextureProgressBar = $CanvasLayer/HealthBarSmooth
@onready var energybar : TextureProgressBar = $CanvasLayer/EnergyBar

var base_gravity : int = 2000
var stopped : bool = false
var gravity : int = base_gravity
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
var prevpos : Vector2 = Vector2(0,0)

func _ready():
	cameratransition.play("ready")
	$Camera2D.limit_top = cam_bound_y_top
	$Camera2D.limit_bottom = cam_bound_y_bottom
	$Camera2D.limit_right = cam_bound_x_right
	$Camera2D.limit_left = cam_bound_x_left

func _physics_process(delta):
	
	if stopped:
		velocity.x = 0
		velocity.y = 1000
	
	if not stopped:
		if energy < 100:
			energy += 25 * delta
		else:
			energy = 100
		energybar.value = energy
		if healthbarsmoothed.value > health:
			healthbarsmoothed.value -= 10 * delta
		if healthbarsmoothed.value < health:
			healthbarsmoothed.value = health
		healthbar.value = health
		
		if wasonfloor and not coyotetimestarted and not is_on_floor():
			coyotetimetimer.start()
			coyotetimestarted = true # so the timer starts only once
			coyotetime = true
	
		if Input.is_action_pressed("z"):
			speed = 75
		else:
			speed = 300
		
		if not is_on_floor():
			if pentagon.attacking == "basic":
				velocity.y = velocity.y/1.5
			else:
				velocity.y += gravity * delta
			ismoving = false
			if wasonfloor == true:
				wasonfloor = false
		else:
			gravity = base_gravity
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
	if immunity == false or damage == 2:
		hurtanimation.play("hurt")
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
			
func spikedamaged():
	damage(20,0,1)
	position = prevpos
