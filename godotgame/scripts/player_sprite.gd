extends Sprite2D

@export var angle = 0

func _process(_delta: float) -> void:
	angle = get_angle_to(get_global_mouse_position())
	
	if cos(angle) < 0:
		scale.x = floor(cos(angle))
	else:
		scale.x = ceil(cos(angle))
