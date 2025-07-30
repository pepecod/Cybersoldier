extends "res://scripts/proyectilbase.gd"
class_name Perdigon


@export var dispersion_aleatoria: float = 0.15
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	direccion = direccion.rotated(randf_range(-dispersion_aleatoria, dispersion_aleatoria))
	rotation = direccion.angle()
	anim_sprite.play("vuelo")
	super._ready()

func get_daño() -> float:
	return daño+1000
