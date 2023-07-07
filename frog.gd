extends CharacterBody2D

var SPEED = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = false

func _physics_process(delta):
	velocity.y += gravity * delta
	if chase == true:
		player = $"../../Player"
		var direction = (player.global_position - self.global_position).normalized()
		if direction.x > 0:		
			get_node("AnimatedSprite2D").flip_h = true
			print(player.global_position)
			print("Right")
		else:
			get_node("AnimatedSprite2D").flip_h = false
			print(player.global_position)
			print("Left")


func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true
		
func _on_player_detection_body_exited(body):		
	if body.name == "Player":
		chase = false
		
		
		
		

