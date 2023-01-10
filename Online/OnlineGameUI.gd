extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	if Network.is_server:
		$Control/MarginContainer/Server.disabled = false


func _on_Server_pressed():
	rpc("end_game")

remotesync func end_game():
	get_tree().disconnect_network_peer(get_tree().get_network_unique_id())
