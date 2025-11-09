extends Area2D

@onready var player = $"../Player"

var direction : float = -100
var speed : float = -200
var rng = RandomNumberGenerator.new()
var y_offset : float
var target_position : Vector2 = Vector2.ZERO

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	$Spawn.play("spawn")
	velocity = transform.x * speed
	target = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if speed < 350:
		speed += delta * 500
	else:
		speed = 350
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.limit_length(speed)
	rotation += 10 * delta
	position += velocity * delta

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * 30
	return steer

func damage(damage: float, knockback : float):
	pass

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player") and is_instance_valid($CollisionShape2D):
		body.damage(10, 1, -direction)
		queue_free()

func die():
	if is_instance_valid($CollisionShape2D):
		$Destroy.play("destroy")
		await $Destroy.animation_finished
		queue_free()

func _on_expire_timer_timeout() -> void:
	die()
