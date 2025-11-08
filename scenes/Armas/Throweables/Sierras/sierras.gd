extends Node2D

@export var damage: float = 20.0
@export var radio_orbita: float = 100.0
@export var velocidad_giro: float = 2.0
@export var fuerza_empuje: float = 200.0

var sprite: AnimatedSprite2D
var area: Area2D
var jugador: CharacterBody2D
var angulo: float = 0.0

func _ready() -> void:
	z_index = 10
	
	jugador = get_tree().get_first_node_in_group("player")
	sprite = get_node("AnimatedSprite2D")
	area = get_node("Area2D")
	
	if area:
		area.body_entered.connect(_on_toca_enemigo)
	
	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("default"):
		sprite.play("default")

func _process(delta: float) -> void:
	if not jugador:
		return
	
	angulo += velocidad_giro * delta
	var offset = Vector2(cos(angulo), sin(angulo)) * radio_orbita
	global_position = jugador.global_position + offset
	
	if sprite:
		sprite.rotation += velocidad_giro * delta * 3

func _on_toca_enemigo(body: Node2D) -> void:
	if body.is_in_group("enemigo") and body.has_method("take_damage"):
		body.take_damage(damage)
		
		if body is CharacterBody2D:
			var direccion = (body.global_position - global_position).normalized()
			body.velocity += direccion * fuerza_empuje
