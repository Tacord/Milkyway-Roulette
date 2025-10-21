extends Area2D

var direction : float = -1
var speed : float = 200
var rng = RandomNumberGenerator.new()
var y_offset : float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	y_offset = rng.randf_range(-50, 25)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += 10 * delta
	if direction == -1:
		position.x += delta * speed
	else:
		position.x -= delta * speed
	position.y += y_offset * delta

func damage(damage: float, knockback : float):
	$CollisionShape2D.queue_free()
	$Destroy.play("destroy")
	await $Destroy.animation_finished
	queue_free()

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		$CollisionShape2D.queue_free()
		body.damage(10, 2, -direction)
		$Destroy.play("destroy")
		queue_free()

func _on_expire_timer_timeout() -> void:
	damage(1,1)
