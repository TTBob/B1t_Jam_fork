extends Camera2D

@export var smoothness := 0.15
var target: Node2D

func _ready():
	target = get_parent() # Player

func _physics_process(delta):
	if not target:
		return

	# Smooth follow
	var desired = target.global_position
	global_position = global_position.lerp(desired, smoothness)

	# PIXEL PERFECT SNAP — THIS FIXES HORIZONTAL + DIAGONAL JITTER
	global_position.x = round(global_position.x * 2) / 2
	global_position.y = round(global_position.y * 2) / 2
