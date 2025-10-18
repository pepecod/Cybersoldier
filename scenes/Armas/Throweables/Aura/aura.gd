# Aura.gd
extends Node2D
class_name Aura

@export var damage_amount: int      = 5
@export var radius: float           = 100.0
@export var color: Color            = Color(0, 0.5, 1.0, 0.3)
@export var pulse_speed: float      = 0.8  # velocidad de pulso
var _time_passed: float = 0.0

@onready var area2d: Area2D         = $Area2D
@onready var game_state := get_node("/root/GameState")
@onready var collision_shape: CollisionShape2D = $Area2D/AreaEfecto

func _ready() -> void:
	# Asegurar que el área coincida con el radio
	if area2d.get_node("CollisionShape2D") is CollisionShape2D:
		var shape = area2d.get_node("CollisionShape2D").shape
		if shape is CircleShape2D:
			shape.radius = radius

	# Conectar detección de enemigos
	area2d.body_entered.connect(Callable(self, "_on_area_body_entered"))
	
	game_state.connect("level_up", Callable(self, "_on_level_up"))

func _process(delta: float) -> void:
	_time_passed += delta
	position = Vector2.ZERO
	queue_redraw()

func _draw() -> void:
	# Cálculo del pulso: frecuencia pulse_speed ciclos/s, amplitud pulse_amplitude
	var pulse_amplitude: float = 10.0  # ajusta según quieras
	var pulse: float = sin(_time_passed * TAU * pulse_speed) * pulse_amplitude
	draw_circle(Vector2.ZERO, radius + pulse, color)

func _on_area_body_entered(body: Node) -> void:
	if body.is_in_group("enemigo") and body.has_method("take_damage"):
		body.take_damage(damage_amount)
func _on_level_up(new_level: int) -> void:
	# cada nivel +10 de radio y +1 de daño
	radius += 10.0
	damage_amount += 1
	# actualizar el collision_shape
	if collision_shape.shape is CircleShape2D:
		collision_shape.shape.radius = radius
