extends Control

@onready var safe_zone: Button = $safe_zone
@onready var next_wave: Button = $next_wave

# Assign Safe Scene path here
@export var safe_scene_path: String = "res://SafeScene.tscn"

func _ready():
	# UI should be hidden until a wave ends
	visible = false

	# Connect buttons
	safe_zone.pressed.connect(_on_safe_zone_pressed)
	next_wave.pressed.connect(_on_next_wave_pressed)


# ---------------------------------------------------------
# WHEN SAFE ZONE IS CLICKED
# ---------------------------------------------------------
func _on_safe_zone_pressed():
	print("Going to Safe Zone...")

	# Unpause stage scene
	get_tree().paused = false

	# Load safe scene
	get_tree().change_scene_to_file(safe_scene_path)



# ---------------------------------------------------------
# WHEN NEXT WAVE IS CLICKED
# ---------------------------------------------------------
func _on_next_wave_pressed():
	print("Starting next wave...")

	visible = false     # Hide UI
	get_tree().paused = false

	# Find wave spawner and resume wave
	var spawner = get_tree().get_first_node_in_group("wave_spawner")
	if spawner:
		spawner.resume_wave()
	else:
		print("ERROR: Spawner not found!")
