extends Area2D

@export var Pawn : PackedScene
@export var Bishop : PackedScene
@export var Knight : PackedScene
@export var Rook : PackedScene
@export var Pawncount : int = 0
@export var Bishopcount : int = 0
@export var Knightcount : int = 0
@export var Rookcount : int = 0
@export var offset : float = -200

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: CharacterBody2D) -> void:
	if body.is_in_group("Player"):
		$CollisionShape2D.queue_free()
		for i in range(0,Pawncount):
			var instance = Pawn.instantiate()
			instance.position = global_position
			instance.position.x += offset
			var timer = get_tree().create_timer(0.5)
			await timer.timeout
			get_parent().add_child(instance)
		for i in range(0,Bishopcount):
			var instance = Bishop.instantiate()
			instance.position = global_position
			instance.position.x += offset
			var timer = get_tree().create_timer(0.5)
			await timer.timeout
			get_parent().add_child(instance)
		for i in range(0,Knightcount):
			var instance = Knight.instantiate()
			instance.position = global_position
			instance.position.x += offset
			var timer = get_tree().create_timer(0.5)
			await timer.timeout
			get_parent().add_child(instance)
		for i in range(0,Rookcount):
			var instance = Rook.instantiate()
			instance.position = global_position
			instance.position.x += offset
			var timer = get_tree().create_timer(0.5)
			await timer.timeout
			get_parent().add_child(instance)
		queue_free()
		
