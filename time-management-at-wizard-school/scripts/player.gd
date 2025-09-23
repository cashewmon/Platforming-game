extends CharacterBody2D


var speed = 150.0
var shift_speed = 70
const JUMP_VELOCITY = -320.0
var grounded = .05
var ledge = 0
var ledge_grab=false
var ledge_drop=false
# facing false = left, true = right
var facing_right = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var left_raycast: RayCast2D = $LeftRaycast
@onready var right_raycast: RayCast2D = $RightRaycast
@onready var up_raycast: RayCast2D = $UpRaycast
@onready var down_raycast: RayCast2D = $DownRaycast


var current_speed = speed

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		grounded-=delta
	# 	
	if is_on_floor():
		grounded = .05
	
	# Take two on walking vs running
	if Input.is_action_pressed("Shift") and is_on_floor():
		if current_speed > shift_speed:
			current_speed -= 20
		if (not left_raycast.is_colliding() and Input.is_action_pressed("ui_left")):
			current_speed=0
		if (not right_raycast.is_colliding() and Input.is_action_pressed("ui_right")):
			current_speed=0
		if (not right_raycast.is_colliding() and Input.is_action_just_released("ui_right")):
			current_speed=shift_speed
		if (not left_raycast.is_colliding() and Input.is_action_just_released("ui_left")):
			current_speed=shift_speed
		if Input.is_action_just_pressed("ui_accept"):
			current_speed=shift_speed
	if Input.is_action_just_released("Shift"):
		current_speed=speed
	
	# makes ledge grabbing false if the player is not ledge grabbing
	#if not velocity.y==0 and is_on_floor():
		#ledge_grab=false
	
	if is_on_floor() or (not is_on_floor() and not velocity.y==0):
		ledge_grab=false
	
	# Alternative handling of ledge grabbibg
	
	if down_raycast.is_colliding() and not up_raycast.is_colliding() and not is_on_floor() and velocity.y>=0:
		print ("ledge")
		velocity.y=0
		ledge_grab=true
		if not is_on_wall():
			if facing_right:
				position.x+=1
			else:
				position.x-=1
		
		# Lets the player jump and drop out of a ledge grab
		#needs editing
	if ledge_grab == true:
		velocity.y=0
		
		if Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_accept"):
			ledge_grab=false
			velocity += get_gravity() * delta
		if Input.is_action_pressed("ui_accept") and not Input.is_action_pressed("ui_down"):
			ledge_grab=false
			ledge_drop=true
	
	if ledge_drop==true and is_on_wall():
		velocity.y=JUMP_VELOCITY
		ledge_drop=false

	
	if is_on_floor():
		ledge_drop=false
	
	
	# Handles jump
	if Input.is_action_just_pressed("ui_accept") and grounded>0 and not ledge_grab and ledge_grab==false:
		velocity.y = JUMP_VELOCITY
		print(ledge)
		# Trying to get the shifting jump to be slightly faster than shifting speed
		if current_speed==shift_speed:
			current_speed=80
		
	# Makes jump height depend on how long user holds space
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y = -30
		
	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and not ledge_grab:
		velocity.x = direction * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		
	# Handles the sprites direction, depending on velocity
	# Handles running animation playing while player is grounded and moving
	if Input.is_action_pressed("ui_left") and is_on_floor() and velocity.x < 0:
		animated_sprite_2d.speed_scale=1
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.animation = "walk"
		down_raycast.position.x=-7
		up_raycast.position.x=-7
		facing_right=false
	if Input.is_action_pressed("ui_right") and is_on_floor() and velocity.x > 0:
		animated_sprite_2d.speed_scale=1
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.animation = "walk"
		down_raycast.position.x=7
		up_raycast.position.x=7
		facing_right=true
	if not is_on_floor() or velocity.x == 0:
		animated_sprite_2d.animation = "idle"
	if Input.is_action_pressed("Shift") and (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
		animated_sprite_2d.speed_scale=.45


	move_and_slide()
