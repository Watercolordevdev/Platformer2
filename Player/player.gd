extends CharacterBody2D

class_name Player

#Separate animation for Landing

signal enemy_hit
var health = 10
const SPEED = 300.0
const JUMP_VELOCITY = -450.0

# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = get_node("AnimationPlayer")
enum PlayerState {STATE_IDLE, STATE_WALK, STATE_FALL, STATE_CROUCH}
var State: PlayerState= PlayerState.STATE_FALL;
var keepplayanim:bool = true;


func ready():
	if health <= 0:
			queue_free()
			get_tree().change_scene_to_file("res://main.tscn")

func transition_to_state(newState: PlayerState):
# This is the list of things that need to happen only once for a state, when transitioning to that state
	match(newState):
		PlayerState.STATE_IDLE:
			anim.play("Idle")
		PlayerState.STATE_CROUCH:
			anim.play("Crouch")
		_:
			pass
	State = newState


func _physics_process(delta):
	velocity.y += delta * gravity
	
	if not is_on_floor():
		State=PlayerState.STATE_FALL
	
	match(State):
		PlayerState.STATE_IDLE:
			velocity.x = 0
			var normal = $Middleraycast.get_collision_normal()
			rotation = normal.angle() + deg_to_rad(90)
			anim.play("Idle")
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				State=PlayerState.STATE_FALL

			elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				State=PlayerState.STATE_WALK

			if Input.is_action_just_pressed("ui_down"):
				State=PlayerState.STATE_CROUCH

				
		#Do I need to normalize my move_direction?
		PlayerState.STATE_WALK:

			anim.play("Walk")
			_direction()
			
			if is_on_ceiling():
				print(up_direction)
				pass
			if get_floor_angle()!=0:
					print("slope!")
					print(rad_to_deg(get_floor_angle()))
					var floorangle = get_floor_angle()
					rotation=(lerpf(rotation, -floorangle, 0.45))
					if $Middleraycast.is_colliding():
						apply_floor_snap()
			if get_floor_angle()==0:
				rotation=(0)
#			if get_floor_angle()>=75:
#				State=PlayerState.STATE_IDLE
			var direction = Input.get_axis("ui_left", "ui_right")
			if !direction:
				State=PlayerState.STATE_IDLE

			if Input.is_action_just_pressed("ui_accept"):
				velocity.y = JUMP_VELOCITY
				State=PlayerState.STATE_FALL

			if Input.is_action_just_pressed("ui_down"):
				State=PlayerState.STATE_CROUCH
	
			
		PlayerState.STATE_FALL:
			_direction()
			##If using springs, remember to check if player pressed jump
			if velocity.y < 0:
	
				anim.play("Jump")
			else:

				anim.play("Fall")
			if is_on_floor():
				State=PlayerState.STATE_IDLE

				
		PlayerState.STATE_CROUCH:
	
				anim.play("Crouch")
				if !Input.is_action_pressed("ui_down"):
					State=PlayerState.STATE_IDLE
	
		_:
			pass
	
func _direction():
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction == -1:
		get_node("AnimatedSprite2D").flip_h = true
	elif direction == 1:
		get_node("AnimatedSprite2D").flip_h = false
	velocity.x = direction * SPEED
	
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


#func _on_animation_player_animation_finished(_anim_name):
#	match(State):
#		PlayerState.STATE_CROUCH:
#			keepplayanim=false;
#		PlayerState.STATE_IDLE:
#			keepplayanim=false;
#		PlayerState.STATE_WALK:
#			keepplayanim=true;
#		PlayerState.STATE_FALL:
#			keepplayanim=false;
#		_:
#			pass


func _on_hitbox_body_entered(body):
	if body is Frog:
		take_damage()

func take_damage():
	health -= 3
	print (health)



