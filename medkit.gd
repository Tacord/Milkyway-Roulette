extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Spawn.play("spawn")
	await $Spawn.animation_finished
	$CollisionShape2D.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func use():
	$AudioStreamPlayer.play()
	$CollisionShape2D.queue_free()
	$Use.play("use")
	$UseParticle.emitting = true
	await $Use.animation_finished
	queue_free()

func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		body.cameratransition.play("heal")
		body.health += 50
		if body.health > 100:
			body.health = 100
		use()
