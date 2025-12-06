extends ProyectilBase
class_name Perdigon

@export var dispersion_aleatoria: float = 0.15
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	super._ready()

func resetear() -> void:
	if direccion != Vector2.ZERO:
		rotation = direccion.angle()
	
	if anim_sprite:
		anim_sprite.play("vuelo")

func get_daño() -> float:
	return daño
