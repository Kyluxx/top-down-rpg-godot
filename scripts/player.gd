extends CharacterBody2D

@export var speed := 150
var current_direction := "none"

func _enter_tree():
	set_multiplayer_authority(int(str(name)))


func _ready():
	if !is_multiplayer_authority():
		return
	
	$Camera2D.make_current()
	
	var rng = RandomNumberGenerator.new()
	var raw_screen = get_viewport().size - Vector2i(100, 100)
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

	$AnimatedSprite2D.play("front_idle")


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		$Camera2D.set_enabled(false)
		return
		
	if Global.is_joined:
		$Username.text = Global.username
		$Camera2D.set_enabled(true) 
		player_movement(delta)

func player_movement(_delta):
	# get_vector(left, right, up, down)
	var dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	
	# set velocity
	velocity = dir * speed

	# determine current_direction string
	if dir == Vector2.ZERO:
		play_animation(0)
		current_direction = "none"
	else:
		play_animation(1)
		# pick the dominant axis
		if abs(dir.x) > abs(dir.y):
			current_direction = "right" if dir.x > 0 else "left"
		else:
			current_direction = "down" if dir.y > 0 else "up"
	# actually move the body
	move_and_slide()

func play_animation(movement):
	var dir = current_direction
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	if dir == "left":
		anim.flip_h = true
		if movement == 1:
			anim.play("side_walk")
		elif movement == 0:
			anim.play("side_idle")
	if dir == "down":
		anim.flip_h = false
		if movement == 1:
			anim.play("front_walk")
		elif movement == 0:
			anim.play("front_idle")
	if dir == "up":
		anim.flip_h = false
		if movement == 1:
			anim.play("back_walk")
		elif movement == 0:
			anim.play("back_idle")
