Org 0000h

RS	Equ P1.3
E	Equ P1.2

;Main Function
Main:
	Clr RS
	Call FuncSet	;Calling Function Set
	Call DispCon	;Turning on Display and Cursor
	Call EntryMode	;Shifting cursor to the right by 1

	SetB RS			;selecting data register, RS = 1

	Mov DPTR, #LUT1	;Look-up table for string "Enter code"

Again:
	Clr A
	Movc A, @A+DPTR	;Get the character
	Jz Next			;Exit when A=0
	Call SendChar	;Displaying character
	Inc DPTR		;pointing to the next character
	Jmp Again		

Next:
	Mov R4, #00h	;counter for checking number of scans
	Mov R5, #00h	;counter for checking the correctness of the pin
	Mov DPTR, #LUT4	;calling the look-up table 4


;Entering the PIN on the keypad
Iterate:
	Call ScanKeyPad	;scanning the key input
	SetB RS			;selecting data register, RS=1
	Clr A
	Mov A, #'*'
	Call SendChar	;Displaying '*' instead of the PIN

;-----------------already moved--------------------------

;Checking for the correctness of the code
	Clr A
	Movc A, @A+DPTR	;looK-up table for the correct PIN
	Call CheckInput	;Function checking if each input is correct
	Inc DPTR		
	INC R4
	Cjne R4, #04h, Iterate
	Cjne R5, #04h, Wrong	;If the input is wrong

;If the PIN is correct
Right:
	Call CursorPos	;Moving the cursor to the next line
	SetB RS			;Selecting data register, RS=1
	Call Granted
	Jmp EndHere
	
;If the PIN is wrong
Wrong:
	Call CursorPos	;Moving the cursor to the next
	SetB RS			;Selecting data register, RS=1
	Call Denied

EndHere:
	Jmp $
;End of Main Function

;Defining the Functions called
FuncSet:
	Clr P1.7
	Clr P1.6
	SetB P1.5
	Clr P1.4

	Call Pulse

	Call Delay		

	Call Pulse

	SetB P1.7
	Clr P1.6
	Clr P1.5
	Clr P1.4

	Call Pulse

	Call Delay
	Ret

DispCon:
	Clr P1.7
	Clr P1.6
	Clr P1.5
	Clr P1.4

	Call Pulse

	SetB P1.7
	SetB P1.6		;Setting the Display on
	SetB P1.5		;Cursor On
	SetB P1.4		;Cursor Blinking
	Call Pulse

	Call Delay
	Ret
	
EntryMode:
	Clr P1.7		;P1.7 = 0
	Clr P1.6		;P1.6 = 0
	Clr P1.5		;P1.5 = 0
	Clr P1.4		;P1.4 = 0

	Call Pulse

	Clr P1.7		;P1.7 = 0
	SetB P1.6		;P1.6 = 1
	SetB P1.5		;P1.5 = 1
	Clr P1.4		;P1.4 = 0

	Call Pulse

	Call Delay

Pulse:
	SetB E
	Clr E
	Ret

SendChar:
	Mov C, Acc.7	;High nibble set
	Mov P1.7, C		;"
	Mov C, Acc.6	;"
	Mov P1.6, C		;"
	Mov C, Acc.5	;"
	Mov P1.5, C		;"
	Mov C, Acc.4	;"
	Mov P1.4, C		;"

	Call Pulse

	Mov C, Acc.3	;Low nibble set
	Mov P1.7, C		;"
	Mov C, Acc.2	;"
	Mov P1.6, C		;"
	Mov C, Acc.1	;"
	Mov P1.5, C		;"
	Mov C, Acc.0	;"
	Mov P1.4, C		;"

	Call Pulse

	Call Delay

	Mov R1, #55h
	Ret

Delay:
	Mov R0, #50
	Djnz R0, $
	Ret

ScanKeyPad:	
	Clr P0.3		;clear Row 3
	Call IDCode0	;function to scan column
	SetB P0.3		;Set Row 3
	JB F0, Done		;If, F0 is set, end scan

	Clr P0.2		;clear Row 2
	Call IDCode1	;function to scan column
	SetB P0.2		;Set Row 2
	JB F0, Done		;If, F0 is set, end scan

	Clr P0.1		;clear Row 1
	Call IDCode2	;function to scan column
	SetB P0.1		;Set Row 1
	JB F0, Done		;If, F0 is set, end scan

	Clr P0.0		;clear Row 0
	Call IDCode3	;function to scan column
	SetB P0.0		;Set Row 0
	JB F0, Done		;If, F0 is set, end scan

	Jmp ScanKeyPad	;Repeating the process from Row 3

Done:
	Clr F0
	Ret

IDCode0:
	JNB P0.4, KeyCode03	;key found if Col0 and Row3 is selected
	JNB P0.5, KeyCode13	;Key Found if Col1 and Row3 is selected
	JNB P0.6, KeyCode23	;Key found if Col2 and Row3 is selected
	Ret

KeyCode03:
	SetB F0			;Key found, set F0
	Mov R7, #'3'	;Code for 3
	Ret

KeyCode13:
	SetB F0			;Key found, set F0
	Mov R7, #'2'	;Code for 2
	Ret

KeyCode23:
	SetB F0			;Key found, set F0
	Mov R7, #'1'	;Code for 1
	Ret

IDCode1:
	JNB P0.4, KeyCode02	;key found if Col0 and Row2 is selected
	JNB P0.5, KeyCode12	;Key Found if Col1 and Row2 is selected
	JNB P0.6, KeyCode22	;Key found if Col2 and Row2 is selected
	Ret

KeyCode02:
	SetB F0			;Key found, set F0
	Mov R7, #'6'	;Code for 6
	Ret

KeyCode12:
	SetB F0			;Key found, set F0
	Mov R7, #'5'	;Code for 5
	Ret

KeyCode22:
	SetB F0			;Key found, set F0
	Mov R7, #'4'	;Code for 4
	Ret

IDCode2:
	JNB P0.4, KeyCode01	;key found if Col0 and Row1 is selected
	JNB P0.5, KeyCode11	;Key Found if Col1 and Row1 is selected
	JNB P0.6, KeyCode21	;Key found if Col2 and Row1 is selected
	Ret

KeyCode01:
	SetB F0			;Key found, set F0
	Mov R7, #'9'	;Code for 9
	Ret

KeyCode11:
	SetB F0			;Key found, set F0
	Mov R7, #'8'	;Code for 8
	Ret

KeyCode21:
	SetB F0			;Key found, set F0
	Mov R7, #'7'	;Code for 7
	Ret

IDCode3:
	JNB P0.4, KeyCode00	;key found if Col0 and Row0 is selected
	JNB P0.5, KeyCode10	;Key Found if Col1 and Row0 is selected
	JNB P0.6, KeyCode20	;Key found if Col2 and Row0 is selected
	Ret

KeyCode00:
	SetB F0			;Key found, set F0
	Mov R7, #'#'	;Code for #
	Ret

KeyCode10:
	SetB F0			;Key found, set F0
	Mov R7, #'0'	;Code for 0
	Ret

KeyCode20:
	SetB F0			;Key found, set F0
	Mov R7, #'*'	;Code for *
	Ret

CheckInput:
	Cjne A,07H,Exit ;stores the code entered
	Inc R5

Exit:
	Ret

CursorPos:
	Clr Rs
	SetB P1.7	;setting the DDRAM address
	SetB P1.6	;Address starts here
	Clr P1.5	;High nibble set
	Clr P1.4	;"

	Call Pulse

	Clr P1.7	;Low nibble set
	Clr P1.6	;"
	Clr P1.5	;"
	Clr P1.4	;"

	Call Pulse

	Call Delay
	Ret

;If access if granted
Granted:
	Mov DPTR, #LUT2	;Look-up table for "Access Granted"

GoBack:
	Clr A
	Movc A,@A+DPTR
	Jz Home
	Call SendChar
	Inc DPTR
	Jmp GoBack

Home:
	Ret

;If access is denied
Denied:
	Mov DPTR, #LUT3	;Look-up table for "Access Denied"

OneMore:	
	Clr A
	Movc A,@A+DPTR
	Jz BackHome
	Call SendChar
	Inc DPTR
	Jmp OneMore

BackHome:
	Ret

;Look-up tables
Org 0200h
LUT1:	DB ' ', 'E', 'n', 't', 'e', 'r', ' ', 'P', 'I', 'N', ':', 0
LUT2:	DB 'A', 'c', 'c', 'e', 's', 's', ' ', 'G', 'r', 'a', 'n', 't', 'e', 'd', 0
LUT3:	DB 'A', 'c', 'c', 'e', 's', 's', ' ', 'D', 'e', 'n', 'i', 'e', 'd', 0

;Correct PIN
Org 0240h
LUT4:	DB '0', '3', '5', '2', 0

Stop:
	Jmp $

	End