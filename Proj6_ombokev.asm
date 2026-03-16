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
; Prompt user to enter string and store the users input.
;
; Preconditions: string is valid addresses to a string,
; strSize is a unsigned integer, and output is a valid memory location.
; 
; Receives:
; string		= string address
; strSize		= max size of input string
; input			= offset of input string
; strLen		= actual length of input string
;
; Returns: 
; input			= offset to store user's input
; strLen		= the number of bytes read from user input string
; --------------------------------------------------------
mGetString		MACRO	string, strSize, input, strLen

	PUSH	EDX
	PUSH	ECX
	PUSH	EAX
	PUSH	EBX

	; Display prompt message.
	MOV		EDX, OFFSET string
	CALL	WriteString

	; Get users input
	MOV		EDX, OFFSET input
	MOV		ECX, strSize
	CALL	ReadString
	CALL	CrLf
	MOV		EBX, OFFSET strLen
	MOV		[EBX], EAX			; Store length of input string in memory.

	POP		EBX
	POP		EAX
	POP		ECX
	POP		EDX
ENDM

; --------------------------------------------------------
; Name: mDisplayString
;
; Print a string which is stored in a specific memory location.
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
; Print an ASCII-formatted character that is provided as an 
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
TEMPS_PER_DAY = 24
INVALID_HANDLE_VALUE = -1
BUFFER_SIZE = 500

.data  
intro			BYTE	"Welcome to the Temperature Organizer!",13,10,13,10,
						"This program will read a comma-delimited (',') file storing ", 
						"a series of temperature values. The file must be ASCII-formatted. ",
						"The program will then reverse the ordering and print the corrected temperature ordering.",13,10,13,10,0
prompt			BYTE	"Enter the name of the file to be read: ",0
userInput		BYTE	MAXSIZE DUP(?)	
userStrLen		DWORD	?
tempArray		SDWORD	TEMPS_PER_DAY DUP(?)
fileBuffer		BYTE	BUFFER_SIZE DUP(?)
fileHandle		DWORD	?
bytesRead		DWORD	?





.code
main PROC
  
	; Introduce program to user.
	mDisplayString	intro

	; Prompt user and store user input.
	mGetString	prompt, MAXSIZE, userInput, userStrLen	

	; Open file
	MOV		EDX, OFFSET userInput
	CALL	OpenInputFile
	CMP		EAX, INVALID_HANDLE_VALUE
	JE		_HandleInvalidFile
	MOV		fileHandle, EAX		; Store file handle

	; Read values from file
	MOV		ECX, SIZEOF fileBuffer
	MOV		EDX, OFFSET fileBuffer
	CALL	ReadFromFile
	MOV		bytesRead, EAX

	; Close file
	MOV		EAX, fileHandle
	CALL	CloseFile
	JMP		_Continue

_HandleInvalidFile:
	CALL	WriteWindowsMsg		; Displays error message for invalid file handle.
	CALL	CrLf
	JMP		_Exit

_Continue:

	; Read temps from user inputed file.
	PUSH	bytesRead
	PUSH	OFFSET fileBuffer	
	PUSH	OFFSET tempArray
	CALL	parseTempsFromString

	; Reverse tempArray
	PUSH	OFFSET tempArray
	CALL	writeTempsReverse

_Exit:

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; --------------------------------------------------------
; Name: parseTempsFromString
;
; Read string formatted integer values from a file. Convert values
; from file into their numeric value representations. Store converted 
; values in an array.
;
; Preconditions: file buffer is filled with ascii values and bytesRead > 0
;
; Postconditions: None
; 
; Receives: tempArray offset, fileBuffer offset, bytesRead
;
; Returns: tempArray
; --------------------------------------------------------
parseTempsFromString PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	EDI
	PUSH	EDX
	PUSH	ECX
	PUSH	EBX
	PUSH	EAX

	; CHEAT SHEET
	; [EBP + 16] = bytesRead
	; [EBP + 12] = fileBuffer offset
	; [EBP + 8] = tempArray offset
	; [EBP + 4] = return address
	
	MOV		ESI, [EBP + 12]		; Read from file buffer.
	MOV		EDI, [EBP + 8]		; Store temps in tempArray.

	MOV		EDX, 0				; Track number of stored.
	MOV		ECX, [EBP + 16]		; Loop bytesRead times	
_ParseTempLoop:
	LODSB
	DEC		ECX					; Manually decrement ECX
	JZ		_Exit				

	CMP		AL, DELIMITER		; Check if current value is a delimiter character.
	JE		_ParseTempLoop			

	MOV		EBX, 0				; Track negative values (1=negative, 0=positive)
	CMP		AL, '-'				
	JNE		_IsDigit			; If current value is not a negative sign, convert it.
	MOV		EBX, 1				
	LODSB						; If current value is a negative sign, get next value.
	DEC		ECX

_IsDigit:
	PUSH	EDX					; Preserve temp tracker
	PUSH	EBX					; Preserve negative flag

	MOV		EBX, 0				; Hold converted digit
	MOV		EDX, 0				; Initialize Accumulator
	
_ConversionLoop:
	SUB		AL, '0'				; (ASCII value - 48 = digit)
	MOVZX	EBX, AL
	MOV		EAX, EDX			; EAX = 0
	IMUL	EAX, 10
	ADD		EAX, EBX			; Add digit to total in EAX
	MOV		EDX, EAX			; Store total in accumulator

	LODSB
	DEC		ECX	

	; Check if next value is digit.
	CMP		AL, '0'
	JB		_DoneConverting
	CMP		AL, '9'
	JA		_DoneConverting
	JMP		_ConversionLoop		; Next value is a digit.

_DoneConverting:
	POP		EBX					; Restore negation flag
	CMP		EBX, 1				;Check if value is negative
	JE		_NegateTemp
	JMP		_StoreTemp

_NegateTemp:
	NEG		EDX

_StoreTemp:
	MOV		EAX, EDX
	STOSD
	POP		EDX					; Restore temp tracker
	CMP		EDX, TEMPS_PER_DAY	; Check if we have all the temps we need.
	JA		_Exit
	INC		EDX					; Add temp to temp tracker.
	JMP		_ParseTempLoop

_Exit:
	
	POP		EAX
	POP		EBX
	POP		ECX
	POP		EDX
	POP		EDI
	POP		ESI
	POP		EBP
	RET		12

parseTempsFromString ENDP

; --------------------------------------------------------
; Name: writeTempsReverse
;
; Take values from an array and print them in reverse order.
;
; Preconditions: tempArray is filled with at least one temperature
;
; Postconditions: None.
; 
; Receives: tempArray offset
;
; Returns: None.
; --------------------------------------------------------
writeTempsReverse PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX

	; CHEAT SHEET
	; [EBP + 8] = tempArray offset
	; [EBP + 4] = return address

	MOV		ESI, [EBP + 8]		; Store address of tempArray

	; Calculate address of last element.
	MOV		EAX, TEMPS_PER_DAY 		
	DEC		EAX
	MOV		EBX, 4
	MUL		EBX
	ADD		ESI, EAX			; ESI = (TEMPS_PER_DAY - 1) * TYPE tempArray.

	MOV		ECX, TEMPS_PER_DAY
	
_RevLoop:
	STD							; Set direction flag to decrement pointer.
	LODSD						; Store value in ESI into EAX.
	CALL	WriteInt			
	mDisplayChar DELIMITER
	LOOP	_RevLoop
	CLD							;Clear direction flag.
	CALL	CrLf

	POP		ECX
	POP		EBX
	POP		EAX
	POP		ESI
	POP		EBP
	RET		4

writeTempsReverse ENDP


END main
