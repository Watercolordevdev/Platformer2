extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")
enum PlayerState {STATE_IDLE, STATE_WALK, STATE_FALL}
var State: PlayerState= PlayerState.STATE_IDLE;

func _process(delta):
	
	pass

func _ready():
	pass

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim.play("Jump")
		print("jump")
	#Do Crouch
	if Input.is_action_just_pressed("ui_down") and is_on_floor():
		print("crouch")
		anim.play("Crouch")

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#var direction2 = Input.get_axis("ui_up", "ui_down")
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
	if direction:
		velocity.x = direction * SPEED
		if velocity.y == 0:
			anim.play("Walk")
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0 and velocity.x == 0 and not Input.is_action_pressed("ui_down"):
			anim.play("Idle")
			#match (PlayerState)
		
	if velocity.y > 0:
		anim.play("Fall")
		print("fall")
		

	move_and_slide()
