extends Node

const PLAYER = preload("res://scenes/player.tscn")
var peer = ENetMultiplayerPeer.new()
var args = OS.get_cmdline_args()
var is_server: bool = "--server" in args or OS.has_feature("dedicated_server")

func _ready():
	if is_server:
		_on_host_pressed()

func _on_host_pressed():
	peer.create_server(25566)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	$Menu/Desc.text = "You are a server"
	print("Server started on port 25566 💫")

func _on_join_pressed():
	peer.create_client("localhost", 25566)
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(pid):
	print("Peer", pid, "has joined the game! 🌟")
	add_player(pid)

func _on_peer_disconnected(pid):
	print("Peer", pid, "has left the game 💔")
	var node_name = str(pid)
	var player = get_node_or_null(node_name)
	if player:
		player.queue_free()
		print("Player", node_name, "removed successfully! 🎉")

func add_player(pid):
	var player = PLAYER.instantiate()
	player.name = str(pid)
	add_child(player)

func _on_line_edit_text_changed(new_text: String) -> void:
	Global.username = new_text

func _on_button_toggled(toggled_on: bool) -> void:
	Global.is_joined = true
	$Menu.hide()
	$MenuCamera.enabled = false
	$IngameMenu.set_visible(true)
	_on_join_pressed()
