extends Area2D

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	pass

func _on_body_entered(body):
	if body.name == "Player":
		print("guaje vas cayer")
		body.fall()
