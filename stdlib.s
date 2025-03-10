		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _bzero( void *s, int n )
; Parameters
;	s 		- pointer to the memory location to zero-initialize (R0)
;	n		- a number of bytes to zero-initialize (R1)
; Return value
;   none
		EXPORT	_bzero
_bzero
		; implement your complete logic, including stack operations
		CMP		R1, #0	
		ITTE	GT			; check if R1 greater than 0
		PUSHGT	{R3}		; save whatever is in R3
		MOVGT	R3, #0x0	; store 0 byte to R3
		MOVLE	pc, lr		; return if R1 <= 0

; loop entered if R1 > 0
_bzero_loop
		STRB	R3, [R0], #1	; store 0 byte into R0 pointer and increment
		SUBS	R1, R1, #1		; sub counter by 1
		BNE		_bzero_loop
		
		POP		{R3}			; restore R3 if counter == 0
		MOV		PC, LR			; return when counter == 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; char* _strncpy( char* dest, char* src, int size )
; Parameters
;   	dest 	- pointer to the buffer to copy to (R0)
;	src	- pointer to the zero-terminated string to copy from (R1)
;	size	- a total of n bytes (R2)
; Return value
;   dest
		EXPORT	_strncpy
_strncpy
		; implement your complete logic, including stack operations
		CMP		R2, #0	; r2 corresponds to size
		IT		LE
		MOVLE	pc, lr ; return if size <= 0, R0 already set to return value
		
		PUSH 	{R3-R6}	; save R3 and R4, R3 = return value, R4 = temp buffer for chars, R5 = checking dest null terminator, R6 = reached end of src flag
		MOV 	R3, R0	; store beginning of dest to return later		
		MOV		R4, #0	; init registers
		MOV		R5, #0
		MOV		R6, #0
		
_strncpy_loop
		CMP		R6, #1			
		LDRBNE	R4, [R1], #1	; load char from src if have not reached the end
		
		CMP		R4, #0x0		; dest will be padded with zeroes if src has reached end, stop reading from src
		MOVEQ	R6, #1			; set stop reading flag

		STRB	R4, [R0], #1	; store char into dst even if overwriting null terminator or going out of bounds
		
		SUBS	R2, R2, #1		; subtract counter
		
		BNE		_strncpy_loop	; loop if counter not 0

_strncpy_done
		MOV		R0, R3			; change dest pointer back to the beginning
		POP		{R3-R6}			; restore registers
		MOV		PC, LR			; return
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _malloc( int size )
; Parameters
;	size	- #bytes to allocate
; Return value
;   	void*	a pointer to the allocated space
		EXPORT	_malloc
_malloc
		; save registers
		PUSH 	{R7, LR} ; push prev R7 and return address to main
			
		MOV		R7, #0x4	
		; set the system call # to R7
	    SVC     #0x4
		 
		; resume registers
		POP 	{R7, LR}	; back to main
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void _free( void* addr )
; Parameters
;	size	- the address of a space to deallocate
; Return value
;   	none
		EXPORT	_free
_free
		; save registers
		; set the system call # to R7
        	SVC     #0x0
		; resume registers
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; unsigned int _alarm( unsigned int seconds )
; Parameters
;   seconds - seconds when a SIGALRM signal should be delivered to the calling program	
; Return value
;   unsigned int - the number of seconds remaining until any previously scheduled alarm
;                  was due to be delivered, or zero if there was no previously schedul-
;                  ed alarm. 
		EXPORT	_alarm
_alarm
		; save registers
		PUSH	{R7, LR}
		
		MOV		R7, #0x1
		; set the system call # to R7
        SVC     #0x1
		
		; resume registers	
		POP		{R7, LR}
		MOV		pc, lr		
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; void* _signal( int signum, void *handler )
; Parameters
;   signum - a signal number (assumed to be 14 = SIGALRM)
;   handler - a pointer to a user-level signal handling function
; Return value
;   void*   - a pointer to the user-level signal handling function previously handled
;             (the same as the 2nd parameter in this project)
		EXPORT	_signal
_signal
		; save registers
		PUSH	{R7, LR}
		
		MOV		R7, #0x2
		; set the system call # to R7
        SVC     #0x2
		
		; resume registers
		POP		{R7, LR}
		MOV		pc, lr	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		END			
