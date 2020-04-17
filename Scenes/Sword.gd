extends KinematicBody2D

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var state_machine = $AnimationTree.get("parameters/playback")
onready var peace_timer = $PeaceTimer

var attacking = false

func _ready():
	state_machine.start("idle")
func peaceTimerTimeout():
	state_machine.travel("idle")
func attack():
	state_machine.travel("attack")
	peace_timer.start()

func _physics_process(delta):
	pass
func attack_peak():
	attacking = false
func attack_started():
	attacking = true
	
func is_on_hit_yaxis(body):
	var ydst = global_position.y - body.global_position.y
	return ydst <0 and ydst > -8

func on_body_entered(body):
	if attacking:
		print(attacking)
		if body.name == "Demon" and is_on_hit_yaxis(body):
			body.getHit()
