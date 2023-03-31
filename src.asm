ORG 0H
LJMP MAIN

ORG 0023H ;serial interrupt


;PROGRAM
MAIN:
	ACALL LCD_SETUP
	ACALL UART_SETUP
	MOV R1, #30H

START:		;writes characters to the LCD
	MOV A, @R1
	JZ FINISH
	ACALL LCD_WRITE_CHAR
	INC R1
	JMP START

FINISH:
	JMP $

;8051 SETUP INSTRUCTIONS
;DEFINE CONSTANTS

UART_SETUP:
	CLR SM0		;|
	SETB SM1	;|put serial port in 8 bit UART mode

	MOV A, PCON	;|
	SETB ACC.7	;|
	MOV PCON, A	;| set SMOD in PCON to double baud rate

	MOV TMOD, #20H	;set timer 1 in mode 2, 8 bit reload
	MOV TH1, #243	;set to -13 so that it resets every 13us
	MOV TL1, #243	;set the low bit to -13 as well so that it will reset after 13us on the first iteration
	SETB TR1		;start timer 1

	RET

LCD_SETUP:
	BUSY_FLAG_TIME EQU 25	; the amount of time needed to clear the LCD busy flag

	CLR P0.7 ; TURN 7 SEGMENT DISPLAYS OFF
	;LCD P1, P1.2 = ENABLE, P1.3 = REGISTER SELECT
	;LCD IS A HD44780

;LCD 4 BIT MODE SELECT

	CLR P1.3		; clear RS - indicates that instructions are being sent to the module

; function set	
	CLR P1.7		; |
	CLR P1.6		; |
	SETB P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL LCD_DELAY		; wait for BF to clear	

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E
					; same function set high nibble sent a second time

	SETB P1.7		; low nibble set (only P1.7 needed to be changed)

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL LCD_DELAY		; wait for BF to clear


; entry mode set
; set to increment with no shift
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	SETB P1.6		; |
	SETB P1.5		; |low nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL LCD_DELAY		; wait for BF to clear

; display on/off control
; the display is turned on, the cursor is turned on and blinking is turned on
	CLR P1.7		; |
	CLR P1.6		; |
	CLR P1.5		; |
	CLR P1.4		; | high nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	SETB P1.7		; |
	SETB P1.6		; |
	SETB P1.5		; |
	SETB P1.4		; | low nibble set

	SETB P1.2		; |
	CLR P1.2		; | negative edge on E

	CALL LCD_DELAY		; wait for BF to clear

	SETB P1.3
	RET

;LCD READY FOR DATA INPUT

LCD_WRITE_CHAR:
		MOV C, ACC.7
		MOV P1.7, C 
		MOV C, ACC.6
		MOV P1.6, C 
		MOV C, ACC.5
		MOV P1.5, C 
		MOV C, ACC.4
		MOV P1.4, C

		SETB P1.2
		CLR P1.2

		MOV C, ACC.3
		MOV P1.7, C 
		MOV C, ACC.2
		MOV P1.6, C 
		MOV C, ACC.1
		MOV P1.5, C 
		MOV C, ACC.0
		MOV P1.4, C

		SETB P1.2
		CLR P1.2

		ACALL LCD_DELAY
		RET

LCD_DELAY:
		MOV R0, #BUSY_FLAG_TIME
		DJNZ R0, $
		RET
END