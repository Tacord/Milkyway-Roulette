extends Area2D

@onready var player = $"../Player"

var direction : float = -1
var speed : float = -100
var rng = RandomNumberGenerator.new()
var y_offset : float
var target_position : Vector2 = Vector2.ZERO

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	rng.randomize()
	$AudioStreamPlayer.pitch_scale = rng.randf_range(0.7,1.3)
	$AudioStreamPlayer.play()
	$Spawn.play("spawn")
	velocity = transform.x * speed
	target = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.limit_length(speed)
	rotation = velocity.angle()
	position += velocity * delta
	position.y += speed * delta
	speed += 200 * delta
	if global_position.y > 100:
		die()

func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * 1000
	return steer

func damage(damage: float, knockback : float):
	pass

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player") and is_instance_valid($CollisionShape2D):
		$CollisionShape2D.queue_free()
		body.damage(2, 1, -direction)
		$Destroy.play("destroy")
		queue_free()

func die():
	if is_instance_valid($CollisionShape2D):
		$CollisionShape2D.queue_free()
		$Destroy.play("destroy")
		await $Destroy.animation_finished
		queue_free()

func _on_expire_timer_timeout() -> void:
	die()
