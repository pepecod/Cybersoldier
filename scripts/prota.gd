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
@export var velocidad: float = 700.0
@export var retroceso_fuerza: float = 10.0
@export var duracion_retroceso: float = 0.15
@export var aceleracion: float = 1000.5
@export var friccion: float = 100.8 

# DASH
@export var dash_velocidad: float = 2000.0
@export var dash_duracion: float = 0.2
@export var dash_cooldown: float = 2.0

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

# Dash
var esta_dasheando: bool = false
var dash_direccion: Vector2 = Vector2.ZERO
var puede_dashear: bool = true
var dash_timer: Timer
var cooldown_timer: Timer

func _ready() -> void:
	add_to_group("player")
	
	weapon_holder_pos_original = weapon_holder.position
	escala_original = anim_sprite.scale
	
	anim_sprite.play("idle")
	anim_sprite.animation_finished.connect(_on_animacion_terminada)
	
	var idx = GameState.selected_weapon_index if GameState else arma_inicial
	cambiar_arma(idx)
	
	vida_actual = vida_maxima
	
	_crear_timers_dash()

func _crear_timers_dash() -> void:
	# Timer de duración del dash
	dash_timer = Timer.new()
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_terminado)
	add_child(dash_timer)
	
	# Timer de cooldown
	cooldown_timer = Timer.new()
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_on_dash_cooldown_terminado)
	add_child(cooldown_timer)

func _physics_process(delta: float) -> void:
	if GameState:
		GameState.player_position = global_position
	
	manejar_dash()
	mover()
	look_at(get_global_mouse_position())
	disparar()
	actualizar_debug()

func manejar_dash() -> void:
	if Input.is_action_just_pressed("ui_accept") and puede_dashear and not esta_dasheando:
		iniciar_dash()

func iniciar_dash() -> void:
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Si no hay input de movimiento, dashear hacia donde mira el mouse
	if dir.length() == 0:
		dir = (get_global_mouse_position() - global_position).normalized()
	
	dash_direccion = dir.normalized()
	esta_dasheando = true
	puede_dashear = false
	
	dash_timer.start(dash_duracion)
	cooldown_timer.start(dash_cooldown)
	
	_efecto_visual_dash()

func _on_dash_terminado() -> void:
	esta_dasheando = false
	dash_direccion = Vector2.ZERO

func _on_dash_cooldown_terminado() -> void:
	puede_dashear = true

func _efecto_visual_dash() -> void:
	var tween = create_tween()
	tween.tween_property(anim_sprite, "modulate", Color(0.5, 0.5, 1.0, 0.7), 0.05)
	tween.tween_property(anim_sprite, "modulate", Color.WHITE, dash_duracion - 0.05)

func mover() -> void:
	var dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	esta_moviendose = dir.length() > 0
	
	if esta_dasheando:
		velocity = dash_direccion * dash_velocidad
	else:
		if dir.length() > 0:
			velocity = velocity.move_toward(dir.normalized() * velocidad, aceleracion)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, friccion)
	
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
	if not puede_dashear:
		texto += "\nDash: Cooldown"
	debug_label.text = texto

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_text_backspace"):
		take_damage(10)

func get_direccion_movimiento() -> Vector2:
	return velocity.normalized()

func get_velocidad_actual() -> float:
	return velocity.length()

func is_moving() -> bool:
	return esta_moviendose
