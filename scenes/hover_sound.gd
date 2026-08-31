extends AudioStreamPlayer

func _ready():
	# เชื่อมต่อระบบ: เมื่อมี Node ใดๆ ถูกโหลดเข้ามาในเกม ให้เรียกฟังก์ชัน _on_node_added
	get_tree().node_added.connect(_on_node_added)
	
	# จัดการปุ่มที่มีอยู่แล้วใน Scene ตั้งแต่เริ่มเกม
	_connect_buttons(get_tree().root)

func _on_node_added(node: Node):
	# เช็คว่า Node ที่เพิ่มเข้ามาเป็นปุ่มหรือไม่ (BaseButton ครอบคลุมทั้ง Button, TextureButton ฯลฯ)
	if node is BaseButton:
		# ถ้าเป็นปุ่มและยังไม่ได้เชื่อม Signal ให้เชื่อมเข้ากับฟังก์ชันเล่นเสียง
		if not node.mouse_entered.is_connected(play_hover_sound):
			node.mouse_entered.connect(play_hover_sound)

func _connect_buttons(node: Node):
	if node is BaseButton:
		if not node.mouse_entered.is_connected(play_hover_sound):
			node.mouse_entered.connect(play_hover_sound)
	
	# วนลูปตรวจสอบโหนดลูกหลานทั้งหมด
	for child in node.get_children():
		_connect_buttons(child)

func play_hover_sound():
	play()
