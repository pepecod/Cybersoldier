# SniperBullet.gd
extends Area2D
class_name SniperBullet

@export var speed: float            = 600.0
@export var damage: int             = 100
@export var base_radius: float      = 4.0
@export var radius_per_level: float = 2.0
@export var lifetime: float         = 5.0

# Vector de movimiento
var direction: Vector2           = Vector2.ZERO
# Enemigos ya golpeados
var hit_enemies: Array[Node2D]   = []

# Nivel del arma: cuando cambie, vuelve a ajustar tamaño
@export var level: int = 1


# Referencias al árbol (asegúrate que los nombres coincidan)
@onready var animated_sprite: AnimatedSprite2D   = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D   = $CollisionShape2D
@onready var timer_vida: Timer                    = $TiempoVida

func _ready() -> void:
	# Conectar señal de colisión
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	# Configurar y arrancar el Timer de vida
	timer_vida.wait_time = lifetime
	timer_vida.one_shot  = true
	timer_vida.start()
	if not timer_vida.timeout.is_connected(_on_TiempoVida_timeout):
		timer_vida.timeout.connect(_on_TiempoVida_timeout)

	# Orientar el sprite según la dirección
	if direction != Vector2.ZERO:
		rotation = direction.angle()

	# Arrancar animación en bucle (usa tu nombre real si no es "vuelo")
		animated_sprite.play("vuelo")
	else:
		var anims = animated_sprite.frames.get_animation_names()
		if anims.size() > 0:
			animated_sprite.play(anims[0])
	# Ajusta tamaño/hitbox según level actual
	_ajustar_tamaño()

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
	# No destruimos aquí para que atraviese

func _on_TiempoVida_timeout() -> void:
	queue_free()

func _ajustar_tamaño() -> void:
	# Calcula el nuevo “radio” base + nivel
	var radio = base_radius + level * radius_per_level
	# Ajusta hitbox según tipo de shape
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radio
	elif collision_shape.shape is RectangleShape2D:
		collision_shape.shape.extents = Vector2(radio, radio)
	else:
		push_warning("SniperBullet: shape no soportado para escalar (%s)" % collision_shape.shape)
	# Escala el sprite visualmente
	var escala = radio / base_radius
	animated_sprite.scale = Vector2(escala, escala)
	# Debug
	print("🔍 SniperBullet nivel %d → radio %.2f, scale %.2f" % [level, radio, escala])
