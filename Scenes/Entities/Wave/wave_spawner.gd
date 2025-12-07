extends Node2D

@export var Basic_Nisse: PackedScene
@export var Range_Wiz: PackedScene
@export var Self_Dest_Wiz: PackedScene

@export var player: Node2D
@export var spawn_radius: float = 300.0
@export var min_spawn_radius: float = 100.0

@export var safe_scene_path: String = "res://Scenes/UI/selection_scene.tscn"

var enemy_info := {
	"Basic_Nisse": {"type": null, "number": 0},
	"Range_Wiz": {"type": null, "number": 0},
	"Self_Dest_Wiz": {"type": null, "number": 0}
}

@export var waves := [
	{ "Basic_Nisse": 3, "Range_Wiz": 0, "Self_Dest_Wiz": 0 },
	{ "Basic_Nisse": 4, "Range_Wiz": 0, "Self_Dest_Wiz": 0 },
	{ "Basic_Nisse": 4, "Range_Wiz": 0, "Self_Dest_Wiz": 0 },
	{ "Basic_Nisse": 6, "Range_Wiz": 0, "Self_Dest_Wiz": 0 },
	{ "Basic_Nisse": 8, "Range_Wiz": 0, "Self_Dest_Wiz": 0 },
	{ "Basic_Nisse": 10, "Range_Wiz": 0, "Self_Dest_Wiz": 0 },
	{ "Basic_Nisse": 12, "Range_Wiz": 0, "Self_Dest_Wiz": 0 }
]

var current_wave := 0
var total_to_spawn := 0
var total_dead := 0
var wave_working := true   # TRUE → can spawn — FALSE → waiting for player


func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS   # Detect keys even when "paused"
	
	enemy_info["Basic_Nisse"].type = Basic_Nisse
	enemy_info["Range_Wiz"].type = Range_Wiz
	enemy_info["Self_Dest_Wiz"].type = Self_Dest_Wiz

	print("Starting first wave...")
	start_next_wave()


func _process(delta):
	if not wave_working:  # Waiting after wave clear
		if Input.is_action_just_pressed("ui_accept"):  # SPACE → next wave
			_continue_wave()

		if Input.is_action_just_pressed("safe_zone"):  # G → Safe Zone
			_go_to_safe_zone()
			

# -------------------------------------------------------
# START + RESUME WAVES
# -------------------------------------------------------

func start_next_wave():
	if current_wave >= waves.size():
		print("All waves finished.")
		return

	if not wave_working:
		return  # waiting for player option

	print("\n=== STARTING WAVE:", current_wave + 1, "===")

	_setup_wave(enemy_info, waves[current_wave])
	_spawn_all_enemies()

	current_wave += 1


func _continue_wave():
	print("\nContinuing to next wave...")
	GameData.wave_paused = false
	wave_working = true
	start_next_wave()


# -------------------------------------------------------
# SETUP
# -------------------------------------------------------

func _setup_wave(dict, wave_data):
	for key in wave_data.keys():
		dict[key].number = wave_data[key]
		print("Wave setup:", key, "=", wave_data[key])


# -------------------------------------------------------
# SPAWNING
# -------------------------------------------------------

func _spawn_all_enemies():
	total_dead = 0
	total_to_spawn = 0

	for key in enemy_info.keys():
		total_to_spawn += enemy_info[key].number

	print("Total enemies to spawn:", total_to_spawn)

	for key in enemy_info.keys():
		var info = enemy_info[key]
		if info.type != null and info.number > 0:
			_spawn_enemy_type(info.type, info.number)


func _spawn_enemy_type(scene: PackedScene, count: int):
	for i in range(count):
		var enemy = scene.instantiate()
		add_child(enemy)

		if enemy.has_signal("is_dead"):
			enemy.is_dead.connect(_enemy_died)

		enemy.global_position = spawn_position_around_player()

		print("Spawned enemy at:", enemy.global_position)


func spawn_position_around_player() -> Vector2:
	var angle = randf() * TAU
	var radius = randf_range(min_spawn_radius, spawn_radius)

	return player.global_position + Vector2(cos(angle), sin(angle)) * radius


# -------------------------------------------------------
# ENEMY DEATH
# -------------------------------------------------------

func _enemy_died():
	total_dead += 1
	print("Enemy died:", total_dead, "/", total_to_spawn)

	if total_dead >= total_to_spawn:
		wave_working = false

		print("\n=== WAVE CLEARED ===")
		GameData.wave_paused = true  # Stop player + enemy movement

		print("Waiting for SPACE (next wave) or G (safe zone)...")


# -------------------------------------------------------
# SAFE ZONE
# -------------------------------------------------------

func _go_to_safe_zone():
	print("Moving to safe zone...")
	GameData.wave_paused = false
	get_tree().change_scene_to_file("res://Scenes/Game_Scenes/safe_zone.tscn")
