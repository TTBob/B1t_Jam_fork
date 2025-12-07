extends ParallaxBackground

@export var parallax_strength := 0.05
var cam: Camera2D

func _ready():
	cam = get_viewport().get_camera_2d()

func _process(delta):
	if cam:
		var pos = cam.global_position * parallax_strength
		scroll_offset = -pos.floor()
