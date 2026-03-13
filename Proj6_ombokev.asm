TITLE MASM Temperature Organizer   (Proj6_ombokev.asm)

; Author: 
; Last Modified:
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section:   CS271 Section ???
; Project Number:                 Due Date:
; Description: This program will use string primitives and macros to fetch temperatures 
; from files and re-organize them into their appropriate order.

INCLUDE Irvine32.inc

; Macro definitions:

; --------------------------------------------------------
; Name: mGetString
;
;  Prompt user to enter string and store the users input.
;
; Preconditions: strOffset is valid addresses to a string,
; strSize is a unsigned integer, and output is a valid memory location.
; 
; Receives:
; strOffset		= string address
; strSize		= max size of input string
; input			= offset of input string
; strLen		= actual length of input string
;
; Returns: 
; input			= offset to store user's input
; strLen		= the number of bytes read from user input string
; --------------------------------------------------------
mGetString		MACRO	strOffset, strSize, input, strLen

	PUSH	EDX
	PUSH	ECX
	PUSH	EAX

	; Display prompt message.
	MOV		EDX, OFFSET strOffset
	CALL	WriteString

	; Get users input
	MOV		EDX, OFFSET input
	MOV		ECX, strSize
	CALL	ReadString
	CALL	CrLf
	MOV		strLen, EAX			; Store length of input string in memory.

	POP		EAX
	POP		ECX
	POP		EDX
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

; --------------------------------------------------------
; Name: mDisplayChar
;
;  Print an ASCII-formatted character that is provided as an 
; immediate or a constant.
;
; Preconditions: char is an immediate or constant defined value.
; 
; Receives:
; char = character to be displayed.
;
; Returns: None
; --------------------------------------------------------
mDisplayChar	MACRO	char
	PUSH	EAX

	MOV		AL, char
	CALL	WriteChar

	POP		EAX

ENDM

; Constant Definitions.
MAXSIZE	= 100
DELIMITER = ','


.data  
intro		BYTE	"Welcome to the Temperature Organizer!",13,10,13,10,
					"This program will read a comma-delimited (',') file storing ", 
					"a series of temperature values. The file must be ASCII-formatted. ",
					"The program will then reverse the ordering and print the corrected temperature ordering.",13,10,13,10,0
prompt		BYTE	"Enter the name of the file to be read: ",0
userInput	BYTE	MAXSIZE DUP(?)	
userStrLen	DWORD	?




.code
main PROC
  
	; Introduce program to user.
	mDisplayString	intro

	; Prompt user and store user input.
	mGetString		prompt, MAXSIZE, userInput, userStrLen	

	; Test mDisplayChar
	mDisplayChar	DELIMITER

	Invoke ExitProcess,0	; exit to operating system
main ENDP



END main
