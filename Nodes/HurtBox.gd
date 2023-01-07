class_name HurtBox, "res://Icons/icon3.png"
extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	
func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox == null:
		return
	
	if hitbox.owner.parent != owner:
		if hitbox.grab:
			if owner.has_method("get_grabbed"):
				owner.get_grabbed(hitbox.owner)
		else:
			if owner.has_method("take_damage"):
				hitbox.angle = hitbox.owner.global_position.direction_to(owner.global_position)
				owner.take_damage(hitbox,hitbox.damage,hitbox.angle,hitbox.base_knockback)

