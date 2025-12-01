extends Area2D

signal hit_target(body)

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()




func _on_body_entered(body: Node2D) -> void:
	if !body.die(): return
	emit_signal("hit_target", body)
	body.die()
