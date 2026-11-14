extends Node
## Global signal bus. Holds typed signals only — no gameplay state.

signal run_started
signal run_ended(reason: String)
signal player_died
