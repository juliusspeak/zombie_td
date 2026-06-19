extends Label3D

@export var color: Color

func _ready() -> void:
	modulate = color
	
	await get_tree().create_timer(1).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	global_position.y += 3*delta
	font_size -= 1
