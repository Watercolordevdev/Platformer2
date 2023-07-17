extends CharacterBody2D

class_name Player

#Separate animation for Landing
#Change hitbox when crouching

@export var Mushroom : PackedScene

signal enemy_hit
var health = 10
const WALKSPEED = 100.0
const RUNSPEED = 200.0
const JUMP_VELOCITY = -350.0

# Get the gravity from the project settings to be synced with RigidBody nodes.

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var anim = $"AnimationPlayer"
@export var Doublejump : PackedScene
enum PlayerState {STATE_IDLE, STATE_WALK, STATE_FALL, STATE_CROUCH, STATE_THROW, STATE_RUN}
var State: PlayerState= PlayerState.STATE_FALL;
var keepplayanim:bool = true;
var jumps: int = 0;
var align_speed = 57;
var facingright = true;
var cansprint = false;

func ready():
	if health <= 0:
			queue_free()
			get_tree().change_scene_to_file("res://main.tscn")

func shoot():
	var mush = Mushroom.instantiate()
	get_tree().root.add_child(mush)
	mush.transform = $Hoof.global_transform
	if facingright:
		mush.direction=Vector2.RIGHT
		
	else:
		mush.direction=Vector2.LEFT
		mush.get_node("Tinymushroom").flip_h = true;

func transition_to_state(newState: PlayerState):
# This is the list of things that need to happen only once for a state, when transitioning to that state
	match(newState):
		PlayerState.STATE_IDLE:
			print("Idle")
			anim.play("Idle")
		PlayerState.STATE_CROUCH:
			anim.play("Crouch")
		PlayerState.STATE_THROW:
			anim.play("Mushroom Throw")
		_:
			pass
	State = newState

func _rotateground(delta):
		var normal2 = $Rightraycast.get_collision_normal()
		var normal1 = $Middleraycast.get_collision_normal()
		var normal3 = $Leftraycast.get_collision_normal()
		var averagenormal = (normal1 + normal2 + normal3)/3
		
		if is_on_floor():
			$AnimatedSprite2D.rotation = lerp(rotation, averagenormal.angle() + PI/2, align_speed * delta)
		pass

func jumpeffect():
	var je = Doublejump.instantiate()
	je.position = self.position
	var flip = $AnimatedSprite2D.flip_h
	if flip == true:
		je.scale.x = -.5
	get_parent().add_child(je)
	print("puff")
	return

func _physics_process(delta):
	velocity.y += delta * gravity
	_rotateground(delta)
	
	if is_on_wall():
		print("Wall!")
		print(get_wall_normal())
	
	if is_on_floor():
		jumps =0
	
	if not is_on_floor():
		transition_to_state(PlayerState.STATE_FALL)
	
	match(State):
		PlayerState.STATE_IDLE:
			velocity.x = 0
			if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP_VELOCITY
				transition_to_state(PlayerState.STATE_FALL)
			elif Input.is_action_pressed("throw"):
					transition_to_state(PlayerState.STATE_THROW)
			elif Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
				transition_to_state(PlayerState.STATE_WALK)
			elif Input.is_action_just_pressed("crouch"):
				transition_to_state(PlayerState.STATE_CROUCH)
			if cansprint:
				if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
					transition_to_state(PlayerState.STATE_RUN)

		PlayerState.STATE_WALK:
			anim.play("Walk")
			cansprint = true;
			$Timer.start()
			_direction()			
			var direction = Input.get_axis("left", "right")
			if !direction:
				transition_to_state(PlayerState.STATE_IDLE)
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				transition_to_state(PlayerState.STATE_FALL)
			if Input.is_action_just_pressed("crouch"):
				transition_to_state(PlayerState.STATE_CROUCH)
			if Input.is_action_just_pressed("throw"):
					transition_to_state(PlayerState.STATE_THROW)
			

		PlayerState.STATE_RUN:
			print("I am running")
			anim.play("Run")
			_direction()
			var direction = Input.get_axis("left", "right")
			if !direction:
				transition_to_state(PlayerState.STATE_IDLE)
			if Input.is_action_just_pressed("jump"):
				velocity.y = JUMP_VELOCITY
				transition_to_state(PlayerState.STATE_FALL)
			
		PlayerState.STATE_FALL:
			_direction()
			##If using springs, remember to check if player pressed jump
			if Input.is_action_just_pressed("jump") && jumps < 1:
				jumps +=1
				if jumps == 0:
					velocity.y = JUMP_VELOCITY
					jumpeffect()
				else:
					velocity.y = JUMP_VELOCITY*0.5
					jumpeffect()
			if velocity.y < 0:	
				anim.play("Jump")
			else:
				anim.play("Fall")
			if is_on_floor():
				transition_to_state(PlayerState.STATE_IDLE)

		PlayerState.STATE_CROUCH:
			if !Input.is_action_pressed("crouch"):
					transition_to_state(PlayerState.STATE_IDLE)
		_:
			pass
		
		PlayerState.STATE_THROW:
			pass
		_:
			pass
	
func _direction():
	var direction = Input.get_axis("left", "right")
	if direction == -1:
		facingright = false;
		get_node("AnimatedSprite2D").flip_h = true
		var hoof = get_node("Hoof") as Node2D
		hoof.position.x = -18
	elif direction == 1:
		facingright = true;
		get_node("AnimatedSprite2D").flip_h = false
		var hoof = get_node("Hoof") as Node2D
		hoof.position.x = 18
	if State==PlayerState.STATE_WALK:
		velocity.x = direction * WALKSPEED
	if State==PlayerState.STATE_RUN:
		velocity.x = direction * RUNSPEED

	move_and_slide()


func _on_hitbox_body_entered(body):
	if body is Frog:
		take_damage()

func take_damage():
	health -= 3
	print (health)

func _on_animation_player_animation_finished(anim_name):
	print(anim_name)
	match(anim_name):
		"Mushroom Throw":
			transition_to_state(PlayerState.STATE_IDLE)
	pass # Replace with function body.

func _on_timer_timeout():
	cansprint=false;
