extends CharacterBody2D

#Separate animation for Landing

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")
enum PlayerState {STATE_IDLE, STATE_WALK, STATE_FALL, STATE_CROUCH}
var State: PlayerState= PlayerState.STATE_FALL;
var keepplayanim:bool = true;

func _process(delta):
	
	pass

func _ready():
	pass

func _physics_process(delta):
	match(State):
		PlayerState.STATE_IDLE:
			velocity.x = 0
			if keepplayanim:
				anim.play("Idle")
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				State=PlayerState.STATE_FALL
				keepplayanim=true;
			elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				State=PlayerState.STATE_WALK
				keepplayanim=true;
			if Input.is_action_just_pressed("ui_down"):
				State=PlayerState.STATE_CROUCH
				keepplayanim=true;
				
		PlayerState.STATE_WALK:
			if keepplayanim:
				anim.play("Walk")
			var direction = Input.get_axis("ui_left", "ui_right")
			if direction == -1:
				get_node("AnimatedSprite2D").flip_h = true
			elif direction == 1:
				get_node("AnimatedSprite2D").flip_h = false
			velocity.x = direction * SPEED
			if !direction:
				State=PlayerState.STATE_IDLE
				keepplayanim=true;
			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_VELOCITY
				State=PlayerState.STATE_FALL
				keepplayanim=true;
			if Input.is_action_just_pressed("ui_down"):
				State=PlayerState.STATE_CROUCH
				keepplayanim=true;
			
		PlayerState.STATE_FALL:
			##If using springs, remember to check if player pressed jump
			if velocity.y < 0:
				if keepplayanim:
					anim.play("Jump")
			else:
				if keepplayanim:
					anim.play("Fall")
			if not is_on_floor():
				velocity.y += gravity * delta
			else:
				State=PlayerState.STATE_IDLE
				keepplayanim=true;
		PlayerState.STATE_CROUCH:
			if keepplayanim:
				anim.play("Crouch")
			
			if !Input.is_action_pressed("ui_down"):
				State=PlayerState.STATE_IDLE
				keepplayanim=true;
		_:
			pass
	
	# Add the gravity.
#	if not is_on_floor():
#		velocity.y += gravity * delta
#
#	# Handle Jump.
#	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
#		velocity.y = JUMP_VELOCITY
#		anim.play("Jump")
#		print("jump")
#	#Do Crouch
#	if Input.is_action_just_pressed("ui_down") and is_on_floor():
#		print("crouch")
#		anim.play("Crouch")
#
#	# Get the input direction and handle the movement/deceleration.
#	# As good practice, you should replace UI actions with custom gameplay actions.
#	#var direction2 = Input.get_axis("ui_up", "ui_down")
#	var direction = Input.get_axis("ui_left", "ui_right")
#	if direction == -1:
#		get_node("AnimatedSprite2D").flip_h = true
#	elif direction == 1:
#		get_node("AnimatedSprite2D").flip_h = false
#	if direction:
#		velocity.x = direction * SPEED
#		if velocity.y == 0:
#			anim.play("Walk")
#
#	else:
#		velocity.x = move_toward(velocity.x, 0, SPEED)
#		if velocity.y == 0 and velocity.x == 0 and not Input.is_action_pressed("ui_down"):
#			anim.play("Idle")
#
#	if velocity.y > 0:
#		anim.play("Fall")
#		print("fall")
#

	move_and_slide()


func _on_animation_player_animation_finished(anim_name):
	match(State):
		PlayerState.STATE_CROUCH:
			keepplayanim=false;
		PlayerState.STATE_IDLE:
			keepplayanim=false;
		PlayerState.STATE_WALK:
			keepplayanim=true;
		PlayerState.STATE_FALL:
			keepplayanim=false;
		_:
			pass # Replace with function body.
