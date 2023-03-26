ORG 0H
;8051 SETUP INSTRUCTIONS

;DEFINE CONSTANTS

	BUSY_FLAG_TIME EQU 25	; the amount of time needed to clear the LCD busy flag

	CLR P0.7 ; TURN 7 SEGMENT DISPLAYS OFF
	;LCD P1, P1.2 = ENABLE, P1.3 = REGISTER SELECT
	;LCD IS A HD44780

;DATA LOADED INTO MEMORY TO BE DISPLAYED
	MOV 30H, #'M'
	MOV 31H, #'S'
	MOV 32H, #'E'
	MOV 33H, #'3'
	MOV 34H, #'5'
	MOV 35H, #'2'
	MOV 36H, #0
	


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

;LCD READY FOR DATA INPUT

;PROGRAM

	MOV R1, #30H

START:
	MOV A, @R1
	JZ FINISH
	ACALL LCD_WRITE_CHAR
	INC R1
	JMP START

FINISH:
	JMP $

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