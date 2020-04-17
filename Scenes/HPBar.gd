extends Node2D

export var maxhp: int = 100
export var hp: int = 100

onready var hp_rect = $HPRect
onready var tween = $Tween

const MAX_SZ = 20

func setHP(newhp):
	var target_x = (newhp / float(maxhp)) * MAX_SZ
	var src = hp_rect.rect_size
	var dst = Vector2(target_x, hp_rect.rect_size.y)
	tween.interpolate_property(hp_rect, "rect_size",
		src, dst, 1,
		Tween.TRANS_BOUNCE, Tween.EASE_IN_OUT)
	tween.start()
	hp = newhp

