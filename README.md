; ============================================================
; SNAKE GAME - Smooth Version
; Classic snake game with colored apples, score, and animations
; Uses only Irvine32 library and MASM assembly
;
; Smooth rendering technique: Instead of clearing the entire
; screen each frame, we only erase the previous tail position
; and redraw the snake head. This eliminates jittering and
; provides smooth, flicker-free gameplay.
; ============================================================

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

; ============================================================
; Initialize game state
; ============================================================
InitializeGame PROC
    ; Initialize snake in center
    mov snakeLength, 3
    mov snakeX[0], 25
    mov snakeY[0], 10
    mov snakeX[1], 24
    mov snakeY[1], 10
    mov snakeX[2], 23
    mov snakeY[2], 10
    
    ; Initialize direction
    mov direction, 3
    mov nextDirection, 3
    
    ; Reset game state
    mov score, 0
    mov gameOver, 0
    mov gameSpeed, 80
    mov prevTailX, 0FFh             ; Reset previous tail
    mov prevTailY, 0FFh
    
    ; Generate first apple
    call GenerateApple
    
    ; Clear screen and draw borders
    call Clrscr
    call DrawBorders
    call DrawUI
    
    ret
InitializeGame ENDP

; ============================================================
; Draw game borders
; ============================================================
DrawBorders PROC
    mov eax, WALL_COLOR
    call SetTextColor
    
    ; Top border
    mov dh, BYTE PTR GAME_START_Y
    mov dl, BYTE PTR GAME_START_X
    call Gotoxy
    mov ecx, BOARD_WIDTH
    mov al, 205                    ; Double line horizontal
    TOP_LOOP:
        call WriteChar
        loop TOP_LOOP
    
    ; Bottom border
    mov eax, GAME_START_Y
    add eax, BOARD_HEIGHT
    mov dh, al
    mov dl, BYTE PTR GAME_START_X
    call Gotoxy
    mov ecx, BOARD_WIDTH
    mov al, 205
    BOTTOM_LOOP:
        call WriteChar
        loop BOTTOM_LOOP
    
    ; Left and right borders
    mov esi, 0
    SIDE_LOOP:
        cmp esi, BOARD_HEIGHT
        jge BORDERS_DONE
        
        mov eax, GAME_START_Y
        add eax, esi
        mov dh, al
        
        ; Left border
        mov dl, BYTE PTR GAME_START_X
        call Gotoxy
        mov al, 186                 ; Double line vertical
        call WriteChar
        
        ; Right border
        mov eax, GAME_START_X
        add eax, BOARD_WIDTH
        mov dl, al
        call Gotoxy
        mov al, 186
        call WriteChar
        
        inc esi
        jmp SIDE_LOOP
    
    BORDERS_DONE:
        ; Corners
        mov dh, BYTE PTR GAME_START_Y
        mov dl, BYTE PTR GAME_START_X
        call Gotoxy
        mov al, 201                ; Top-left corner
        call WriteChar
        
        mov eax, GAME_START_X
        add eax, BOARD_WIDTH
        mov dl, al
        call Gotoxy
        mov al, 187                ; Top-right corner
        call WriteChar
        
        mov eax, GAME_START_Y
        add eax, BOARD_HEIGHT
        mov dh, al
        mov dl, BYTE PTR GAME_START_X
        call Gotoxy
        mov al, 200                ; Bottom-left corner
        call WriteChar
        
        mov eax, GAME_START_X
        add eax, BOARD_WIDTH
        mov dl, al
        call Gotoxy
        mov al, 188                ; Bottom-right corner
        call WriteChar
        
        mov eax, TEXT_COLOR
        call SetTextColor
        ret
DrawBorders ENDP

; ============================================================
; Draw UI elements (score, length, etc.)
; ============================================================
DrawUI PROC
    mov eax, TEXT_COLOR
    call SetTextColor
    
    ; Title
    mov dh, 0
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET titleMsg
    call WriteString
    
    ; Score
    mov dh, 1
    mov dl, 0
    call Gotoxy
    mov edx, OFFSET scoreLabel
    call WriteString
    mov eax, score
    call WriteDec
    
    ; Length
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET lengthLabel
    call WriteString
    mov eax, snakeLength
    call WriteDec
    
    ; Controls
    mov dh, 1
    mov dl, 35
    call Gotoxy
    mov edx, OFFSET controlsMsg
    call WriteString
    
    ret
DrawUI ENDP

; ============================================================
; Check keyboard input
; ============================================================
CheckInput PROC
    call ReadKey
    jz NO_INPUT                    ; No key pressed
    
    ; Check for ESC (pause)
    cmp al, 27
    je PAUSE_GAME
    
    ; Check arrow keys (extended scan codes)
    cmp al, 0
    jne NO_INPUT                   ; Not extended key
    
    cmp ah, 72                     ; Up arrow
    je UP_KEY
    cmp ah, 80                     ; Down arrow
    je DOWN_KEY
    cmp ah, 75                     ; Left arrow
    je LEFT_KEY
    cmp ah, 77                     ; Right arrow
    je RIGHT_KEY
    jmp NO_INPUT
    
    UP_KEY:
        cmp direction, 1           ; Can't reverse direction
        je NO_INPUT
        mov nextDirection, 0
        jmp NO_INPUT
    
    DOWN_KEY:
        cmp direction, 0
        je NO_INPUT
        mov nextDirection, 1
        jmp NO_INPUT
    
    LEFT_KEY:
        cmp direction, 3
        je NO_INPUT
        mov nextDirection, 2
        jmp NO_INPUT
    
    RIGHT_KEY:
        cmp direction, 2
        je NO_INPUT
        mov nextDirection, 3
        jmp NO_INPUT
    
    PAUSE_GAME:
        ; Simple pause - wait for key press
        mov dh, 12
        mov dl, 20
        call Gotoxy
        mov al, 'P'
        call WriteChar
        mov al, 'A'
        call WriteChar
        mov al, 'U'
        call WriteChar
        mov al, 'S'
        call WriteChar
        mov al, 'E'
        call WriteChar
        mov al, 'D'
        call WriteChar
        call ReadChar
        ; Clear pause message
        mov dh, 12
        mov dl, 20
        call Gotoxy
        mov ecx, 6
        mov al, ' '
        CLEAR_PAUSE:
            call WriteChar
            loop CLEAR_PAUSE
    
    NO_INPUT:
        ret
CheckInput ENDP

; ============================================================
; Update game state (move snake, check collisions, etc.)
; ============================================================
UpdateGame PROC
    ; Update direction
    mov al, nextDirection
    mov direction, al
    
    ; Save tail position for erasing
    mov esi, snakeLength
    dec esi
    mov al, snakeX[esi]
    mov prevTailX, al
    mov al, snakeY[esi]
    mov prevTailY, al
    
    ; Move snake body (shift all segments)
    mov esi, snakeLength
    dec esi
    SHIFT_LOOP:
        cmp esi, 0
        je MOVE_HEAD
        mov al, snakeX[esi - 1]
        mov ah, snakeY[esi - 1]
        mov snakeX[esi], al
        mov snakeY[esi], ah
        dec esi
        jmp SHIFT_LOOP
    
    MOVE_HEAD:
        ; Calculate new head position
        mov al, snakeX[0]
        mov ah, snakeY[0]
        
        cmp direction, 0
        je MOVE_UP
        cmp direction, 1
        je MOVE_DOWN
        cmp direction, 2
        je MOVE_LEFT
        jmp MOVE_RIGHT
        
        MOVE_UP:
            dec ah
            jmp HEAD_MOVED
        
        MOVE_DOWN:
            inc ah
            jmp HEAD_MOVED
        
        MOVE_LEFT:
            dec al
            jmp HEAD_MOVED
        
        MOVE_RIGHT:
            inc al
            jmp HEAD_MOVED
    
    HEAD_MOVED:
        mov snakeX[0], al
        mov snakeY[0], ah
    
    ; Check wall collision
    mov al, snakeX[0]
    mov ah, snakeY[0]
    cmp al, 0
    jl WALL_HIT
    cmp al, BOARD_WIDTH - 1
    jge WALL_HIT
    cmp ah, 0
    jl WALL_HIT
    cmp ah, BOARD_HEIGHT - 1
    jge WALL_HIT
    
    ; Check self collision
    mov esi, 1
    CHECK_SELF:
        cmp esi, snakeLength
        jge CHECK_APPLE
        mov al, snakeX[0]
        mov ah, snakeY[0]
        cmp al, snakeX[esi]
        jne NEXT_SEGMENT
        cmp ah, snakeY[esi]
        je SELF_HIT
        NEXT_SEGMENT:
        inc esi
        jmp CHECK_SELF
    
    CHECK_APPLE:
        ; Check if snake ate apple
        mov al, snakeX[0]
        mov ah, snakeY[0]
        cmp al, appleX
        jne UPDATE_DONE
        cmp ah, appleY
        jne UPDATE_DONE
        
        ; Apple eaten!
        mov esi, snakeLength
        mov al, snakeX[esi - 1]
        mov ah, snakeY[esi - 1]
        mov snakeX[esi], al
        mov snakeY[esi], ah
        inc snakeLength
        
        ; Update score based on apple type
        cmp appleType, 0
        je GREEN_APPLE
        ; Red apple worth more
        add score, 5
        jmp SCORE_UPDATED
        GREEN_APPLE:
        add score, 1
        SCORE_UPDATED:
        
        ; Generate new apple
        call GenerateApple
        
        ; Increase speed slightly (make game harder)
        cmp gameSpeed, 30
        jle SPEED_OK
        dec gameSpeed
        SPEED_OK:
        
        jmp UPDATE_DONE
    
    WALL_HIT:
    SELF_HIT:
        mov gameOver, 1
    
    UPDATE_DONE:
        ret
UpdateGame ENDP

; ============================================================
; Generate new apple at random position
; ============================================================
GenerateApple PROC
    APPLE_LOOP:
        ; Generate random position
        mov eax, BOARD_WIDTH - 2
        call RandomRange
        inc eax
        mov appleX, al
        
        mov eax, BOARD_HEIGHT - 2
        call RandomRange
        inc eax
        mov appleY, al
        
        ; Check if apple is on snake
        mov esi, 0
        CHECK_SNAKE:
            cmp esi, snakeLength
            jge APPLE_OK
            mov al, appleX
            mov ah, appleY
            cmp al, snakeX[esi]
            jne NEXT_CHECK
            cmp ah, snakeY[esi]
            je APPLE_LOOP           ; Regenerate
            NEXT_CHECK:
            inc esi
            jmp CHECK_SNAKE
    
    APPLE_OK:
        ; Randomly choose apple type (70% green, 30% red)
        mov eax, 10
        call RandomRange
        cmp eax, 3
        jl RED_APPLE
        mov appleType, 0            ; Green
        jmp APPLE_DONE
        RED_APPLE:
        mov appleType, 1            ; Red
    
    APPLE_DONE:
        ret
GenerateApple ENDP

; ============================================================
; ============================================================
; Draw game (snake, apple, UI updates)
; ============================================================
DrawGame PROC
    ; Erase previous tail (smooth movement - only erase what changed)
    ; This prevents jittering by only updating changed cells
    mov al, prevTailX
    mov ah, prevTailY
    cmp al, 0FFh                    ; Check if valid (not initialized)
    je SKIP_ERASE
    cmp al, 0
    je SKIP_ERASE
    mov dh, ah
    add dh, BYTE PTR GAME_START_Y
    inc dh
    mov dl, al
    add dl, BYTE PTR GAME_START_X
    inc dl
    call Gotoxy
    mov eax, (black * 16) + black    ; Erase with background color
    call SetTextColor
    mov al, ' '
    call WriteChar
    
    SKIP_ERASE:
    ; Draw snake
    mov eax, SNAKE_COLOR
    call SetTextColor
    
    mov esi, 0
    DRAW_SNAKE:
        cmp esi, snakeLength
        jge DRAW_APPLE
        
        mov al, snakeY[esi]
        mov ah, snakeX[esi]
        mov dh, al
        add dh, BYTE PTR GAME_START_Y
        inc dh
        mov dl, ah
        add dl, BYTE PTR GAME_START_X
        inc dl
        call Gotoxy
        
        ; Draw head differently
        cmp esi, 0
        jne BODY_SEGMENT
        mov al, 219                 ; Full block for head
        jmp DRAW_SEGMENT
        BODY_SEGMENT:
        mov al, 178                 ; Medium shade for body
        DRAW_SEGMENT:
        call WriteChar
        
        inc esi
        jmp DRAW_SNAKE
    
    ; Draw apple
    DRAW_APPLE:
        mov al, appleY
        mov ah, appleX
        mov dh, al
        add dh, BYTE PTR GAME_START_Y
        inc dh
        mov dl, ah
        add dl, BYTE PTR GAME_START_X
        inc dl
        call Gotoxy
        
        cmp appleType, 0
        je GREEN_APPLE_DRAW
        mov eax, RED_APPLE_COLOR
        jmp SET_APPLE_COLOR
        GREEN_APPLE_DRAW:
        mov eax, GREEN_APPLE_COLOR
        SET_APPLE_COLOR:
        call SetTextColor
        mov al, 254                 ; Block character
        call WriteChar
    
    ; Update UI (score, length)
    call UpdateUI
    
    ; Draw sandwatch animation
    call DrawSandwatch
    
    ; Reset text color
    mov eax, TEXT_COLOR
    call SetTextColor
    
    ret
DrawGame ENDP

; ============================================================
; Update UI elements
; ============================================================
UpdateUI PROC
    mov eax, TEXT_COLOR
    call SetTextColor
    
    ; Update score
    mov dh, 1
    mov dl, 7
    call Gotoxy
    mov eax, score
    call WriteDec
    ; Clear any extra digits
    mov ecx, 5
    CLEAR_SCORE:
        mov al, ' '
        call WriteChar
        loop CLEAR_SCORE
    
    ; Update length
    mov dl, 28
    call Gotoxy
    mov eax, snakeLength
    call WriteDec
    ; Clear any extra digits
    mov ecx, 3
    CLEAR_LENGTH:
        mov al, ' '
        call WriteChar
        loop CLEAR_LENGTH
    
    ret
UpdateUI ENDP

; ============================================================
; ============================================================
; Draw sandwatch animation
; ============================================================
DrawSandwatch PROC
    ; Update animation frame (cycle through 4 frames)
    inc sandwatchFrame
    cmp sandwatchFrame, 4
    jl FRAME_OK
    mov sandwatchFrame, 0
    FRAME_OK:
    
    ; Draw sandwatch character in top right
    mov eax, TEXT_COLOR
    call SetTextColor
    mov dh, 1
    mov dl, 70
    call Gotoxy
    
    mov esi, sandwatchFrame
    mov al, sandwatchChars[esi]
    call WriteChar
    
    ret
DrawSandwatch ENDP

END main
