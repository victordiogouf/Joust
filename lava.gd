extends Area2D

signal lava_hit


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		lava_hit.emit()
