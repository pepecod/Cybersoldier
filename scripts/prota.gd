extends CharacterBody2D

# ——— Señales ————————————————————————————————————————
signal pasiva_equipada(pasiva_name: String)
signal pasiva_desequipada(pasiva_name: String)
signal vida_cambiada(vida_actual: float, vida_maxima: float)
signal muerto()

# ——— Vida ————————————————————————————————————————
@export var vida_maxima: float = 100.0
var vida_actual: float = 100.0

# ——— Configuración ————————————————————————————————————————
@export var velocidad: float = 2000.0
@export var retroceso_fuerza: float = 10.0
@export var duracion_retroceso: float = 0.15

@export_group("Armas")
@export var armas_disponibles: Array[PackedScene] = [
	preload("res://scenes/Armas/Holded/Escopeta/escopeta.tscn"),
	preload("res://scenes/Armas/Holded/Chakram/chakram.tscn"),
	preload("res://scenes/Armas/Holded/Sniper/sniper.tscn"),
]
@export var arma_inicial: int = 0

@export_group("Pasivas")
@export var pasivas_disponibles: Array[PackedScene] = []

# ——— Nodos ————————————————————————————————————————
@onready var weapon_holder: Node2D = $WeaponHolder
@onready var passive_holder: Node2D = $PassiveHolder
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var debug_label: Label = $DebugLabel

# ——— Estado ————————————————————————————————————————
var arma_actual: Node = null
var esta_moviendose: bool = false
var pasivas_equipadas: Array = []
var weapon_holder_pos_original: Vector2
var escala_original: Vector2

func _ready() -> void:
	add_to_group("player")
	
	weapon_holder_pos_original = weapon_holder.position
	escala_original = anim_sprite.scale
	
	anim_sprite.play("idle")
	anim_sprite.animation_finished.connect(_on_animacion_terminada)
	
	var idx = GameState.selected_weapon_index if GameState else arma_inicial
	cambiar_arma(idx)
	
	# Inicializar vida
	vida_actual = vida_maxima

func _physics_process(delta: float) -> void:
	if GameState:
		GameState.player_position = global_position
	
	mover()
	look_at(get_global_mouse_position())
	disparar()
	actualizar_debug()

func mover() -> void:
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	esta_moviendose = dir.length() > 0
	velocity = dir.normalized() * velocidad
	move_and_slide()
	actualizar_animacion_movimiento()

func actualizar_animacion_movimiento() -> void:
	if anim_sprite.animation == "disparar":
		return
	var nueva_anim = "caminar" if esta_moviendose else "idle"
	if anim_sprite.animation != nueva_anim:
		anim_sprite.play(nueva_anim)

func disparar() -> void:
	if not Input.is_action_pressed("ui_leftclick"):
		return
	if not arma_actual or not arma_actual.has_method("disparar"):
		return
	
	var mouse_pos = get_global_mouse_position()
	var arma_pos = arma_actual.global_position
	var direccion = (mouse_pos - arma_pos).normalized()
	arma_actual.disparar(arma_pos, direccion)

func _on_disparo_realizado() -> void:
	anim_sprite.play("disparar")
	anim_sprite.frame = 0
	animar_retroceso_arma()
	animar_retroceso_cuerpo()

func animar_retroceso_arma() -> void:
	var retroceso_local = Vector2(-4, 0)
	var tween = create_tween()
	tween.tween_property(weapon_holder, "position", weapon_holder_pos_original + retroceso_local, 0.05)
	tween.tween_property(weapon_holder, "position", weapon_holder_pos_original, 0.1)

func animar_retroceso_cuerpo() -> void:
	var dir_retro = -transform.x * retroceso_fuerza
	var pos_inicial = position
	var tween = create_tween()
	tween.tween_property(self, "position", pos_inicial + dir_retro, duracion_retroceso / 2)
	tween.tween_property(self, "position", pos_inicial, duracion_retroceso / 2)

func cambiar_arma(indice: int) -> void:
	if indice < 0 or indice >= armas_disponibles.size():
		return
	
	if arma_actual:
		arma_actual.queue_free()
	
	arma_actual = armas_disponibles[indice].instantiate()
	weapon_holder.add_child(arma_actual)
	arma_actual.position = Vector2.ZERO
	
	if arma_actual.has_signal("disparado"):
		arma_actual.disparado.connect(_on_disparo_realizado)

func equipar_pasiva_por_indice(indice: int) -> void:
	if indice < 0 or indice >= pasivas_disponibles.size():
		return
	
	if pasivas_equipadas.size() >= 3:
		return
	
	var sistema = pasivas_disponibles[indice].instantiate()
	passive_holder.add_child(sistema)
	sistema.position = Vector2.ZERO
	pasivas_equipadas.append(sistema)

func desequipar_pasiva_por_indice(indice: int) -> void:
	if indice < 0 or indice >= pasivas_equipadas.size():
		return
	
	var sistema = pasivas_equipadas[indice]
	pasivas_equipadas.remove_at(indice)
	sistema.queue_free()

func take_damage(cantidad: float) -> void:
	vida_actual = max(0, vida_actual - cantidad)
	vida_cambiada.emit(vida_actual, vida_maxima)
	
	if vida_actual <= 0:
		muerto.emit()

func _on_animacion_terminada() -> void:
	if anim_sprite.animation == "disparar":
		actualizar_animacion_movimiento()

func actualizar_debug() -> void:
	if not debug_label:
		return
	var texto = "Pos: " + str(global_position.round())
	texto += "\nVel: " + str(velocity.length()).pad_decimals(0)
	texto += "\nVida: " + str(int(vida_actual)) + "/" + str(int(vida_maxima))
	texto += "\nPasivas: " + str(pasivas_equipadas.size()) + "/3"
	debug_label.text = texto

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		if pasivas_equipadas.size() > 0:
			desequipar_pasiva_por_indice(0)
		else:
			equipar_pasiva_por_indice(0)
	
	# DEBUG: Tecla para probar daño
	if event.is_action_pressed("ui_text_backspace"):
		take_damage(10)

func get_direccion_movimiento() -> Vector2:
	return velocity.normalized()

func get_velocidad_actual() -> float:
	return velocity.length()

func is_moving() -> bool:
	return esta_moviendose
