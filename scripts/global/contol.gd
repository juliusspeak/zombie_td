extends Node

signal wave_passed
signal prepare_wave
signal esc_pressed
signal game_over
signal start_new_game
@export var data: Node
@export var mob_controller: Node
@export var build_controller: Node3D

func _ready() -> void:
	set_start_vals()

func mob_died(reward: int) -> void:
	data.money += reward

func start_game() -> void:
	spawn_barricades()

func spawn_wave() -> void:
	var cur_wave: int = data.wave_i
	data.wave_i += 1
	if data.waves.size() <= cur_wave:
		cur_wave = data.waves.size() - 1
	for mob_pack: MobPack in data.waves[cur_wave].packs:
		for i in mob_pack.count:
			var mob_scene: PackedScene = data.mob_scenes[mob_pack.mob_name]
			mob_controller.spawn(mob_scene)
			var delay: float = mob_pack.spawn_delay
			await get_tree().create_timer(delay).timeout
			
	wave_passed.emit()
	prepare_wave.emit()

func spawn_barricades() -> void:
	build_controller.clear_barricades()
	var possible_cells = build_controller.has_build.keys()
	if possible_cells.has(Vector2i(-8,-8)):
		possible_cells.erase(Vector2i(-8,-8))
	if possible_cells.has(Vector2i(8,8)):
		possible_cells.erase(Vector2i(8,8))
	
	for i in 5:
		build_controller.put_barricade(possible_cells.pick_random())
		await get_tree().create_timer(0.3).timeout
	
	spawn_wave()


func damage_area_entered(body: Node3D) -> void:
	if body.is_in_group("mob"):
		body.queue_free()
		data.hp -= 1
		if data.hp <= 0:
			game_over.emit()
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		esc_pressed.emit()

func upgrade_build(build: StaticBody3D) -> void:
	var lvl: int = build.lvl
	var upg_price: int = float(data.prices[build.g_name]) * (1.15**lvl)
	if upg_price > data.money:
		return
	
	data.money -= upg_price
	build.lvl += 1
	esc_pressed.emit()

func sell_build(build: StaticBody3D) -> void:
	var lvl: int = build.lvl
	var sell_price: int = data.prices[build.g_name]/2
	var pos = Vector2i(build.global_position.x,build.global_position.z)
	build_controller.has_build[pos] = false
	build_controller.builds_list[pos] = null
	build.destroy_self()
	
	build_controller.demolish_audio.pitch_scale = randf_range(0.8,1.2)
	build_controller.demolish_audio.play()
	
	data.money += sell_price
	esc_pressed.emit()

func new_game() -> void:
	set_start_vals()
	start_new_game.emit()

func set_start_vals() -> void:
	data.money = data.start_money
	data.hp = data.start_hp
	data.wave_i = data.start_wave_i
