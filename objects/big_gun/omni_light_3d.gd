extends OmniLight3D

func _process(delta: float) -> void:
	if light_energy >= 0:
		light_energy -= 30*delta
