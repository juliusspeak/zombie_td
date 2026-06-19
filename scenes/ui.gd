extends Control
@export var controller: Node 
@export var build_controller: Node3D
@export var data: Node
@export var x_label: Label
@export var y_label: Label
@export var money_label: Label
@export var wave_label: Label
@export var hp_label: Label
@export var sml_gun_button: Button
@export var mid_gun_button: Button
@export var big_gun_button: Button
@export var sml_gun_label: Label
@export var mid_gun_label: Label
@export var big_gun_label: Label
@export var start_button: Button
var build_panel: Panel
var build_panel_scene: PackedScene = load("res://scenes/build_panel.tscn")
var game_over_scene: PackedScene = load("res://scenes/game_over_panel.tscn")
var last_build
func _ready() -> void:
	build_controller.cur_cell_changed.connect(cur_cell_changed)
	build_controller.cur_plan_changed.connect(cur_plan_changed)
	build_controller.build_pressed.connect(build_pressed)
	
	data.money_changed.connect(money_changed)
	data.wave_changed.connect(wave_changed)
	data.hp_changed.connect(hp_changed)
	
	controller.prepare_wave.connect(prepare_wave)
	controller.esc_pressed.connect(esc_pressed)
	controller.game_over.connect(game_over)
	
	sml_gun_button.pressed.connect(set_build.bind("sml"))
	mid_gun_button.pressed.connect(set_build.bind("mid"))
	big_gun_button.pressed.connect(set_build.bind("big"))
	
	set_labels()
	money_changed(data.money)
	hp_changed(data.hp)

func cur_plan_changed(btn: String) -> void:
	sml_gun_button.get_child(0).visible = false
	mid_gun_button.get_child(0).visible = false
	big_gun_button.get_child(0).visible = false
	if btn != "":
		{"sml":sml_gun_button,"mid":mid_gun_button,"big":big_gun_button}[btn].get_child(0).visible = true

func cur_cell_changed(cell: Vector2) -> void:
	x_label.text = str(clamp(int(cell.x)+4,0,8))
	y_label.text = str(clamp(int(cell.y)+4,0,8))

func money_changed(money: int) -> void:
	money_label.text = str(money)
	shake(money_label)
	set_buttons()

func wave_changed(wave_i: int) -> void:
	shake(wave_label)
	wave_label.text = str(wave_i)

func hp_changed(hp: int) -> void:
	shake(hp_label)
	hp_label.text = str(hp)
	
func set_labels() -> void:
	sml_gun_label.text = str(data.prices["sml"])
	mid_gun_label.text = str(data.prices["mid"])
	big_gun_label.text = str(data.prices["big"])

func set_buttons() -> void:
	if data.money >= data.prices["sml"]:
		sml_gun_button.disabled = false
	else:
		sml_gun_button.disabled = true
	if data.money >= data.prices["mid"]:
		mid_gun_button.disabled = false
	else:
		mid_gun_button.disabled = true
	if data.money >= data.prices["big"]:
		big_gun_button.disabled = false
	else:
		big_gun_button.disabled = true

func set_build(type: String) -> void:
	build_controller.cur_plan = type

func prepare_wave() -> void:
	start_button.visible = true

func build_pressed(build: StaticBody3D) -> void:
	if build_panel:
		build_panel.queue_free()
	build_panel = build_panel_scene.instantiate()
	last_build = build
	add_child(build_panel)
	
	var lvl: int = build.lvl
	var dmg: int = (10+(lvl-1)*2) * build.bullets_poses.size()
	var upg_price: int = float(data.prices[build.g_name]) * (1.15**lvl)
	var sell_price: int = data.prices[build.g_name]/2
	
	build_panel.lvl_label.text = str(lvl)
	build_panel.dmg_label.text = str(dmg)
	build_panel.upg_price_label.text = str(upg_price)
	build_panel.sell_price_label.text = str(sell_price)
	
	var pos: Vector2 = get_local_mouse_position()
	if pos.x > 830:
		pos.x = 700
	if pos.y > 490:
		pos.y = 480
	
	build_panel.position = pos
	build_panel.visible = true
	
	build_panel.upg_button.pressed.connect(controller.upgrade_build.bind(build))
	build_panel.sell_button.pressed.connect(controller.sell_build.bind(build))
func _on_button_pressed() -> void:
	controller.start_game()
	start_button.visible = false

func shake(node: Control) -> void:
	node.pivot_offset = Vector2(node.size.x/2,node.size.y/2)
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(node,"rotation", randf_range(-0.2,0.2),0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(node,"scale", Vector2(0.8,0.8),0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween.set_parallel(false)
	tween.tween_property(node,"rotation", 0,0.1).set_ease(Tween.EASE_IN)
	tween.tween_property(node,"scale", Vector2(1,1),0.1).set_ease(Tween.EASE_IN)

func esc_pressed() -> void:
	if build_panel:
		build_panel.queue_free()
		last_build = null

func game_over() -> void:
	var game_over_panel = game_over_scene.instantiate()
	add_child(game_over_panel)
	game_over_panel.button.pressed.connect(controller.new_game)
	game_over_panel.button.pressed.connect(game_over_panel.queue_free)
