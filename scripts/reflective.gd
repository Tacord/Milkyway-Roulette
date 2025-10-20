@tool
extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_zoom_changed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_zoom_changed()

func _zoom_changed():
	material.set_shader_parameter("y_zoom", get_viewport_transform().get_scale().y)
	
