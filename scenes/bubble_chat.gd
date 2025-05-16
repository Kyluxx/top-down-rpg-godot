extends Control

@onready var panel = $Panel
@onready var label = $Panel/Label  # your regular Label

var length_of_text

# adjust these for how much padding you want
const PADDING_X = 20
const PADDING_Y = 0

func show_chat(text: String) -> void:
	# 1) set the label text
	label.text = text
	length_of_text = text.length()

	# 2) force layout update
	#label.queue_sort()  # ensures minimum size is recalculated next frame

	# 3) compute minimum size + padding
	var size = label.get_minimum_size()
	size.x += PADDING_X * 2
	size.y += PADDING_Y * 2

	# 4) apply to panel
	panel.size = size
	panel.pivot_offset = Vector2(size.x * 0.5, size.y)
	position.y = -size.y - 10 
	print(position)
	# 5) position bubble however you need, then show
	show()
	var timeout = 2 if length_of_text < 100 else 4 
	$Timer.start(timeout)  # otomatis hide setelah beberapa detik

func _on_timer_timeout() -> void:
	hide()
