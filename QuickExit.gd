extends Node


func _ready():
	pause_mode = PAUSE_MODE_PROCESS
	
func _process(_delta):
	if Input.is_action_just_pressed("quick_exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("quick_restart"):
		get_tree().reload_current_scene()
