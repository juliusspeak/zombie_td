extends RigidBody3D

@export var damage: int = 10

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	queue_free()
