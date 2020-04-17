extends KinematicBody2D

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var state_machine = $AnimationTree.get("parameters/playback")
onready var peace_timer = $PeaceTimer

var attacking = false

func _ready():
	state_machine.start("relax")
func peaceTimerTimeout():
	state_machine.travel("relax")
func attack():
	state_machine.travel("attack")
	peace_timer.start()

func _physics_process(delta):
	pass
func attack_peak():
	attacking = false
func attack_started():
	attacking = true
func on_body_entered(body):
	if attacking:
		if body.name == "Demon":
			body.getHit()
