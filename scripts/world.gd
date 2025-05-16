extends Node

# Preload the player scene only once
const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")

# Networking peer
var network_peer: ENetMultiplayerPeer
var is_server: bool

# Root node for all players
@onready var players_root: Node = $Players

@onready var MainMenu = $Menu/Desc

func _ready() -> void:
	# Determine if this instance is server
	var args = OS.get_cmdline_args()
	is_server = ("--server" in args) or OS.has_feature("dedicated_server")

	# Setup networking
	network_peer = ENetMultiplayerPeer.new()
	if is_server:
		_start_server()
	else:
		# Delay client join until user input, or auto-join:
		# _start_client("localhost", 25566)
		pass

	# Connect multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _start_server(port: int = 25566) -> void:
	network_peer.create_server(port)
	multiplayer.multiplayer_peer = network_peer
	MainMenu.text = "You are the server"
	print("Server started on port %d" % port)

func _start_client(host: String, port: int) -> void:
	network_peer.create_client(host, port)
	multiplayer.multiplayer_peer = network_peer
	print("Connecting to %s:%d..." % [host, port])

func _on_host_pressed() -> void:
	_start_server()

func _on_join_pressed() -> void:
	_start_client("localhost", 25566)
	$Menu.hide()
	$MenuCamera.enabled = false
	$IngameMenu.visible = true
	

func _on_peer_connected(peer_id: int) -> void:
	print("Peer %d has joined" % peer_id)
	_spawn_player(peer_id)

func _on_peer_disconnected(peer_id: int) -> void:
	print("Peer %d has left" % peer_id)
	var player_node = players_root.get_node_or_null(str(peer_id))
	if player_node:
		player_node.queue_free()

func _spawn_player(peer_id: int) -> void:
	if not multiplayer.is_server():
		return
	# Instantiate and add to players container
	var player = PLAYER_SCENE.instantiate()
	var node_name = "Player_%d" % peer_id
	if players_root.has_node(node_name):
		$Menu/NameInput.placeholder_text = "Oops! try another name"
		$Menu/NameInput.text = ""
		return
	player.name = node_name
	players_root.add_child(player)
	# Give network authority to the specific peer
	player.set_multiplayer_authority(peer_id)

	# Initialize player properties remotely if needed
	if is_server:
		# Optionally broadcast initial state
		# rpc_id(peer_id, "_init_player", player.global_position)
		pass

# Example RPC to initialize player state _on client
#@rpc(any_peer, reliable)
#func _init_player(pos: Vector2) -> void:
#    global_position = pos

func _on_line_edit_text_changed(new_text: String) -> void:
	Global.username = new_text

func _on_button_toggled(toggled_on: bool) -> void:
	Global.is_joined = toggled_on
	if toggled_on:
		_on_join_pressed()

@rpc("any_peer", "call_local", "unreliable")
func display_chat(chat_text: String, sent_by: int) -> void:
	var player = _get_player_node(sent_by)
	if not player:
		push_warning("Player %d not found!" % sent_by)
		return
	var bubble = player.get_node("bubble_chat")
	if bubble:
		bubble.show_chat(chat_text)
	else:
		push_warning("BubbleChat missing in %s" % player.name)

func _get_player_node(peer_id: int) -> Node2D:
	var players = get_node("Players")
	return players.get_node_or_null("Player_%d" % peer_id)
