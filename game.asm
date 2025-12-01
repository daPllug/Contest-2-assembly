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

; Sandwatch animation frame
    sandwatchFrame DWORD 0
    sandwatchChars BYTE "|/-\", 0
    
    ; Messages
    titleMsg BYTE "=== SNAKE GAME ===", 0
    scoreLabel BYTE "Score: ", 0
    lengthLabel BYTE "Length: ", 0
    gameOverMsg BYTE "GAME OVER! Final Score: ", 0
    restartMsg BYTE "Press R to restart, Q to quit", 0
    controlsMsg BYTE "Arrow Keys: Move | ESC: Pause", 0
    
    ; Colors (Irvine32 color constants)
    SNAKE_COLOR = (green * 16) + white
    GREEN_APPLE_COLOR = (green * 16) + green
    RED_APPLE_COLOR = (red * 16) + red
    WALL_COLOR = (gray * 16) + white
    TEXT_COLOR = (black * 16) + white
    
.code
main PROC


 call Randomize
    call InitializeGame
    
    MAIN_LOOP:
        call CheckInput
        call UpdateGame
        call DrawGame
        
        cmp gameOver, 1
        je GAME_OVER_SCREEN
        
        mov eax, gameSpeed
        call Delay
        jmp MAIN_LOOP
    
    GAME_OVER_SCREEN:
        call Clrscr
        mov dh, 10
        mov dl, 20
        call Gotoxy
        mov edx, OFFSET gameOverMsg
        call WriteString
        mov eax, score
        call WriteDec
        call Crlf
        mov edx, OFFSET restartMsg
        call WriteString

WAIT_KEY:
            call ReadChar
            cmp al, 'r'
            je RESTART
            cmp al, 'R'
            je RESTART
            cmp al, 'q'
            je EXIT_GAME
            cmp al, 'Q'
            je EXIT_GAME
            jmp WAIT_KEY
        
        RESTART:
            call InitializeGame
            jmp MAIN_LOOP
    
    EXIT_GAME:
        call Clrscr
        exit
main ENDP
