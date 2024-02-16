extends AnimatedSprite2D

func _process(_delta):
	if $"../..".face == 'FRONT':
		z_index = 0
		frame = $"../..".value
	elif $"../..".face == 'BACK':
		z_index = -1

