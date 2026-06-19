extends Node3D

@export var model: Node3D
@export var particles: Node3D

func _ready() -> void:
	await  get_tree().process_frame
	build_visuals()

func destroy_self() -> void:
	build_visuals()
	get_node("CollisionShape3D").disabled = true
	var tween = create_tween()
	var pos: Vector3 = position
	tween.tween_property(self, "position", Vector3(pos.x,pos.y-1,pos.z), 1)
	await get_tree().create_timer(1).timeout
	queue_free()
	
func build_visuals() -> void:
	var tween = create_tween()
	for p in particles.get_children():
		p.restart()
	tween.tween_property(model, "scale", Vector3(1.1,0.8,1.1), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(model, "scale", Vector3(0.8,0.8,0.8), 0.2).set_ease(Tween.EASE_OUT)
	model.rotation_degrees.y = [0,90,180,270].pick_random()
