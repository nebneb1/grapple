extends Node2D

func _ready():
	get_tree().paused = true
	$transition.emitting = true
	yield(get_tree().create_timer(1.0), "timeout")
	get_tree().paused = false
