extends Node

var blood_arr: Array = []
var bone_arr: Array = []
var wave_paused: bool = false

var completed_ingredients := {
	"salt": false,
	"oats": false,
	"milk": false,
	"honey": false,
}

var progress_values := {
	"salt": 0,
	"oats": 0,
	"milk": 0,
	"honey": 0,
}

var current_wave: int = 0   # <-- track which wave we’re on globally


func reset_all():
	blood_arr.clear()
	bone_arr.clear()

	for k in completed_ingredients:
		completed_ingredients[k] = false

	for k in progress_values:
		progress_values[k] = 0

	current_wave = 0

	print("GameData reset completed.")
