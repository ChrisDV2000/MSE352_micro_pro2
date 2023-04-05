ORG 30H

MAIN:
	ACALL LCD_SETUP		;setup LCD display
	ACALL UART_SETUP	;setup UART
	ACALL STARTUP		;display "Enter Password" on both UART and the LCD
	ACALL PIN_INPUT		;allows user 3 attempts to input a password
	ACALL LED_ANIMATION	;do a 5 second LED animation

QUIT:
	JMP $	;infinite loop

;-------------End of Main--------------

;-----------Setup Functions------------
LCD_SETUP:
	;LCD P1, P1.2 = ENABLE, P1.3 = REGISTER SELECT
	;LCD IS A HD44780
	
	CLR P0.7 ; TURN 7 SEGMENT DISPLAYS OFF

	CLR RS		; clear RS - indicates that instructions are being sent to the module

	CALL FUNCTION_SET; 	function set	to 4 bit mode
	CALL ENTRY_MODE;	entry mode set - shift cursor to the right
	CALL DISP_CON; 		turn display and cursor on/off

	RET ;LCD READY FOR DATA INPUT

UART_SETUP:
	CLR SM0		;|
	SETB SM1	;|put serial port in 8 bit UART mode

	SETB REN	;|enable serial port reciever 

	MOV A, PCON	;|
	SETB ACC.7	;|
	MOV PCON, A	;| set SMOD in PCON to double baud rate

	MOV TMOD, #20H	;set timer 1 in mode 2, 8 bit reload
	MOV TH1, #253	;set to -13 so that it resets every 13us												|
	MOV TL1, #253	;set the low bit to -13 as well so that it will reset after 13us on the first iteration	|this sets the baud rate to 4800
	SETB TR1		;start timer 1

	RET

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

;---------End of Setup Functions-------

;-----------Program Functions----------
;KEYPAD PIN INPUT
	PIN_INPUT:
		MOV R4, #00H		;counter for checking number of scans
		MOV R5, #00H		;counter for checking the correctness of the pin
		MOV DPTR, #LUT4		;calling the look-up table 4

	;Entering the PIN on the keypad
	KEY_ITERATE:
		ACALL KEY_PAD_ENTRY	;scanning the key input
		SETB RS				;selecting data register, RS=1
		CLR A
		MOV A, #'*'
		ACALL LCD_WRITE_CHAR	;Displaying '*' instead of the PIN


	;Checking for the correctness of the code
		CLR A
		MOVC A, @A+DPTR	;looK-up table for the correct PIN
		ACALL CHECK_INPUT	;Function checking if each input is correct
		INC DPTR		
		INC R4
		CJNE R4, #04H, KEY_ITERATE
		CJNE R5, #04H, WRONG_CODE	;If the input is wrong

	;If the PIN is correct
	RIGHT_CODE:
		ACALL LCD_CURSOR_POS	;Moving the cursor to the next line
		SETB RS			;Selecting data register, RS=1
		ACALL LED_ANIMATION
		ACALL ACCESS_GRANTED

	;If the PIN is wrong
	WRONG_CODE:
		ACALL LCD_CURSOR_POS	;Moving the cursor to the next
		SETB RS			;Selecting data register, RS=1
		ACALL LED_ANIMATION
		ACALL ACCESS_DENIED

	CHECK_INPUT:
		CJNE A, 07H, INPUT_RETURN ;stores the code entered
		INC R5
		INPUT_RETURN:
			RET

KEY_PAD_ENTRY:
	CLR P0.3		;clear row 3
	CALL ID_CODE_0	;call function to scan row
	SETB P0.3		;set row 3
	JB F0, KEY_DONE		;if F0 is set end scan

	CLR P0.2		;clear row 2
	CALL ID_CODE_1	;call function to scan row
	SETB P0.2		;set row 3
	JB F0, KEY_DONE		;if F0 is set end scan
	
	CLR P0.1		;clear row 3
	CALL ID_CODE_2	;call function to scan row
	SETB P0.1		;set row 3
	JB F0, KEY_DONE		;if F0 is set end scan
	
	CLR P0.0		;clear row 3
	CALL ID_CODE_3	;call function to scan row
	SETB P0.0		;set row 3
	JB F0, KEY_DONE		;if F0 is set end scan

	JMP KEY_PAD_ENTRY

	KEY_DONE:
		CLR F0			;clear F0 flag before exit
		RET

ID_CODE_0:
	JNB P0.4, KEY_CODE_03	;key found if col 0 and row 3 is cleared
	JNB P0.5, KEY_CODE_13	;key found if col 1 and row 3 is cleared
	JNB P0.6, KEY_CODE_23	;key found if col 2 and row 3 is cleared
	RET

KEY_CODE_03:
	SETB F0				;key found: set F0
	MOV R7, #'3'		;code displayed '3'
	RET

KEY_CODE_13:
	SETB f0				;key found: set f0
	MOV R7, #'2'		;code displayed '2'
	RET

KEY_CODE_23:
	SETB F0				;key found: set F0
	MOV R7, #'1'		;code displayed '1'
	RET

ID_CODE_1:
	JNB P0.4, KEY_CODE_02	;key found if col 0 and row 2 is cleared
	JNB P0.5, KEY_CODE_12	;key found if col 1 and row 2 is cleared
	JNb P0.6, KEY_CODE_22 ;Key found if col 2 and row 2 is cleared
	RET

KEY_CODE_02:
	SETB F0				;key found: set F0
	MOV R7, #'6'		;code displayed '6'
	RET

KEY_CODE_12:
	SETB F0				;key found: set F0
	MOV R7, #'5'		;code displayed '5'
	RET

KEY_CODE_22:
	SETB F0				;key found: set F0
	MOV R7, #'4'		;code displayed '4'
	RET

ID_CODE_2:
	JNB P0.4, KEY_CODE_01	;key found if col 0 and row 1 is cleared
	JNB P0.5, KEY_CODE_11	;key found if col 1 and row 1 is cleared
	JNB P0.6, KEY_CODE_21	;key found if col 2 and row 1 is cleared
	RET

KEY_CODE_01:
	SETB F0				;key found: set F0
	MOV R7, #'9'		;code displayed '9'
	RET

KEY_CODE_11:
	SETB F0				;key found: set F0
	MOV R7, #'8'		;code displayed '8'
	RET

KEY_CODE_21:
	SETB F0				;key found: set F0
	MOV R7, #'7'		;code displayed '7'
	RET

ID_CODE_3:
	JNB P0.4, KEY_CODE_00 ;key found if col 0 and row 0 is cleared
	JNB P0.5, KEY_CODE_10	;key found of col 1 and row 0 is cleared
	JNB P0.6, KEY_CODE_20	;key found of col 2 and row 0 is cleared 
	RET

KEY_CODE_00:
	SETB F0				;key found: set F0
	MOV R7, #'#'		;code displayed '#'
	RET

KEY_CODE_10:
	SETB F0				;key found: set F0
	MOV R7, #'0'		;code displayed '0'
	RET

KEY_CODE_20:
	SETB F0				;key found: set F0
	MOV R7, #'*'		;code displayed '*'
	RET

;==========SERIAL==========
SERIAL:
	CLR A
	MOVC A, @A + DPTR		;move the next character into the accumulator
	INC DPTR				;increment the data pointer
	JZ FINISH_SERIAL		;the last value is sent so the function returns
	MOV SBUF, A				;move the data in the accumulator into SBUF to be sent out by UART
	L1: JNB TI, L1				;check TI flag until it is set
		CLR TI					;clear TI flag
		SJMP SERIAL				;jump back to the beginning
	FINISH_SERIAL:
		RET

;=================LCD DISPLAY=============

LCD_CURSOR_POS:
	CLR RS
	SETB P1.7	;setting the DDRAM address
	SETB P1.6	;Address starts here
	CLR P1.5	;High nibble set
	CLR P1.4	;"

	ACALL LCD_CLOCK

	CLR P1.7	;Low nibble set
	CLR P1.6	;"
	CLR P1.5	;"
	CLR P1.4	;"

	ACALL LCD_CLOCK

	ACALL LCD_DELAY
	RET

LCD_CLOCK:
	SETB E		; |
	CLR E		; | negative edge on E
	RET

CLEAR_LCD:
	CLR RS
	MOV A, #1
	ACALL LCD_WRITE_CHAR
	SETB RS
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

WRITE_STRING:
	CLR A
	MOVC A, @A + DPTR		;move the next character into the accumulator
	INC DPTR				;increment the data pointer
	CJNE A, #0DH, WRITE		;the last value is sent so the function returns else jump to write char
	RET
	WRITE:
		ACALL LCD_WRITE_CHAR	;write character to LCD
		SJMP WRITE_STRING

;=========DISPLAYS=============

STARTUP:
	MOV DPTR, #START_STR	;make data pointer point to where the start string is
	ACALL SERIAL					;force the serial interrupt
	MOV DPTR, #START_STR	;make data pointer point to where the start string is
	ACALL WRITE_STRING
	RET

ACCESS_GRANTED:
	ACALL CLEAR_LCD
	MOV DPTR, #ACCESS_STR	;make data pointer point to where the start string is
	ACALL SERIAL					;force the serial interrupt
	MOV DPTR, #ACCESS_STR	;make data pointer point to where the start string is
	ACALL WRITE_STRING
	RET

ACCESS_DENIED:
	ACALL CLEAR_LCD
	MOV DPTR, #DENIED_STR	;make data pointer point to where the start string is
	ACALL SERIAL					;force the serial interrupt
	MOV DPTR, #DENIED_STR	;make data pointer point to where the start string is
	ACALL WRITE_STRING
	RET

LOCK_DOWN:
	ACALL CLEAR_LCD
	MOV DPTR, #LOCK_STR	;make data pointer point to where the start string is
	ACALL SERIAL					;force the serial interrupt
	MOV DPTR, #LOCK_STR	;make data pointer point to where the start string is
	ACALL WRITE_STRING
	RET

;=================LEDs=================

LED_ANIMATION:
	MOV P1, #0FFH		;make sure all of the LEDs are off
	CLR P1.7			;turn each LED on in turn from left to right
	ACALL LED_DELAY
	CLR P1.6
	ACALL LED_DELAY
	CLR P1.5
	ACALL LED_DELAY
	CLR P1.4
	ACALL LED_DELAY
	CLR P1.3
	ACALL LED_DELAY
	CLR P1.2
	ACALL LED_DELAY
	CLR P1.1
	ACALL LED_DELAY
	CLR P1.0
	MOV P1, #0FFH		;shut all of the LEDs off
	RET

LED_DELAY:	; 0.625 second delay
	MOV TMOD, #01H
	MOV R5, #11
	MOV TL0, #00H
	MOV TH0, #00H
	SETB TR0
	CHECK_OF:
		JNB TF0, CHECK_OF
		CLR TF0
		DJNZ R5, CHECK_OF
		CLR TR0
		RET


ORG 1000H
	BUSY_FLAG_TIME EQU 25	; the amount of time needed to clear the LCD busy flag
	UART_DATA EQU 64 ; where recieved UART data is stored in ram
	RS EQU P1.3
	E EQU P1.2
	START_STR: DB 'E','n','t','e','r',' ','P','a','s','s','c','o','d','e',':',0DH,0
	ACCESS_STR: DB 'A','c','c','e','s','s',' ','G','r','a','n','t','e','d',0DH,0
	DENIED_STR: DB 'A','c','c','e','s','s',' ','D','e','n','i','e','d',0DH,0
	LOCK_STR: DB 'L','O','C','K',' ','D','O','W','N',0DH,0

ORG 1200H
	LUT4:	DB '0', '3', '5', '2', 0

END