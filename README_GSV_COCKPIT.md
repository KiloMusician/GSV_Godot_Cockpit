# Ξ GSV Godot Cockpit

> **Godot is not the brain. Godot is the cockpit.**

This Godot 4 project is the visual, interactive membrane of **GSV Sublime Optimization**.

## System Frame

| Layer | Role |
|-------|------|
| Godot Cockpit | visible / navigable / playable membrane |
| Kilo_Core | factory |
| GSV | memory / ship OS |
| Intermediary | dispatcher |
| FCC / LiteLLM / Ollama | model bloodstream |
| DESKTOP-L9V3EMB | engine room |
| Terminal Depths | game-heart |

## What it does right now

- **Status panel** — probes FCC, LiteLLM, OpenClaw, Ollama, Desktop services; shows ✓/✗
- **Proof bundle** — runs service probes + ship health and displays results
- **Natural-language routing** — type a task, it routes through intermediary + gsv who-can
- **Memory tail** — shows last 20 cockpit events from vents.jsonl

## Launch

`powershell
godot --path "C:\dev\active\GSV_Godot_Cockpit"
`

## Bridge

Godot calls this PowerShell bridge for all colony I/O:

`powershell
# Manual test
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\GSV\tools\godot-cockpit\Invoke-GSVGodotBridge.ps1" -Mode status
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\GSV\tools\godot-cockpit\Invoke-GSVGodotBridge.ps1" -Mode proof
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\GSV\tools\godot-cockpit\Invoke-GSVGodotBridge.ps1" -Mode route -Objective "Improve colony factory autonomy"
pwsh -NoProfile -ExecutionPolicy Bypass -File "C:\GSV\tools\godot-cockpit\Invoke-GSVGodotBridge.ps1" -Mode memory
`

## Next additions

1. **Quest board panel** — tasks as quests, errors as encounters, tests as proof gates
2. **Agent/service graph** — agents as NPCs, repos as zones
3. **Receipt/log viewer** — receipts.jsonl, live-sprint.log
4. **Terminal Depths state panel** — TD depth, cycle, CHUG status
5. **Godot RL / Torch integration** — after telemetry is stable
