extends Node2D
class_name Minas

@export var spawn_radius: float = 150.0
@export var radio: float = 20.0   # debug

func _ready() -> void:
	var prota_pos = GameState.player_position
	var ang  = randf() * TAU
	var dist = randf() * spawn_radius
	global_position = prota_pos + Vector2(cos(ang), sin(ang)) * dist
	print("💣 Mina plantada en ", global_position)

func _draw() -> void:
	draw_circle(Vector2.ZERO, radio, Color.RED)
