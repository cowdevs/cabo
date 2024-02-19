extends AnimatedSprite2D

func _process(_delta):
	if $"../..".face == 'FRONT':
		frame = $"../..".value
		$".".show()
	elif $"../..".face == 'BACK':
		$".".hide()
