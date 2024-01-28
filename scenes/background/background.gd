extends ParallaxLayer

@export var speed: int

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.motion_offset.y += speed * delta
