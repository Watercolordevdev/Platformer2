extends Area2D

var speed = 500
var direction = Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta
	

func _on_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("mobs"):
		body.frogdeath()
	queue_free()
