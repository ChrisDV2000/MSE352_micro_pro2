ORG 0H

start:
	SETB P3.3
	SETB P3.4

	SETB P2.0
	MOV P1, #11000000B
	ACALL delay

	CLR P3.3

	SETB P2.1
	MOV P1, #11111001B
	ACALL delay
	
	SETB P3.3
	CLR P3.4

	SETB P2.2
	MOV P1, #10100100B
	ACALL delay

	CLR P3.3

	SETB P2.3
	MOV P1, #10110000B
	ACALL delay
		
	SJMP start

delay:
	MOV R0, #200
here:
	DJNZ R0, here
RET

END

	CLR SM0			; |
	SETB SM1		; | put serial port in 8-bit UART mode

	MOV A, PCON		; |
	SETB ACC.7		; |
	MOV PCON, A		; | set SMOD in PCON to double baud rate

	MOV TMOD, #20H		; put timer 1 in 8-bit auto-reload interval timing mode
	MOV TH1, #243		; put -13 in timer 1 high byte (timer will overflow every 13 us)
	MOV TL1, #243		; put same value in low byte so when timer is first started it will overflow after 13 us
	SETB TR1		; start timer 1

	MOV 30H, #'a'		; |
	MOV 31H, #'b'		; |
	MOV 32H, #'c'		; | put data to be sent in RAM, start address 30H

	MOV 33H, #0		; null-terminate the data (when the accumulator contains 0, no more data to be sent)
	MOV R0, #30H		; put data start address in R0
again:
	MOV A, @R0		; move from location pointed to by R0 to the accumulator
	JZ receive		; if the accumulator contains 0, no more data to be sent, jump to finish
	MOV C, P		; otherwise, move parity bit to the carry
	MOV ACC.7, C		; and move the carry to the accumulator MSB
	MOV SBUF, A		; move data to be sent to the serial port
	INC R0			; increment R0 to point at next byte of data to be sent
	JNB TI, $		; wait for TI to be set, indicating serial port has finished sending byte
	CLR TI			; clear TI
	JMP again		; send next byte

receive:
	CLR SM0			; |

	SETB REN		; enable serial port receiver

	MOV A, PCON		; |
	SETB ACC.7		; |
	MOV PCON, A		; | set SMOD in PCON to double baud rate

	MOV TMOD, #20H		; put timer 1 in 8-bit auto-reload interval timing mode
	MOV TH1, #0FDH		; put -3 in timer 1 high byte (timer will overflow every 3 us)
	MOV TL1, #0FDH		; put same value in low byte so when timer is first started it will overflow after approx. 3 us
	SETB TR1		; start timer 1
	MOV R1, #30H		; put data start address in R1
wait:
	JNB RI, $		; wait for byte to be received
	CLR RI			; clear the RI flag
	MOV A, SBUF		; move received byte to A
	CJNE A, #0DH, skip	; compare it with 0DH - it it's not, skip next instruction
	JMP finish		; if it is the terminating character, jump to the end of the program
skip:
	MOV @R1, A		; move from A to location pointed to by R1
	INC R1			; increment R1 to point at next location where data will be stored
	JMP wait		; jump back to waiting for next byte
finish:
	JMP $			; do nothing
END