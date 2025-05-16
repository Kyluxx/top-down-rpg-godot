extends Control

# Signals for typing status
signal is_typing
signal finished_typing

@onready var line_edit = $MarginContainer/HBoxContainer/VBoxContainer/LineEdit
@onready var button    = $MarginContainer/HBoxContainer/VBoxContainer/Button

func _ready():
	# Connect UI events
	button.pressed.connect(_on_send_pressed)
	line_edit.focus_entered.connect(_send_on_typing)
	line_edit.focus_exited.connect(_send_finished_typing)

func _input(event):
	# Send on Enter only when LineEdit is focused
	if event.is_action_pressed("enter") and line_edit.has_focus():
		_on_send_pressed()
	elif event.is_action_pressed("escape"):
		line_edit.release_focus()

func _on_send_pressed() -> void:
	var msg = line_edit.text 
	if msg == "":
		return
	# Send message via RPC to display_chat in ChatManager
	var my_id = multiplayer.get_unique_id()
	# find the world node in the scene	
	var world = get_tree().get_nodes_in_group("world")[0]
	# call the RPC on it
	world.rpc("display_chat", msg, my_id)
	# Reset input
	line_edit.text = ""
	line_edit.release_focus()

func _send_on_typing() -> void:
	is_typing.emit()

func _send_finished_typing() -> void:
	finished_typing.emit()
