extends ParallaxBackground

func _process(delta):
	$ParallaxLayer.motion_offset.y += 25 * delta
