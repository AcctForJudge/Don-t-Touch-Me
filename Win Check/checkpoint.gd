class_name Checkpoint
extends Area2D



## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#position = position.snapped(Vector2.ONE * 64) + Vector2.ONE * 32


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


#func _on_area_entered(area: Area2D) -> void:
	#var pl = area.get_parent() as Player
	#print(area, pl.name)
	#if pl == winner:
		#complete = true
		#pl.completed = true
		#pl.tween_to(position)
	#
