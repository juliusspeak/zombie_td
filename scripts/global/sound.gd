extends Node
@export var music_button: Button
@export var sfx_button: Button

func _ready() -> void:
	music_button.mouse_entered.connect(buttonHoverOn.bind(music_button))
	music_button.mouse_exited.connect(buttonHoverOff.bind(music_button))
	sfx_button.mouse_entered.connect(buttonHoverOn.bind(sfx_button))
	sfx_button.mouse_exited.connect(buttonHoverOff.bind(sfx_button))
	music_button.pressed.connect(music)
	sfx_button.pressed.connect(sfx)

func buttonHoverOn(b: Button) -> void:
	var a = b.modulate.a
	b.modulate = Color.GOLD
	b.modulate.a = a

func buttonHoverOff(b: Button) -> void:
	var a = b.modulate.a
	b.modulate = Color.WHITE
	b.modulate.a = a

func music() -> void:
	if AudioServer.get_bus_volume_db(2) > -6:
		AudioServer.set_bus_volume_db(2,-999)
		music_button.modulate.a = 0.5
	else:
		AudioServer.set_bus_volume_db(2,0)
		music_button.modulate.a = 1

func sfx() -> void:
	if AudioServer.get_bus_volume_db(1) > -6:
		AudioServer.set_bus_volume_db(1,-999)
		sfx_button.modulate.a = 0.5
	else:
		AudioServer.set_bus_volume_db(1,0)
		sfx_button.modulate.a = 1
