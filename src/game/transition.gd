extends CanvasLayer

const DELAY := 0.05

signal transitioned

func change_scene(path: String) -> void:
	show()
	fade_out()
	await transitioned
	get_tree().change_scene_to_file(path)
	fade_in()
	await transitioned
	hide()

func fade_in() -> void:
	for column in $Row.get_children():
		column.get_node('AnimationPlayer').play("fade_in")
		column.get_node('AnimationPlayer').speed_scale = 0.1
	
	for column in $Row.get_children():
		column.get_node('AnimationPlayer').speed_scale = 1.0
		await get_tree().create_timer(DELAY).timeout
	
	await $Row.get_child(5).get_node('AnimationPlayer').animation_finished
	emit_signal("transitioned")

func fade_out() -> void:
	for column in $Row.get_children():
		column.get_node('AnimationPlayer').play("fade_out")
		column.get_node('AnimationPlayer').speed_scale = 0.1
	
	for column in $Row.get_children():
		column.get_node('AnimationPlayer').speed_scale = 1.0
		await get_tree().create_timer(DELAY).timeout
	
	await $Row.get_child(5).get_node('AnimationPlayer').animation_finished
	emit_signal("transitioned")
