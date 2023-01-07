extends CanvasLayer
onready var menu = $MenuOptions


# Called when the node enters the scene tree for the first time.
func _ready():
	set_visibility(false)
	$MenuOptions/FilterButton.set_pressed_no_signal(true)


func _input(event):
	if event.is_action_pressed("pause"):
		set_visibility(!get_tree().paused)
		$MenuOptions/Resume.grab_focus()
		get_tree().paused = !get_tree().paused


func _on_Resume_pressed():
	get_tree().paused = false
	set_visibility(false)


func set_visibility(is_visible) -> void:
	for node in get_children():
		node.visible = is_visible
