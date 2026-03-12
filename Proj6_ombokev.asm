TITLE MASM Temperature Organizer   (Proj6_ombokev.asm)

; Author: 
; Last Modified:
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section:   CS271 Section ???
; Project Number:                 Due Date:
; Description: This program will use string primitives and macros to fetch temperatures 
; from files and re-organize them into their appropriate order.

INCLUDE Irvine32.inc

; (insert macro definitions here)

; --------------------------------------------------------
; Name: mGetString
;
;  Prompt user to enter string and store the users input.
;
; Preconditions: promptOffset and userInputAddress are valid addresses.
; 
; Receives:
; promptOffset	= prompt string address
; userInp		= the user's input
; count			= length of input string
; bytesRead		= number of bytes read by macro
;
; Returns: 
; userInp		= users input
; bytesRead		= the number of bytes read when reading the string.
; --------------------------------------------------------
mGetString		MACRO	promptOffset, userInp, count, bytesRead


ENDM

; --------------------------------------------------------
; Name: mDisplayString
;
;  Print a string which is stored in a specific memory location.
;
; Preconditions: strOff contain a valid memory address of a string.
; 
; Receives:
; strOff = adress of a string
;
; Returns: None
; --------------------------------------------------------
mDisplayString	MACRO	stringOff
	PUSH	EDX

	MOV		EDX, OFFSET stringOff
	CALL	WriteString

	POP		EDX
ENDM

; (insert constant definitions here)


.data  
intro		BYTE	"Welcome to the Temperature Organizer!",13,10,13,10,
					"This program will read a comma-delimited (',') file storing ", 
					"a series of temperature values. The file must be ASCII-formatted. ",
					"The program will then reverse the ordering and print the corrected temperature ordering.",13,10,13,10,0
prompt		BYTE	"Enter the name of the file to be read: ",0
userInput	SDWORD	?




.code
main PROC
  
	; Introduce program to user.
	mDisplayString		intro

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; --------------------------------------------------------
; Name: introduction
;
; Introduce the program to the user and explain it's finctionality. 
;
; Precinditions: intro is a string.
;
; Postconditions: None
;
; Receives: intro
; 
; Returns: None
; --------------------------------------------------------
introduction PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDX

	; CHEAT SHEET
	; [EBP + 8] = intro offset
	; [EBP + 4] = return address

	MOV		EDX, [EBP + 8]
	CALL	WriteString
	CALL	CrLf

	POP		EDX
	POP		EBP
	RET		4

introduction ENDP
	

END main
