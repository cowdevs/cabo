extends AnimatedSprite2D


func _process(_delta):
	if $"../..".face == 'Front':
		self.frame = $"../..".value
	elif $"../..".face == 'Back':
		self.frame = 1

