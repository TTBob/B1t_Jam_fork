extends Node2D

@export var stage_scene_path: String = "res://StageScene.tscn"

func _ready():
	get_tree().paused = false   # safe zone never pauses
	print("Entered Safe Zone")

	# Make sure player never stays in paused mode from stage scene
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.in_safe_zone = false  # will change when entering RitualZone


func _process(delta):
	# Press Space to go back to stage scene
	if Input.is_action_just_pressed("ui_accept"):
		_go_back_to_stage()


func _go_back_to_stage():
	get_tree().change_scene_to_file(stage_scene_path)


# ======================================================
# RITUAL ZONE LOGIC
# ======================================================
func _on_ritual_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.in_safe_zone = true
		print("Player entered ritual zone → inventory donations ENABLED")


func _on_ritual_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.in_safe_zone = false
		print("Player left ritual zone → inventory donations DISABLED")
