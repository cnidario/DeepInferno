extends Node2D

onready var arrow_proto = $ArrowPrototype
onready var arrows_parent = $Arrows
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
	arrows.append({obj = arrow, life = 3})
	arrows_parent.add_child(arrow)
	var hit_detector = arrow.get_node("HitDetector")
	hit_detector.connect("body_entered", self, "_on_body_entered", [arrows.size() - 1])
	
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

func _process(delta):
	if is_main_scene():
		if Input.is_action_just_released("action"):
			shoot()
	age_arrows(delta)


func _on_body_entered(body, arrow_ix):
	print("body entered")
	print(body.name)
	if body.name == "Demon":
		var arrow = arrows[arrow_ix]
		arrows.remove(arrow_ix)
		arrow.obj.queue_free()
		body.getHit(10)

