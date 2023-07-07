extends CharacterBody2D

var SPEED = 50
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player
var chase = false

func _physics_process(delta):
	velocity.y += gravity * delta
	if chase == true:
		if get_node("AnimatedSprite2D").animation != "Death":
			get_node("AnimatedSprite2D").play("Jump")
		player = $"../../Player"
		var direction = (player.global_position - self.global_position).normalized()
		if direction.x > 0:		
			get_node("AnimatedSprite2D").flip_h = true
			print("Right")
		else:
			get_node("AnimatedSprite2D").flip_h = false
			print("Left")
		velocity.x = direction.x * SPEED
	else:
		if get_node("AnimatedSprite2D").animation != "Death":
			get_node("AnimatedSprite2D").play("Idle")
		velocity.x = 0
	move_and_slide()

func _ready():
	get_node("AnimatedSprite2D").play("Idle")

func _on_player_detection_body_entered(body):
	if body.name == "Player":
		chase = true
		
func _on_player_detection_body_exited(body):		
	if body.name == "Player":
		chase = false

func _on_player_death_body_entered(body):
	if body.name == "Player":
		chase = false
		get_node("AnimatedSprite2D").play("Death")
		await get_node("AnimatedSprite2D").animation_finished
		self.queue_free()


func _on_player_death_body_exited(body):
	pass # Replace with function body.
