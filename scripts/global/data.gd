extends Node

signal money_changed
signal hp_changed
signal wave_changed


@export var start_money: int = 50
var money: int:
	set(val):
		if money != val:
			money = val
			money_changed.emit(money)

@export var start_hp: int = 100
var hp: int:
	set(val):
		if hp != val:
			hp = val
			hp_changed.emit(hp)

@export var start_wave_i: int = 0
var wave_i: int:
	set(val):
		if wave_i != val:
			wave_i = val
			wave_changed.emit(wave_i)

@export var prices: Dictionary[String,int]

@export var mob_scenes: Dictionary[String,PackedScene]
@export var waves: Array
