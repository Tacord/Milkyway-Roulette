extends Area2D

var player : CharacterBody2D
var running : bool = true
var inside : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("c") and inside:
		running = false
		player.cameratransition.play("transition")
		player.stopped = true
		$Use.play("use")
		$AnimationPlayer.play("disappear_2")
		$Prompt.hide()


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player") and running:
		inside = true
		$AnimationPlayer.play("appear")
		player = body

func _on_body_exited(body: CharacterBody2D) -> void:
	if body.is_in_group("Player") and running:
		inside = false
		$AnimationPlayer.play("disappear")
		player = body
