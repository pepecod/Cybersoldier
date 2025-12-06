# SniperBullet.gd
extends Area2D
class_name SniperBullet

@export var speed: float = 600.0
@export var damage: int = 100
@export var base_radius: float = 4.0
@export var radius_per_level: float = 2.0
@export var lifetime: float = 5.0

# Multiplicador de área desde el arma
var area_multiplicador: float = 1.0
var direction: Vector2 = Vector2.ZERO
var hit_enemies: Array[Node2D] = []

@export var level: int = 1

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var timer_vida: Timer = $TiempoVida

signal destruido()

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	timer_vida.wait_time = lifetime
	timer_vida.one_shot = true
	timer_vida.start()
	if not timer_vida.timeout.is_connected(_on_TiempoVida_timeout):
		timer_vida.timeout.connect(_on_TiempoVida_timeout)
	
	# Orientar el proyectil según la dirección
	if direction != Vector2.ZERO:
		rotation = direction.angle()
		animated_sprite.play("vuelo")
	else:
		var anims = animated_sprite.sprite_frames.get_animation_names()
		if anims.size() > 0:
			animated_sprite.play(anims[0])
	
	_ajustar_tamaño()
	print("Direction: ", direction)
	print("Rotation aplicada: ", direction.angle())
	print("Rotation del Area2D: ", rotation)
	print("Rotation del sprite: ", animated_sprite.rotation)

func set_level(value: int) -> void:
	level = value
	_ajustar_tamaño()

func _physics_process(delta: float) -> void:
	position += direction.normalized() * speed * delta

func _on_body_entered(body: Node) -> void:
	if not body.is_in_group("enemigo"):
		return
	if body in hit_enemies:
		return
	if body.has_method("take_damage"):
		body.take_damage(damage)
	hit_enemies.append(body)

func _on_TiempoVida_timeout() -> void:
	destruido.emit()

func _ajustar_tamaño() -> void:
	var radio = (base_radius + level * radius_per_level) * area_multiplicador
	
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radio
	elif collision_shape.shape is RectangleShape2D:
		collision_shape.shape.size = Vector2(radio * 2, radio * 2)
	
	var escala = radio / base_radius
	animated_sprite.scale = Vector2(escala, escala)
