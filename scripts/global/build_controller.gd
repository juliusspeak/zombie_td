extends Node3D

signal cur_cell_changed
signal cur_plan_changed
signal build_pressed

@export var ui: Control 
@export var controller: Node 
@export var data: Node

var cur_cell: Vector2i:
	set(val):
		if cur_cell != val:
			cur_cell = val
			cur_cell_changed.emit(cur_cell)
var cur_build: StaticBody3D
var cur_plan: String:
	set(val):
		if cur_plan != val:
			cur_plan = val
			cur_plan_changed.emit(cur_plan)
@export var y_decal: Decal
@export var x_decal: Decal
@export var mob_start: Node3D
@export var mob_end: Node3D
@export var nav_region: NavigationRegion3D
@export var builds: Dictionary[String,PackedScene]

@export var build_audio: AudioStreamPlayer
@export var demolish_audio: AudioStreamPlayer


var astar = AStar2D.new()
var cell_id: Dictionary
var has_build: Dictionary[Vector2i,bool]
var barricades_scene = load("res://objects/barricades/barricades.tscn")
var barricades: Array
var builds_list: Dictionary[Vector2i,StaticBody3D]

func _ready() -> void:
	setup_cells()
	build_astar()
	
	controller.game_over.connect(game_over)
	controller.esc_pressed.connect(esc_pressed)

func game_over() -> void:
	for b in nav_region.get_children():
		b.destroy_self()
	for v2 in has_build:
		has_build[v2] = false
	barricades.clear()
	builds_list.clear()
	build_astar()

func _process(delta: float) -> void:
	set_cell()
	draw_decals()

func esc_pressed() -> void:
	cur_plan = ""
	cur_build = null

func set_cell() -> void:
		var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		var cam: Camera3D = $"../world/settings/Camera3D"
		var mousepos: Vector2 = get_viewport().get_mouse_position()
		var origin: Vector3 = cam.project_ray_origin(mousepos)
		var end: Vector3 = origin + cam.project_ray_normal(mousepos) * 200
		var query = PhysicsRayQueryParameters3D.create(origin, end)
		query.collision_mask = (1 << 0) | (1 << 2)
		var result = space_state.intersect_ray(query)
		if result:
			if result.collider.is_in_group("builds"):
				if cur_build != null:
					cur_build.hover(false)
				cur_build = result.collider
				cur_build.hover(true)
			else:
				if cur_build != null:
					cur_build.hover(false)
					cur_build = null
			cur_cell = Vector2i(roundi(result.position.x/2),roundi(result.position.z/2))
		else:
			cur_build = null
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("lbm"):
		if ui.build_panel:
			if !ui.build_panel.get_global_rect().has_point(get_viewport().get_mouse_position()):
				controller.esc_pressed.emit()
			return
		if cur_cell == Vector2i(-4,-4) or cur_cell == Vector2i(4,4):
			return
		if cur_cell.x <= -5 or cur_cell.x >= 5:
			return
		if cur_cell.y <= -5 or cur_cell.y >= 5:
			return
		if has_build[cur_cell*2] == true:
			if ui.build_panel:
				return
			cur_plan = ""
			if cur_build:
				build_pressed.emit(cur_build)
		else:
			if blocked_path(cur_cell*2) == true:
				return
			if cur_plan == "":
				return
			try_build()

func put_barricade(pos:Vector2i) -> void:
	var pos_v3 = Vector3(pos.x,0,pos.y)
	if has_build[pos] == true:
		has_build[pos] = false
		if builds_list[pos] != null:
			builds_list[pos].destroy_self()
	if blocked_path(pos):
		return
	var b = put_build(barricades_scene,pos_v3)
	barricades.append(b)

func clear_barricades() -> void:
	for b in barricades:
		if b:
			var pos = Vector2i(b.global_position.x,b.global_position.z)
			has_build[pos] = false
			builds_list[pos] = null
			b.destroy_self()
	
	demolish_audio.pitch_scale = randf_range(0.8,1.2)
	demolish_audio.play()
	barricades.clear()
	build_astar()

func put_build(scene: PackedScene, pos: Vector3):
	var pos_2d = Vector2i(pos.x,pos.z)
	var build = scene.instantiate()
	nav_region.add_child(build)
	build.global_position = pos
	nav_region.bake_navigation_mesh()
	
	has_build[pos_2d] = true
	builds_list[pos_2d] = build
	
	build_audio.pitch_scale = randf_range(0.8,1.2)
	build_audio.play()
	
	build_astar()
	return build

func try_build() -> void:
	if data.money >= data.prices[cur_plan]:
		data.money -= data.prices[cur_plan]
		
		put_build(builds[cur_plan],Vector3(cur_cell.x,0,cur_cell.y)*2)

func draw_decals() -> void:
	if cur_cell.x >= -4 and cur_cell.x <= 4 and cur_cell.y >= -4 and cur_cell.y <= 4:
		x_decal.visible = true
		x_decal.global_position.x = cur_cell.x*2
		y_decal.visible = true
		y_decal.global_position.z = cur_cell.y*2
	else:
		x_decal.visible = false
		y_decal.visible = false

func setup_cells() -> void:
	var n:int = 0
	for x in range(-4,5):
		for y in range(-4,5):
			cell_id[Vector2i(x*2,y*2)] = n
			has_build[Vector2i(x*2,y*2)] = false
			n += 1

func build_astar() -> void:
	for node in get_children():
		node.queue_free()
	astar.clear()
	
	for pos in cell_id:
		astar.add_point(cell_id[pos],pos)
	
	for pos in cell_id:
		var neighbours: Array = [Vector2i(-2,0),Vector2i(2,0),Vector2i(0,-2),Vector2i(0,2)]
		for add_pos in neighbours:
			var neighbour_pos: Vector2i = pos+add_pos
			if cell_id.keys().has(neighbour_pos):
				var cur_id: int = cell_id[pos]
				var neighbour_id: int = cell_id[neighbour_pos]
				
				if has_build[pos] == false and has_build[neighbour_pos] == false:
					astar.connect_points(cur_id,neighbour_id,true)

func blocked_path(pos: Vector2i) -> bool:
	has_build[pos] = true
	build_astar()
	var path: Array = astar.get_id_path(cell_id[Vector2i(-8,-8)],cell_id[Vector2i(8,8)])
	
	if path.is_empty():
		has_build[pos] = false
		build_astar()
		return true
	else:
		has_build[pos] = false
		return false
