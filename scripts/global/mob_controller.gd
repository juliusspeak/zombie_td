extends Node

@export var controller: Node

@export var mob_start: Node3D
@export var mob_end: Node3D

func _ready() -> void:
	controller.game_over.connect(game_over)

func game_over() -> void:
	for c in get_children():
		c.queue_free()
func spawn(mob_scene: PackedScene) -> void:
	var mob = mob_scene.instantiate()
	add_child(mob)
	mob.global_position = mob_start.global_position
	mob.nav_agent.set_target_position(mob_end.global_position)
	mob.died.connect(controller.mob_died)
