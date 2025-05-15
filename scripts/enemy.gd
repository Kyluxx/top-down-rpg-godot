extends CharacterBody2D

var speed := 80
var chasing_player := false
var player = null


func _ready():
	var rng = RandomNumberGenerator.new()
	var raw_screen = get_viewport().size
	print(raw_screen)
	var max_attempts = 50

	for i in range(max_attempts):
		var pos_x = rng.randi_range(0, raw_screen.x)
		var pos_y = rng.randi_range(0, raw_screen.y)
		position = Vector2(pos_x, pos_y)
		print(position)


		# force update posisi biar Area2D bisa cek tabrakan
		$Detection_Area.global_position = position
		await get_tree().process_frame

		if $Detection_Area.get_overlapping_bodies().is_empty():
			break  # posisi aman, keluar dari loop

	# play animasi
	$AnimatedSprite2D.play()



func _process(delta):
	if chasing_player:
		position += (player.position - position) / speed
		move_and_slide()


func _on_detection_area_body_entered(body):
	player = body
	chasing_player = true
	

func _on_detection_area_body_exited(body):
	player = null
	chasing_player = false
	
