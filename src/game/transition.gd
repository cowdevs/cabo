extends CanvasLayer

const DELAY := 0.05

func change_scene(path: String) -> void:
	show()
	for column in $Row.get_children():
		column.get_node('AnimationPlayer').play_backwards("fade")
		column.get_node('AnimationPlayer').speed_scale = 0
	for column in $Row.get_children():
		column.get_node('AnimationPlayer').speed_scale = 1.0
		await get_tree().create_timer(DELAY).timeout
	await $Row.get_child(5).get_node('AnimationPlayer').animation_finished
	get_tree().change_scene_to_file(path)
	for column in $Row.get_children():
		column.get_node('AnimationPlayer').play("fade")
		column.get_node('AnimationPlayer').speed_scale = 0
	for column in $Row.get_children():
		column.get_node('AnimationPlayer').speed_scale = 1.0
		await get_tree().create_timer(DELAY).timeout
	await $Row.get_child(5).get_node('AnimationPlayer').animation_finished
	hide()
