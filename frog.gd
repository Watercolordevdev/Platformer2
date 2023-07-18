extends CharacterBody2D

class_name Frog

var SPEED = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = false
@onready var froganim = $AnimatedSprite2D

func _physics_process(delta):
	velocity.y += gravity * delta
	if chase:
		if $AnimatedSprite2D.animation != "Death":
			$AnimatedSprite2D.play("Jump")
		player = $"../../Player"
		var direction = (player.global_position - self.global_position).normalized()
		if direction.x > 0:		
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		velocity.x = direction.x * SPEED
	else:
		if $AnimatedSprite2D.animation != "Death":
			$AnimatedSprite2D.play("Idle")
		velocity.x = 0
	move_and_slide()

func _ready():
	$AnimatedSprite2D.play("Idle")

func _on_player_detection_body_entered(body):
	if body is Player:
		chase = true
		
func _on_player_detection_body_exited(body):		
	if body is Player:
		chase = false
#
#
func frogdeath():
	chase = false
	$AnimatedSprite2D.play("Death")
	await $AnimatedSprite2D.animation_finished
	self.queue_free()
#
#
#func _on_frog_death_body_entered(body):
#	frogdeath()
#	pass # Replace with function body.



func _on_player_death_2_body_entered(body):
	if body is Player:
		body.take_damage()
		frogdeath()
	pass # Replace with function body.


func _on_player_death_2_body_exited(_body):
	pass # Replace with function body.
	

