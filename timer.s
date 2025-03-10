		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Timer Definition
STCTRL		EQU		0xE000E010		; SysTick Control and Status Register
STRELOAD	EQU		0xE000E014		; SysTick Reload Value Register
STCURRENT	EQU		0xE000E018		; SysTick Current Value Register
	
STCTRL_STOP	EQU		0x00000004		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 0, Bit 0 (ENABLE) = 0
STCTRL_GO	EQU		0x00000007		; Bit 2 (CLK_SRC) = 1, Bit 1 (INT_EN) = 1, Bit 0 (ENABLE) = 1
STRELOAD_MX	EQU		0x00FFFFFF		; MAX Value = 1/16MHz * 16M = 1 second
STCURR_CLR	EQU		0x00000000		; Clear STCURRENT and STCTRL.COUNT	
SIGALRM		EQU		14			; sig alarm

; System Variables
SECOND_LEFT	EQU		0x20007B80		; Secounds left for alarm( )
USR_HANDLER EQU		0x20007B84		; Address of a user-given signal handler function	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer initialization
; void timer_init( )
		EXPORT		_timer_init
_timer_init
		;; Implement by yourself
		PUSH 	{R1-R2}
		
		LDR		R2, =STCTRL		; load SYST_CSR register
		LDR		R1, [R2]		; load current value
		
		ORR		R1, R1, #0x7	; set last 3 bits to 111 (7)
		EOR		R1, R1, #0x3	; set last 2 bits to 0	(111 xor 011 = 100)
		
		STR		R1, [R2]		; store reset value into SYST_CSR
		
		LDR		R1, =STRELOAD_MX	; store max SYST_RVR value into R1
		LDR		R2, =STRELOAD		; get address for SYST_RVR
		STR		R1, [R2]			; store max val
		
		POP		{R1-R2}		; restore registers
		MOV		pc, lr		; return to Reset_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer start
; int timer_start( int seconds )
		EXPORT		_timer_start
_timer_start
		;; Implement by yourself
		PUSH	{R1-R3}
		
		LDR		R1, =SECOND_LEFT
		LDR		R2, [R1]	; save previous value
		
		STR		R0, [R1]	; store new seconds
		
		LDR		R1, =0xE000E010	; SYST_CSR
		LDR		R3, [R1]		; value at SYST_CSR
		
		ORR		R3, R3, #0x7	; set last three bits to 111 (7)
		STR		R3, [R1]
		
		LDR		R1, =0xE000E018	; SYST_CVR
		LDR		R3, =STCURR_CLR
		STR		R3, [R1]		; clear SYST_CVR
		
		POP		{R1-R3}
		MOV		pc, lr		; return to SVC_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void timer_update( )
		EXPORT		_timer_update
_timer_update
		;; Implement by yourself
		PUSH	{R2-R3}
		LDR		R2, =SECOND_LEFT
		LDR		R3, [R2]
		
		SUB		R3, R3, #1
		STR		R3, [R2]		; store decremented value 
		CMP		R3, #0
		BEQ		_stop_timer
		BNE		_timer_update_done

_stop_timer
		LDR		R2, =STCTRL		; SYST_CSR
		LDR		R3, [R2]
		ORR		R3, R3, #0x7	; set last 3 bits to 111
		EOR		R3, R3, #0x3	; set last 2 bits to 00 
		STR		R3, [R2]		; set SYST_CSR
		
		PUSH	{LR}
		LDR		R2, =USR_HANDLER
		LDR		R3, [R2]
		BLX		R3
		POP		{LR}
			
		
_timer_update_done
		POP		{R2-R3}
		MOV		pc, lr			; return to SysTick_Handler		
		
		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Timer update
; void* signal_handler( int signum, void* handler )
	    EXPORT	_signal_handler
_signal_handler
		;; Implement by yourself
		PUSH	{R2-R3}
		LDR		R2, =USR_HANDLER
		MOV		R3, #0xE
		
		CMP		R0, #14
		ITT		EQ
		LDREQ	R0, [R2]	; get old value of r2
		STREQ	R1, [R2]	; store func into usr_handler
		
		POP		{R2-R3}
		
		MOV		pc, lr		; return to Reset_Handler
		
		END		
