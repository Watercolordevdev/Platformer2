extends CharacterBody2D

var SPEED = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = false

func _physics_process(delta):
	velocity.y += gravity * delta
	if chase:
		if get_node("AnimatedSprite2D").animation != "Death":
			get_node("AnimatedSprite2D").play("Jump")
		player = $"../../Player"
		var direction = (player.global_position - self.global_position).normalized()
		if direction.x > 0:		
			get_node("AnimatedSprite2D").flip_h = true
		else:
			get_node("AnimatedSprite2D").flip_h = false
		velocity.x = direction.x * SPEED
	else:
		if get_node("AnimatedSprite2D").animation != "Death":
			get_node("AnimatedSprite2D").play("Idle")
		velocity.x = 0
	move_and_slide()

func _ready():
	get_node("AnimatedSprite2D").play("Idle")

func _on_player_detection_body_entered(body):
	if body is Player:
		chase = true
		
func _on_player_detection_body_exited(body):		
	if body is Player:
		chase = false
#
#func _on_player_death_body_entered(body):
#	if body is Player:
#		death()
#
#
#
#func _on_player_collision_body_entered(body):
#	if body is Player:
#		print("playerdamage")
#		body.health -= 3
#		death()
#
#func death():
#	chase = false
#	get_node("AnimatedSprite2D").play("Death")
#	await get_node("AnimatedSprite2D").animation_finished
#	self.queue_free()
#
#func _on_player_death_2_body_exited(body):
#	pass # Replace with function body.



func _on_frog_death_body_entered(body):
	print("froggy die")
	pass # Replace with function body.


func _on_frog_death_body_exited(body):
	pass # Replace with function body.


func _on_player_death_2_body_entered(body):
	print("player die")
	pass # Replace with function body.


func _on_player_death_2_body_exited(body):
	pass # Replace with function body.
