extends Node
class_name Health

signal hp_depleted()

var max_hp = 100
var current_hp = max_hp
var damage = 10

func _ready():
	pass # Replace with function body.

func lose_hp():
	current_hp -= damage
	current_hp = clamp(current_hp,0,max_hp)
	if current_hp == 0:
		emit_signal("hp_depleted")

func gain_hp(amount):
	current_hp += amount
	current_hp = clamp(current_hp,0,max_hp)

