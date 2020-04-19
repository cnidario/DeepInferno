extends KinematicBody2D

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var character = $Character
onready var shadow = $Shadow
onready var enemy_collider_detector = $EnemyColliderDetector

export var state: Dictionary = {
	moving = "idle",
	facing = "right",
	turning = false,
	falling = false,
	jumping = false,
	bouncing = 0,
}
const SPEED = 75
const ACCELERATION = 150
const EPSILON = 5
var velocity: Vector2 = Vector2.ZERO
var original_y
export var z = 0
var z_velocity = 0
const bouncing_velocities = [10, 30, 50, 70]
var weapon

onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	state_machine.start("idle")
	weapon = $Character/Hand/Sword
	original_y = character.position.y

func process_pseudoz(delta):
	z += z_velocity * delta
	if z < 0:
		z = 0
		z_velocity = 0
	z_velocity -= 300*delta

func process_jump(delta):
	process_pseudoz(delta)
	if z == 0:
		state.jumping = false

func process_bouncing(delta):
	process_pseudoz(delta)
	velocity = velocity - velocity.normalized()*20*delta
	if z == 0:
		z_velocity = bouncing_velocities[state.bouncing - 1]
		state.bouncing -= 1

func bounce(jump_vel, bounce_direction):
	state.bouncing = 3
	z_velocity = jump_vel
	velocity = bounce_direction*bouncing_velocities[3]

func jump():
	z_velocity = 100
	state.jumping = true

func fall():
	state.falling = true
	state_machine.stop()
	shadow.visible = false
	state_machine.travel("fall")

func turning_ended():
	state.turning = false

func get_input():
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(x, y).normalized()

func must_turn(old, new):
	if old == "right" and new == "left":
		return "turn-left"
	elif old == "left" and new == "right":
		return "turn-right"
	else:
		return false
func is_walking(st):
	return st != "idle"

func calc_movement(input: Vector2):
	if input.length_squared() < 0.1 * 0.1:
		return "idle"
	var alpha = input.angle()
	if alpha >= PI/4 and alpha <= (PI - PI/4):
		return "down"
	elif abs(alpha) >= (PI - PI/4):
		return "left"
	elif -alpha >= PI/4 and -alpha <= (PI - PI/4):
		return "up"
	else:
		return "right"
		
func attack():
	weapon.attack()
	
func _physics_process(delta):
	character.position.y = original_y
	var input = get_input()
	if Input.is_action_just_pressed("action"):
		attack()
	var new_moving_state = calc_movement(input)
	var turn_to = must_turn(state.facing, new_moving_state)
	if state.bouncing > 0:
		process_bouncing(delta)
	else:
		if enemy_collider_detector.get_overlapping_bodies().size() > 0:
			bounce(80, -velocity.normalized())
	if state.jumping:
		process_jump(delta)
	if state.turning or state.falling or state.bouncing != 0:
		pass
	else:
		if Input.is_action_just_pressed("jump") and !state.jumping:
			jump()
		if turn_to:
			state.facing = new_moving_state
			state.turning = true
			state_machine.travel(turn_to)
		elif is_walking(new_moving_state):
			state.moving = "walking"
			state_machine.travel("walk-cycle")
		elif state.moving != "idle":
			state_machine.travel("idle")
			state.moving = "idle"
	
	var new_velocity = velocity
	if state.falling:
		new_velocity = velocity - velocity * 1.8 * delta
	elif state.bouncing != 0:
		pass
	elif is_walking(new_moving_state):
		new_velocity = velocity + ACCELERATION * input * delta
		# cap max speed
		if new_velocity.length_squared() > SPEED*SPEED:
			new_velocity = new_velocity.normalized() * SPEED
	# deccelerate
	elif velocity.length_squared() > EPSILON*4:
		new_velocity = velocity - ACCELERATION * 2 * velocity.normalized() * delta
	else:
		new_velocity = Vector2.ZERO
	velocity = move_and_slide(new_velocity, Vector2(1, 0))
	
func _process(delta):
	original_y = character.position.y
	character.position.y -= z

