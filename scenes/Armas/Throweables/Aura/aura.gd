# Aura.gd
extends Node2D
class_name Aura

@export var damage_amount: int = 5
@export var animation_name: String = "default"

@onready var sprite_top: AnimatedSprite2D   = $AnimatedSprite2D
@onready var sprite_bot: AnimatedSprite2D  = $AnimatedSprite2D2
@onready var area2d: Area2D                 = $Area2D

func _ready() -> void:
	# 1) Al instanciarla como hija del Prota, mantenemos su posición local a (0,0)
	position = Vector2.ZERO

	# 2) Arrancar ambas animaciones en bucle si existen
	if sprite_top.frames.has_animation(animation_name):
		sprite_top.play(animation_name)
		sprite_top.frames.set_animation_loop(animation_name, true)
	if sprite_bot.frames.has_animation(animation_name):
		sprite_bot.play(animation_name)
		sprite_bot.frames.set_animation_loop(animation_name, true)

	# 3) Conectar señal para dañar a quien entre al área
	area2d.body_entered.connect(Callable(self, "_on_area_body_entered"))

func _process(_delta: float) -> void:
	# 4) Asegurarnos de que la posición local siempre sea el origen del padre
	position = Vector2.ZERO

func _on_area_body_entered(body: Node) -> void:
	# 5) Si es enemigo y puede recibir daño, le aplicamos damage_amount
	if body.is_in_group("enemigo") and body.has_method("recibir_daño"):
		body.recibir_daño(damage_amount)
