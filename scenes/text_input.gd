extends Control

signal is_typing
signal finished_typing
signal send_msg(msg: String)

@onready var line_edit = $MarginContainer/HBoxContainer/VBoxContainer/LineEdit
@onready var button = $MarginContainer/HBoxContainer/VBoxContainer/Button

func _ready():
	line_edit.focus_entered.connect()
	line_edit.focus_exited.connect()

func _input(_event):
	if Input.is_action_just_pressed("enter"):
		_send_msg(line_edit.text)
	if Input.is_action_pressed("escape"):
		line_edit.release_focus()
		

#@rpc("any_peer", "call_local", "unreliable", 1)
#func _recv_msg():
	#

func _send_msg(msg):
	send_msg.emit(msg)

func _send_on_typing():
	is_typing.emit()

func _send_finished_typing():
	finished_typing.emit()
