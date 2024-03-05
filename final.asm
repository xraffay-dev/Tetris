[org 0x0100]
jmp MainMenu
scoreINT: dw 0000
scoreTXT: dw "Score:", 0
clockSeconds: dw 59
clockMinutes: dw 4
clockTXT: dw ":", 0
temp: dw 5
TitleText: db " WELCOME TO TETRIS GAME ", 0
NewGame: db "New Game", 0
Credits: db "Credits", 0
Instructions: db "Instructions", 0
Exit: db "Exit", 0
CreditsText: db "Developed by Mamoon Ahmad& Abdul Rafay", 0
InstructionsText: db "Press left and right keys to move the shapes", 0
ExitText: db "Game Over", 0 
BlackBackground:
      push ax
      push di
      push es
      mov ax, 0xb800
      mov es, ax
      mov ax, 0x0720
      mov di, 0
      clsLoop:
         mov [es : di], ax
         add di, 2
         cmp di, 4000
         jne clsLoop
      pop es
      pop di
      pop ax
      ret
cls:
  push cx
  push di
  push ax
  mov cx, 2000
  xor di, di
  mov ax, 0xfb20
  rep stosw 
  pop ax
  pop di
  pop cx
  ret
printstr:     
     push bp
     mov  bp, sp 
     push es 
     push ax 
     push cx 
     push si 
     push di 
     push ds  
     pop es                 ; load ds in es 
     mov di, [bp + 4]       ; point di to string 
     mov cx, 0xffff         ; load maximum number in cx 
     xor al, al             ; load a zero in al 
     repne scasb            ; find zero in the string 
     mov ax, 0xffff         ; load maximum number in ax 
     sub ax, cx             ; find change in cx 
     dec ax                 ; exclude null from length 
     jz strExit             ; no printing if string is empty
     mov cx, ax             ; load string length in cx 
     mov ax, 0xb800
     mov es, ax
     mov di, [bp+8]         ; point di to required location
     xor ax, ax 
     mov ah, [bp+6]         ; load attribute in ah
     mov si, [bp+4]         ; point si to string 
    cld                      ; auto increment mode 
     nextchar:     
         lodsb               ; load next char in al 
         stosw               ; print char/attribute pair 
         loop nextchar       ; repeat for the whole string 
     strExit:
         pop di 
         pop si 
         pop cx 
         pop ax 
         pop es 
         pop bp 
         ret 6
printNum:
   push bp 
   mov bp, sp 
   push es 
   push ax 
   push bx 
   push cx 
   push dx 
   push di
   mov ax, [bp+4]    ; load number in ax 
   mov bx, 10        ; use base 10 for division 
   mov cx, 0         ; initialize count of digits 
   nextdigit:
     mov dx, 0       ; zero upper half of dividend 
     div bx          ; divide by 10 
     add dl, 0x30    ; convert digit into ascii value 
     push dx         ; save ascii value on stack 
     inc cx          ; increment count of values 
     cmp ax, 0       ; is the quotient zero 
   jnz nextdigit     ; if no divide it again 
   nextpos:
     pop dx          ; remove a digit from the stack 
     mov dh, 0x70    ; use normal attribute 
     mov [es:di], dx ; print char on screen 
     add di, 2       ; move to next screen location 
     loop nextpos    ; repeat for all digits on stack
    pop di
    pop dx 
    pop cx 
    pop bx 
    pop ax 
    pop es 
    pop bp 
    ret 2 
printArena:
     push bp
     mov bp, sp
     push di 
     push es
     push ax
     push bx
     push cx
     push dx
     mov al, 80
     mov bh, 0x2
     mul bh                         ; multiply with y1
     add ax, 0xE                    ; add x1
     shl ax, 1
     mov di, ax                     ; mov(x1, y1) in di as starting point
     push di                        ; push di in stack to save (x1,y1) coordinate
     mov al, 80
     mul bh
     add ax, 0x2d
     shl ax, 1 
     mov dx, ax                     ; dx -> (x2, y2)
     mov ax, [bp + 4]
     upperHorizontal:
         mov [es : di], ax
         add di, 2
         cmp di, dx
         jne upperHorizontal
      mov al, 80
      mul byte [bp + 6]
      add ax, 0xE
      shl ax, 1
      pop di     ; (x1, y1) moves in di
      mov bx, ax ; bx -> (x3, y3)
      mov ax, [bp + 4]
      leftVertical:
         mov [es : di], ax
         add di, 160
         cmp di, bx
         jne leftVertical
     mov al, 80
     mul byte [bp + 6]
     add ax, 0x2d
     shl ax, 1
     mov cx, ax ; cx -> (x4, y4)
     mov di, dx
     mov ax, [bp + 4]
     rightVertical:
         mov [es : di], ax
         add di, 160
         cmp di, cx
         jne rightVertical
     mov di, bx ; bx-> (x3, y3)
     add cx, 2  ; 1 more printing for better aesthetics
     lowerHorizontal:
         mov [es : di], ax
         add di, 2
         cmp di, cx
         jne lowerHorizontal
     pop dx
     pop cx
     pop bx
     pop ax
     pop es
     pop di
     pop bp
     ret 4
generateRandom:
    push ax
    push cx
    mov ah, 0               ; BIOS function to get system timer count
    int 1Ah                 ; Call BIOS interrupt
    and dx, 3               ; Ensure dx is in the range 0 to 3
    pop cx
    pop ax
    ret
printShapes:
	push bp
	mov bp, sp
	push ax
	push cx
	push bx
	push di
	mov ax, [bp+4]
	mov bx, [bp+6]
	cmp bx, 0
	je PrintLShape
	cmp bx, 1
	je PrintJShape
	cmp bx, 2
	je PrintSquareShape
	cmp bx, 3
	je PrintRectangleShape
	PrintLShape:
   mov cx, 3
   push di
	 Lshape:
	 mov [es:di], ax 
	 sub di, 160
	 loop Lshape
	 pop di
   mov cx, 4
   right:
	 mov [es:di], ax
       add di, 2
       loop right
   jmp ExitShape
  PrintJShape:
		 mov cx, 3
	   JShape:
			mov [es:di], ax
			add di, 2
			loop JShape
		 mov cx, 3
	   Top:
			mov [es:di], ax
			sub di, 160
			loop Top
        jmp ExitShape
	PrintRectangleShape:
		mov cx, 8
		RectangleShape:
			mov[es:di], ax
			add di, 2
			loop RectangleShape
		jmp ExitShape
	PrintSquareShape:
		    mov cx, 2
            TopSquare:
			    mov[es:di], ax
			    add di, 2
			    loop TopSquare
        jmp ExitShape
	ExitShape:
        pop di
		pop bx
		pop cx
		pop ax
		pop bp
		ret 4
delay:
     push ax
     push bx
     push cx
     push dx
     push si
     push di
     push bp
     mov cx, 0xffff
     delaying:
      add ax, 1
      add bx, 1
      add dx, 1
      add si, 1
      add di, 1
      add bp, 1
     loop delaying
     pop bp
     pop di
     pop si
     pop dx
     pop cx 
     pop bx
     pop ax
     ret
scrolldown:
 push di
 push ax
 push cx
 push ds
 mov di, bx
 mov si, di
 mov ax, 0xb800
 mov ds, ax
 sub si, 160
  RepeatInScroll:
    push si
    push di
    mov cx, 33
     std 
     rep movsw 
     cld
   pop di
   pop si
   sub si, 160
   sub di, 160
   cmp si, 510
   jae RepeatInScroll
  pop ds
  add word[scoreINT], 10
  pop cx
  pop ax
  pop di
  jmp main
clock:
 push di
 mov word[es:764], 0xfb20
 mov word[es:766], 0xfb20
 mov word[es:768], 0xfb20
 mov di, 760
 push word [clockMinutes]
 call printNum
 mov di, 762
 push di
 push byte 0x70
 push word clockTXT
 call printstr
 mov di, 764
 push word [clockSeconds]
 call printNum
 cmp word [clockSeconds], 0x0
 jle decMinute
 dec word [clockSeconds]
 pop di
 ret
 decMinute:
 cmp word [clockMinutes], 0x0
 je ExitHelper
 dec word [clockMinutes]
 mov word [clockSeconds], 59
 pop di
 ret
 ExitHelper:
  jmp ExitMenu
MainMenu:
  call BlackBackground
  mov ax, 0xb800
  mov es, ax
  mov di, 1016
  push di
  push word 0xf4
  push word TitleText
  call printstr
  mov di, 1512
  push di
  push word 0x07
  push word NewGame
  call printstr
  mov di, 1832
  push di
  push word 0x07
  push word Credits
  call printstr
  mov di, 2148
  push di
  push word 0x07
  push word Instructions
  call printstr
  mov di, 2476
  push di
  push word 0x07
  push word Exit
  call printstr
  mov di, 1500
  PointerMovement:
    mov ah, 0x87
    mov al, '.'
    mov [es:di], ax
    mov ah, 0
    int 0x16
    cmp al, 's'       ; down key pressed
    je MoveDown
    cmp al, 'w'       ; up
    je MoveUp
    cmp al, 0x0d       ; enter
    je EnterMenu
    jmp PointerMovement
    MoveDown:
      mov word[es:di] , 0x0720
      add di, 320
      cmp di, 2460
      jg PointToStart
      jmp PointerMovement
     MoveUp:
       mov word[es:di] , 0x0720
       sub di, 320
       cmp di, 1500
       jl PointToBottom
       jmp PointerMovement
    PointToStart:
       mov di , 1500
       jmp PointerMovement
    PointToBottom:
      mov di , 2460
      jmp PointerMovement
    EnterMenu:
      cmp di, 1500
      je start
      cmp di, 1820
      je EnterCredits
      cmp di, 2140
      je EnterInstructions
      cmp di, 2460
      je ExitMenu
    EnterCredits:
        call BlackBackground
        mov di , 1960
        push di
        push word 0x07
        push word CreditsText
        call printstr
    BackToMainScreen:
        mov ah , 0
        int 0x16
        cmp al , 'b'
        je MainMenu
        jmp BackToMainScreen
    EnterInstructions:
        call BlackBackground
        mov di , 1960
        push di
        push word 0x07
        push word InstructionsText
        call printstr
    BackToMainMenu:
        mov ah , 0
        int 0x16
        cmp al , 'b'
        je MainMenu
        jmp BackToMainMenu
    ExitMenu:
        call BlackBackground
        push word 1990
        push word 0x87
        push word ExitText
        call printstr
        push word 2312
        push word 0x70
        push word scoreTXT
        call printstr
        mov di, 2324
        push word [scoreINT]
        call printNum
        jmp exit
 start:
  push word 0xb800
  pop es
  call cls
  ; INNER ARENA
  mov ax, 23                            ; y3, y4
  push ax                               ; +6
  mov ax, 0x0720                        ; color attribute
  push ax                               ; +4
  call printArena                       ; Prints the square arena
  mov di, 600
  push di
  push byte 0x20
  push word scoreTXT
  call printstr
  call generateRandom
  mov word [temp], dx
main:
 mov di, 1400
 push word[temp]
 push 0xfb20
 call printShapes
 mov di, 612
 push word [scoreINT]
 call printNum
 call clock
 mov di, 1400
 call generateRandom
 push dx
 push 0x2420
 call printShapes
 xchg dx, [temp]
 mov di, 850
 helperCalle:
    cmp dx, 0
    je printL
    cmp dx, 1
    je printJ
    cmp dx, 2
    je printSquare
    jmp printRectangle
 printL:
  push dx
  push word 0x4220
  call printShapes
  call stopCheck
  call delay
  push dx
  push word 0xfb20
  call printShapes
  jmp move
 printJ:
  push dx
  push word 0x5220
  call printShapes
  call stopCheck
  call delay
  push dx
  push word 0xfb20
  call printShapes
  jmp move
 printSquare:
  push dx
  push word 0x6320
  call printShapes
  call stopCheck
  call delay
  push dx
  push word 0xfb20
  call printShapes
  jmp move
 printRectangle:
  push dx
  push word 0x2420
  call printShapes
  call stopCheck
  call delay
  push dx
  push word 0xfb20
  call printShapes
 move:
  xor ax, ax
  in al, 0x60
  cmp al, 0x4b
  je moveLeft
  cmp al, 0x4d
  je moveRight
  cmp al, 0x19
  je pauseGame
  cmp al, 0x12
  je ExitMenu
  jmp moveDown
 pauseGame:
    mov ah, 0
    int 0x16
    cmp al, 'r'
    je moveDown
    cmp al, 'e'
    je ExitMenu
    jmp pauseGame
 moveLeft:
  cmp word[es:di-4], 0xfb20
  jne moveDown
  cmp word[es:di-2], 0xfb20
  jne moveDown
  cmp word[es:di], 0xfb20
  jne moveDown
  cmp word[es:di+158], 0xfb20
  jne moveDown
  cmp word[es:di+156], 0xfb20
  jne moveDown
  sub di, 4
  jmp moveDown
 moveRight:
  add di, 4
 moveDown:
  add di, 160
  jmp helperCalle
 stopCheck:
  cmp word[es:di + 160], 0xfb20
  jne popAByte
  mov bx, di
  cmp dx, 2
  je checkSquare
  cmp dx, 3
  je checkRectangle
  checkLandJ:
    mov cx, 3
    checkLandJLoop:
     add bx, 2
     cmp word[es:bx+160], 0xfb20
     jne popAByte
     loop checkLandJLoop
    jmp goBack
  checkSquare:
   add bx, 2
   cmp word[es:bx+160], 0xfb20
   jne popAByte
   jmp goBack
  checkRectangle:
   mov cx, 7
   checkRectangleLoop:
    add bx, 2
    cmp word[es:bx+160], 0xfb20
    jne popAByte
    loop checkRectangleLoop
  goBack:
   ret
 popAByte:
  add sp, 2
  mov bx, di
  push bx
  checkLeft:
   cmp word [es:bx], 0xfb20 ; background
   je main
   cmp word [es:bx], 0x0720 ; black boundary
   je checkRight
   sub bx, 2
   jmp checkLeft
  checkRight:
   pop bx
   checkRightLoop:
    cmp word [es:bx], 0xfb20
    je main
    cmp word [es:bx], 0x0720
    je scrolldown
    add bx, 2
    jmp checkRightLoop
 exit:
   mov ax, 0x4c00
   int 21h