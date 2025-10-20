extends Line2D

var queue : Array
var maxlength : int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	maxlength = 100
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $"../Pentagon".attacking == "none":
		maxlength = 0.04 * Engine.get_frames_per_second()
		
	queue.push_front($"../Pentagon".position)
	
	if queue.size() > maxlength:
		queue.pop_back()
		
	clear_points()
	
	for point in queue:
		add_point(point)

#class_name Trail
#extends Line2D
#
#var maxlength : int = 100
#@onready var curve := Curve2D.new()
#
#func _process(delta:float):
	#curve.add_point(get_parent().position)
	#if curve.get_baked_points().size() > maxlength:
		#curve.remove_point(0)
	#points = curve.get_baked_points()
#
#func stop():
	#set_process(false)
	#var tw := get_tree().create_tween()
	#tw.tween_property(self, "modulate:a", 0.0, 3.0)
	#await tw.finished
	#queue_free()
	#
#static func create() -> Trail:
	#var scn = preload("res://scenes/trail.tscn")
	#return scn.instantiate()
