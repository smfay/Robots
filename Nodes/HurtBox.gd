class_name HurtBox, "res://Icons/icon3.png"
extends Area2D

func _init() -> void:
	collision_layer = 0
	collision_mask = 2

func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	var groups = owner.get_groups()
	for group in groups:
		add_to_group(group)
	
func _on_area_entered(hitbox: HitBox) -> void:
	if hitbox == null:
		return
	
	if !hitbox.is_in_group(owner.get_groups()[0]):
		if hitbox.grab:
			if owner.has_method("get_grabbed"):
				owner.get_grabbed(hitbox.owner)
		else:
			if owner.has_method("take_damage"):
				var hit_x_avg = (hitbox.global_position.x + global_position.x) / 2
				var hit_y_avg = (hitbox.global_position.y + global_position.y) / 2
				var hit_location := Vector2(hit_x_avg,hit_y_avg)
				hitbox.angle = hitbox.global_position.direction_to(global_position)
				owner.take_damage(hitbox,hitbox.damage,hitbox.angle,hitbox.base_knockback)
				GameManager.fx.create_effect(hit_location,GameManager.fx.hit_flash)

