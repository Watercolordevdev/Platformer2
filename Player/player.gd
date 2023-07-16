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
var jumps: int = 0;
var align_speed = 57;


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

func _rotateground(delta):
		var normal = $Middleraycast.get_collision_normal()
		#rotation = normal.angle() + deg_to_rad(90)
		if is_on_floor():
			$Hitbox.rotation = lerp(rotation, get_floor_normal().angle() + PI/2, align_speed * delta)
			$AnimatedSprite2D.rotation = lerp(rotation, get_floor_normal().angle() + PI/2, align_speed * delta)
		pass



func _physics_process(delta):
	velocity.y += delta * gravity
	_rotateground(delta)
	
	if is_on_wall():
		print("Wall!")
		print(get_wall_normal())
		
	
	if is_on_floor():
		jumps =0
	
	if not is_on_floor():
		State=PlayerState.STATE_FALL
	
	match(State):
		PlayerState.STATE_IDLE:
			velocity.x = 0
			anim.play("Idle")
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				State=PlayerState.STATE_FALL
			elif Input.is_action_just_pressed("ui_left") or Input.is_action_just_pressed("ui_right"):
				State=PlayerState.STATE_WALK
			if Input.is_action_just_pressed("ui_down"):
				State=PlayerState.STATE_CROUCH
#			if abs(get_floor_angle())<deg_to_rad(50):
#				var normal = $Middleraycast.get_collision_normal()
#				rotation = normal.angle() + deg_to_rad(90)
		

				
		PlayerState.STATE_WALK:
			anim.play("Walk")
			_direction()			
			if is_on_ceiling():
				print(up_direction)
				pass
			
#			if get_floor_angle()!=0:
#					var floorangle = get_floor_angle()
#					rotation=(lerpf(rotation, -floorangle, 0.45))
#					if $Middleraycast.is_colliding():
#						apply_floor_snap()
#			if get_floor_angle()==0:
#				rotation=(0)
#			if abs(get_floor_angle())<50:
#				var normal = $Middleraycast.get_collision_normal()
#				rotation = normal.angle() + deg_to_rad(90)
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
			
			if Input.is_action_just_pressed("ui_accept") && jumps < 1:
				jumps +=1
				velocity.y = JUMP_VELOCITY
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
	

	move_and_slide()


func _on_hitbox_body_entered(body):
	if body is Frog:
		take_damage()

func take_damage():
	health -= 3
	print (health)



