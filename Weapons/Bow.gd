extends Node2D

onready var arrow_proto = $ArrowPrototype
onready var arrows_parent = $Arrows
onready var explosion_proto = $Explosion
onready var explosions_parent = $Explosions
var arrows = []
export var facing = "right" setget set_facing

func _ready():
	arrow_proto.set_process(false)

func set_facing(new_facing):
	facing = new_facing
	if facing == "right":
		rotation = 0
	else:
		rotation = PI
func attack():
	shoot()
func shoot():
	var arrow = arrow_proto.duplicate(1)
	arrow.visible = true
	arrow.global_position = global_position
	arrow.rotation = rotation
	var arrow_vel = Vector2(180, 0)
	if facing == "left":
		arrow_vel *= -1
	arrow.linear_velocity = arrow_vel
	var arrow_entry = {obj = arrow, life = 3}
	arrows.append(arrow_entry)
	arrows_parent.add_child(arrow)
	var hit_detector = arrow.get_node("HitDetector")
	hit_detector.connect("body_entered", self, "_on_body_entered", [arrow_entry])
	
func is_main_scene():
	return get_parent() == get_tree().root

func age_arrows(delta):
	var to_delete = []
	for arrow_ix in range(arrows.size()):
		var arrow = arrows[arrow_ix]
		arrow.life -= delta
		if arrow.life <= 0:
			to_delete.append(arrow_ix)
	for delete_ix in to_delete:
		var arrow = arrows[delete_ix]
		arrows.remove(delete_ix)
		arrow.obj.queue_free()

func prune_explosions():
	if !explosions_parent.get_children():
		for explosion in explosions_parent.get_children():
			if !explosion.emitting:
				explosion.queue_free()

func _process(delta):
	if is_main_scene():
		if Input.is_action_just_released("action"):
			shoot()
	age_arrows(delta)
	prune_explosions()


func _on_body_entered(body, arrow_entry):
	if body.name == "Demon":
		arrow_entry.life = 0
		var explosion = explosion_proto.duplicate(0)
		explosion.emitting = true
		explosion.visible = true
		explosion.global_position = arrow_entry.obj.global_position
		explosions_parent.add_child(explosion)
		body.getHit(10)

