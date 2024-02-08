extends AnimatedSprite2D

func _process(_delta):
	if $"../..".face == 'Front':
		z_index = 0
		frame = $"../..".value
	elif $"../..".face == 'Back':
		z_index = -1

