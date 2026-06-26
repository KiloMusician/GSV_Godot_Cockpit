extends VBoxContainer

## ModelStatusPanel — Live model bloodstream: Ollama · LiteLLM · FCC.
## Probes each inference endpoint and shows available models.

const BRIDGE := "C:/GSV/tools/godot-cockpit/Invoke-GSVGodotBridge.ps1"

var _output: RichTextLabel
var _status: Label

func _ready() -> void:
	var title := Label.new()
	title.text = "Ξ Model Bloodstream — Ollama · LiteLLM · FCC"
	title.add_theme_font_size_override("font_size", 15)
	add_child(title)

	_status = Label.new()
	_status.text = "status: waiting"
	_status.modulate = Color(0.6, 0.6, 0.6)
	add_child(_status)

	var btns := HBoxContainer.new()
	add_child(btns)

	var refresh_btn := Button.new()
	refresh_btn.text = "↺ Refresh"
	refresh_btn.pressed.connect(refresh_models)
	btns.add_child(refresh_btn)

	var fcc_note := Label.new()
	fcc_note.text = "  bridge mode: models"
	fcc_note.modulate = Color(0.5, 0.5, 0.5)
	btns.add_child(fcc_note)

	_output = RichTextLabel.new()
	_output.use_bbcode = true
	_output.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_output.scroll_following = false
	add_child(_output)

	refresh_models()

func refresh_models() -> void:
	_status.text = "status: probing..."
	_output.clear()
	_output.append_text("[color=cyan]probing model bloodstream...[/color]\n")

	# Parallel: probe Ollama and LiteLLM directly (faster than bridge)
	_probe_ollama()
	_probe_litellm()
	_probe_fcc()

	_status.text = "status: live"

func _probe_ollama() -> void:
	var raw := _ps("(Invoke-WebRequest 'http://localhost:11434/api/tags' -UseBasicParsing -TimeoutSec 4).Content")
	_output.append_text("\n[b]OLLAMA :11434[/b]\n")
	var parsed = JSON.parse_string(raw)
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("models"):
		var models: Array = parsed["models"]
		_output.append_text("[color=green]● UP[/color] — %d models\n" % models.size())
		for m in models:
			if typeof(m) == TYPE_DICTIONARY:
				var name_str: String = str(m.get("name", m.get("model", "?")))
				var size_gb: float = float(str(m.get("size", 0))) / 1_000_000_000.0
				_output.append_text("  [color=gray]·[/color] %s  [color=gray](%.1fGB)[/color]\n" % [name_str, size_gb])
	else:
		_output.append_text("[color=red]● DOWN[/color]\n")

func _probe_litellm() -> void:
	var raw := _ps("(Invoke-WebRequest 'http://localhost:4000/v1/models' -UseBasicParsing -TimeoutSec 4).Content")
	_output.append_text("\n[b]LITELLM :4000[/b]\n")
	var parsed = JSON.parse_string(raw)
	if typeof(parsed) == TYPE_DICTIONARY and parsed.has("data"):
		var items: Array = parsed["data"]
		_output.append_text("[color=green]● UP[/color] — %d aliases\n" % items.size())
		for item in items:
			if typeof(item) == TYPE_DICTIONARY:
				_output.append_text("  [color=gray]·[/color] %s\n" % str(item.get("id", "?")))
	else:
		_output.append_text("[color=red]● DOWN[/color]\n")

func _probe_fcc() -> void:
	var raw := _ps("(Invoke-WebRequest 'http://127.0.0.1:8082/v1/models' -UseBasicParsing -TimeoutSec 4).Content")
	_output.append_text("\n[b]FCC :8082[/b]\n")
	var parsed = JSON.parse_string(raw)
	if typeof(parsed) == TYPE_DICTIONARY and (parsed.has("data") or parsed.has("models")):
		var items: Array = parsed.get("data", parsed.get("models", []))
		_output.append_text("[color=green]● UP[/color] — %d models\n" % items.size())
		# Show first 8
		var shown := 0
		for item in items:
			if shown >= 8: break
			if typeof(item) == TYPE_DICTIONARY:
				_output.append_text("  [color=gray]·[/color] %s\n" % str(item.get("id", item.get("name", "?"))))
			shown += 1
		if items.size() > 8:
			_output.append_text("  [color=gray]... +%d more[/color]\n" % (items.size() - 8))
	else:
		_output.append_text("[color=yellow]● NOT FOUND[/color] (start fcc-codex)\n")

func _ps(cmd: String) -> String:
	var output: Array = []
	OS.execute("pwsh", ["-NoProfile", "-Command",
		"try { %s } catch { '{}' }" % cmd], output, true, false)
	var text := ""
	for line in output: text += str(line)
	return text.strip_edges()
