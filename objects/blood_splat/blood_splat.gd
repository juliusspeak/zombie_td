extends Node3D


var audio: AudioStreamPlayer

func _ready() -> void:
	audio = get_node("AudioStreamPlayer")
	audio.pitch_scale = randf_range(0.8,1.2)
	audio.play()
	rotation_degrees.y = randf_range(0,180)
	await get_tree().create_timer(3).timeout
	queue_free()
func _process(delta: float) -> void:
	global_position.y -= 0.05*delta
