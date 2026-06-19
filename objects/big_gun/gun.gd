extends StaticBody3D

@export var g_name: String
@export var gun_model: Node3D
@export var anim_player: AnimationPlayer
@export var particles: Array[CPUParticles3D]
@export var light: OmniLight3D
@export var area: Area3D
@export var visible_area: MeshInstance3D
@export var bullets_poses: Array[Vector3] = [Vector3(0,0,0)]
@export var recharge_time: float = 1
@export var build_particles: Node3D
var audio: AudioStreamPlayer
var target: CharacterBody3D
var lvl: int = 1

var bullet_scene: PackedScene = load("res://objects/bullet/bullet.tscn")

func _ready() -> void:
	fire()
	anim_player.speed_scale = 1/recharge_time
	
	audio = get_node("AudioStreamPlayer")
	
	await  get_tree().process_frame
	build_visuals()

func build_visuals() -> void:
	for p in build_particles.get_children():
		p.restart()
	var tween = create_tween()
	tween.tween_property(gun_model, "scale", Vector3(1.1,0.8,1.1), 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(gun_model, "scale", Vector3.ONE, 0.2).set_ease(Tween.EASE_OUT)
	gun_model.rotation_degrees.y = [0,90,180,270].pick_random()

func destroy_self() -> void:
	build_visuals()
	get_node("CollisionShape3D").disabled = true
	gun_model.visible = false
	var tween = create_tween()
	var pos: Vector3 = position
	tween.tween_property(self, "position", Vector3(pos.x,pos.y-1,pos.z), 1)
	await get_tree().create_timer(1).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	if target:
		var look: Vector3 = target.global_position
		look.y = global_position.y
		gun_model.look_at(look)

func fire() -> void:
	await get_tree().create_timer(recharge_time).timeout
	
	if !target:
		fire()
		return
	
	audio.pitch_scale = randf_range(0.8,1.2)
	audio.play()
	fire_visual()
	fire_bullet()
	
	fire()

func fire_visual() -> void:
	for p in particles:
		p.restart()
	anim_player.play("fire")
	light.light_energy = 10

func fire_bullet() -> void:
	for pos in bullets_poses:
		var bullet = bullet_scene.instantiate()
		bullet.damage += (lvl - 1)*2
		add_child(bullet)
		
		bullet.global_position = particles[0].global_position + pos
		var direction = (target.global_position + pos - bullet.global_position + Vector3(0,0.5,0)).normalized()
		bullet.apply_central_impulse(direction * 20)

func body_enter_area(body: Node3D) -> void:
	if target:
		return
	if body.is_in_group("mob"):
		target = body

func _on_area_3d_body_exit_area(body: Node3D) -> void:
	if body == target:
		find_new_target_or_off()

func find_new_target_or_off() -> void:
	target = null
	for body in area.get_overlapping_bodies():
		if body.is_in_group("mob"):
			target = body

func hover(mouse: bool) -> void:
	visible_area.visible = mouse
