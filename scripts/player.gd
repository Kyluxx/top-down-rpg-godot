extends CharacterBody2D

const speed := 100
var current_direction := "none"


func _ready():
	$AnimatedSprite2D.play("front_idle")


func _physics_process(delta: float) -> void:
	player_movement(delta)
	print(current_direction)

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


#const SPEED = 300.0
#const JUMP_VELOCITY = -400.0
#
#
#func _physics_process(delta: float) -> void:
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var direction := Input.get_axis("ui_left", "ui_right")
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
