extends Node2D

@export var Pawn : PackedScene
@export var Bishop : PackedScene
@export var Knight : PackedScene
@export var Rook : PackedScene
@export var Queen : PackedScene
@export var Medkit : PackedScene

var Pawncount = [
	0,2,0,2,0,
	0,3,0,0,0,
	0,1,0,0,0,
	10,0,2,6,3,]
var Bishopcount = [
	0,0,0,0,0,
	1,2,0,0,0,
	2,1,2,0,5,
	0,0,0,0,6,]
var Knightcount = [
	0,0,1,1,2,
	0,0,0,0,0,
	0,1,2,3,0,
	0,0,0,2,0,]
var Rookcount = [
	0,0,0,0,0,
	0,0,0,0,1,
	1,1,0,1,0,
	0,0,0,0,1,]
var Queencount = [
	0,0,0,0,0,
	0,0,0,0,0,
	0,0,0,0,0,
	0,1,0,0,0,]
var Medkitcount = [
	0,0,0,0,1,
	0,0,0,0,1,
	0,0,0,0,1,
	1,0,1,0,1,
	0,0,0,0,1,]

var wave : int = -1
var totalcount : int = 0
var rng = RandomNumberGenerator.new()
var decide : int = 1

# pawn, knight, bishop, rook, queen
@export var offset : float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scorecount.is_arcade = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if scorecount.kills >= totalcount:
		wave += 1
		scorecount.kills = 0
		totalcount = Pawncount[wave] + Bishopcount[wave] + Knightcount[wave] + Rookcount[wave] + Queencount[wave]
		print(wave)
		print(totalcount)
		spawn_wave()
	
func spawn_wave():
	for i in range(0,Pawncount[wave]):
		var instance = Pawn.instantiate()
		instance.position.y = -500
		decide = rng.randi_range(1,2)
		if decide == 1:
			instance.global_position.x = rng.randf_range(-200, -500)
		else:
			instance.global_position.x = rng.randf_range(200, 500)
		var timer = get_tree().create_timer(0.5)
		await timer.timeout
		add_child(instance)
	for i in range(0,Bishopcount[wave]):
		var instance = Bishop.instantiate()
		instance.position.y = -500
		decide = rng.randi_range(1,2)
		if decide == 1:
			instance.global_position.x = rng.randf_range(-200, -500)
		else:
			instance.global_position.x = rng.randf_range(200, 500)
		var timer = get_tree().create_timer(0.5)
		await timer.timeout
		add_child(instance)
	for i in range(0,Knightcount[wave]):
		var instance = Knight.instantiate()
		instance.position.y = -500
		decide = rng.randi_range(1,2)
		if decide == 1:
			instance.global_position.x = rng.randf_range(-200, -500)
		else:
			instance.global_position.x = rng.randf_range(200, 500)
		var timer = get_tree().create_timer(0.5)
		await timer.timeout
		add_child(instance)
	for i in range(0,Rookcount[wave]):
		var instance = Rook.instantiate()
		instance.position.y = -500
		decide = rng.randi_range(1,2)
		if decide == 1:
			instance.global_position.x = rng.randf_range(-200, -500)
		else:
			instance.global_position.x = rng.randf_range(200, 500)
		var timer = get_tree().create_timer(0.5)
		await timer.timeout
		add_child(instance)
	for i in range(0,Queencount[wave]):
		var instance = Queen.instantiate()
		instance.position.y = 40
		decide = rng.randi_range(1,2)
		if decide == 1:
			instance.global_position.x = rng.randf_range(-200, -500)
		else:
			instance.global_position.x = rng.randf_range(200, 500)
		var timer = get_tree().create_timer(0.5)
		await timer.timeout
		add_child(instance)
	for i in range(0,Medkitcount[wave]):
		var instance = Medkit.instantiate()
		instance.position.y = 40
		decide = rng.randi_range(1,2)
		if decide == 1:
			instance.global_position.x = rng.randf_range(-200, -500)
		else:
			instance.global_position.x = rng.randf_range(200, 500)
		var timer = get_tree().create_timer(0.5)
		await timer.timeout
		add_child(instance)
