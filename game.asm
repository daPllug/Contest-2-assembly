INCLUDE Irvine32.inc

.data
    ; Game board dimensions
    BOARD_WIDTH = 50
    BOARD_HEIGHT = 20
    GAME_START_X = 5
    GAME_START_Y = 3
    
    ; Snake structure (max 200 segments)
    snakeX BYTE 200 DUP(0)
    snakeY BYTE 200 DUP(0)
    snakeLength DWORD 3
    direction BYTE 3              ; 0=up, 1=down, 2=left, 3=right
    nextDirection BYTE 3
    
    ; Food/apples
    appleX BYTE 0
    appleY BYTE 0
    appleType BYTE 0              ; 0=green, 1=red
    appleValue DWORD 1            ; Points for apple
    
    ; Game state
    score DWORD 0
    gameOver BYTE 0
    gameSpeed DWORD 80            ; Milliseconds between frames
    
    ; Previous positions for smooth redraw
    prevTailX BYTE 0FFh             ; Initialize to invalid value
prevTailY BYTE 0FFh

