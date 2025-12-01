This is a code for our assembly class. We decided to go with a snake game. The snake eats the apple and gets bigger.
# Snake Game – MASM Assembly (Irvine32)

This is a smooth-rendered Snake Game written entirely in MASM assembly,
using only the Irvine32 library.

Features:
- Smooth movement (erase only tail)
- Random colored apples (green/red)
- Score counter and UI
- Sandwatch animation
- Game over screen and restart option
- Arrow key controls + pause

## Requirements
- Windows OS
- MASM32 or ML.exe
- Irvine32 library installed and linked

## How to Compile (see COMPILATION.md for details)
ml /c /coff src\SnakeGame.asm
link /subsystem:console SnakeGame.obj Irvine32.lib

## How to Run
Run the generated EXE:
