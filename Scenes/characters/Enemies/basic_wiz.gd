extends CharacterBody2D

signal is_dead

func die():
	emit_signal("is_dead")
	queue_free()
