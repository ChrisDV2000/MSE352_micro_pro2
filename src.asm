ORG 0H
LJMP MAIN

ORG 0023H ;serial interrupt
LJMP SERIAL
RETI

;PROGRAM
MAIN:
	ACALL CONSTANTS
	ACALL INTERRUPTS
	ACALL LCD_SETUP
	ACALL UART_SETUP
	MOV R1, #30H

START:		;writes characters to the LCD
	MOV A, @R1
	JZ QUIT
	ACALL LCD_WRITE_CHAR
	INC R1
	JMP START

QUIT:
	JMP $

;------------End of Main-------------

;8051 SETUP INSTRUCTIONS

INTERRUPTS:
	MOV IE, #90H

UART_SETUP:
	CLR SM0		;|
	SETB SM1	;|put serial port in 8 bit UART mode

	SETB REN	;|enable serial port reciever 

	MOV A, PCON	;|
	SETB ACC.7	;|
	MOV PCON, A	;| set SMOD in PCON to double baud rate

	MOV TMOD, #20H	;set timer 1 in mode 2, 8 bit reload
	MOV TH1, #243	;set to -13 so that it resets every 13us												|
	MOV TL1, #243	;set the low bit to -13 as well so that it will reset after 13us on the first iteration	|this sets the baud rate to 4800
	SETB TR1		;start timer 1

	RET

SERIAL:
	MOV R1, #UART_DATA
	MOV R0, #UART_DATA
RECEIVE:
	JNB RI, SEND
	CLR RI
	MOV A, SBUF
	CJNE A, #0DH, SKIP
	JMP SEND
SKIP:
	MOV @R1, A
	INC R1
	JMP RECEIVE
SEND:
	MOV @R0, A
	JZ FINISH
	MOV SBUF, A
	INC R0
	JNB TI, $
	CLR TI
	SETB RI
	JMP RECEIVE

FINISH:
	RET

CONSTANTS:
	BUSY_FLAG_TIME EQU 25	; the amount of time needed to clear the LCD busy flag
	UART_DATA EQU 64 ; where recieved UART data is stored in ram
	RS EQU P1.3
	E EQU P1.2

LCD_SETUP:
	;LCD P1, P1.2 = ENABLE, P1.3 = REGISTER SELECT
	;LCD IS A HD44780
	
	CLR P0.7 ; TURN 7 SEGMENT DISPLAYS OFF

	CLR RS		; clear RS - indicates that instructions are being sent to the module

	CALL FUNCTION_SET; 	function set	to 4 bit mode
	CALL ENTRY_MODE;	entry mode set - shift cursor to the right
	CALL DISP_CON; 		turn display and cursor on/off

	RET ;LCD READY FOR DATA INPUT

FUNCTION_SET:
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	CALL LCD_CLOCK

	CALL LCD_DELAY		; wait for BF to clear	

	CALL LCD_CLOCK ; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	CALL LCD_CLOCK

	CALL LCD_DELAY		; wait for BF to clear
	RET

DISP_CON:
	; display on/off control
	; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	CALL LCD_CLOCK

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	CALL LCD_CLOCK

	CALL LCD_DELAY		; wait for BF to clear

	SETB RS
	RET

ENTRY_MODE:
	; entry mode set
	; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	CALL LCD_CLOCK

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	CALL LCD_CLOCK

	CALL LCD_DELAY		; wait for BF to clear
	RET

LCD_CLOCK:
	SETB E		; |
	CLR E		; | negative edge on E
	RET

LCD_WRITE_CHAR:
	MOV C, ACC.7
	MOV P1.7, C 
	MOV C, ACC.6
	MOV P1.6, C 
	MOV C, ACC.5
	MOV P1.5, C 
	MOV C, ACC.4
	MOV P1.4, C

	CALL LCD_CLOCK

	MOV C, ACC.3
	MOV P1.7, C 
	MOV C, ACC.2
	MOV P1.6, C 
	MOV C, ACC.1
	MOV P1.5, C 
	MOV C, ACC.0
	MOV P1.4, C

	CALL LCD_CLOCK

	ACALL LCD_DELAY
	RET

LCD_DELAY:
		MOV R0, #BUSY_FLAG_TIME
		DJNZ R0, $
		RET
END