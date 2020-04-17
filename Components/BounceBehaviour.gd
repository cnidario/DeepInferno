extends Node
class_name BounceBehaviour

onready var animation_player = $AnimationPlayer

export (NodePath) var target = NodePath("ColorRect")
export (String) var property = "position:x"

var status = "end"

func createAnimationPlayer():
	animation_player = AnimationPlayer.new()
	self.add_child(animation_player)
	# animation_player.root_node

func _ready():
	#createAnimationPlayer()
	var target_node = get_node(target)
	var anim = animation_player.get_animation("bounce") #Animation.new()
	var track_index = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_index, str(target_node.get_path()) + ":" + property)
	anim.track_insert_key(track_index, 0.0, 0)
	anim.track_insert_key(track_index, 0.5, 100)
	#track_index = anim.add_track(Animation.TYPE_METHOD)
	#anim.track_set_path(track_index, ".")
	#anim.track_insert_key(track_index, 0.0, {"method" : "bounce_started" , "args" : []})
	#anim.track_insert_key(track_index, 1.0, {"method" : "bounce_finished" , "args" : []})
	#animation_player.add_animation("bounce", anim)

func bounce():
	if status == "end":
		status = "start"
		animation_player.play("bounce")
	
func bounce_started():
	print("bounce started")
	pass
func bounce_finished():
	status = "end"
