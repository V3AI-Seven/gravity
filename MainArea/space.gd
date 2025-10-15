extends Node3D

func _ready() -> void:
	if Flags.debug_mode == true:
		$Debug.visible = true
	else:
		$Debug.visible = false
