extends CharacterBody3D

signal died

@export var nav_agent: NavigationAgent3D
@export var model: Node3D
@export var anim_player: AnimationPlayer
@export var blood_particle: CPUParticles3D
@export var lifebar: MeshInstance3D
@export var speed: float = 2
@export var hp: int = 100
var start_hp: int
@export var reward: int = 1
@export var mesh_for_mat: MeshInstance3D
var cover_mat: StandardMaterial3D
func _ready() -> void:
	start_hp = hp
	anim_player.speed_scale = speed/1.5
	anim_player.play("run")
	
	
	cover_mat = mesh_for_mat.get_surface_override_material(0)

func _physics_process(delta: float) -> void:
	var target = nav_agent.get_next_path_position()
	
	target.y = global_position.y
	var dir = (target - global_position).normalized()
	
	model.look_at(Vector3(target.x,0.7,target.z))
	
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed


	move_and_slide()


func _on_damage_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("bullets"):
		get_damage(body)
		body.queue_free()

func get_damage(bullet: RigidBody3D) -> void:
	hp -= bullet.damage
	blood_particle.restart()
	lifebar.visible = true
	lifebar.mesh.size.x = remap(hp,0,start_hp,0,1.5)
	
	var tween = create_tween()
	tween.tween_property(cover_mat,"albedo_color",Color.DARK_RED, 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(cover_mat,"albedo_color",Color.WHITE, 0.1).set_ease(Tween.EASE_IN)
	
	var flying_text: Label3D = load("uid://6apcfcqxjnvj").instantiate()
	flying_text.text = "-" + str(bullet.damage)
	flying_text.color = Color.RED
	get_tree().current_scene.add_child(flying_text)
	flying_text.global_position = global_position
	
	if hp <= 0:
		die()

func die() -> void:
	anim_player.stop()
	model.visible = false
	speed = 0
	
	died.emit(reward)
	
	var blood_splat = load("res://objects/blood_splat/blood_splat.tscn").instantiate()
	get_parent().add_child(blood_splat)
	blood_splat.visible = true
	blood_splat.global_position = global_position
	queue_free()
