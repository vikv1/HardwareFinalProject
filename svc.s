		AREA	|.text|, CODE, READONLY, ALIGN=2
		THUMB


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table
SYSTEMCALLTBL	EQU		0x20007B00 ; originally 0x20007500
SYS_EXIT		EQU		0x0		; address 20007B00
SYS_ALARM		EQU		0x1		; address 20007B04
SYS_SIGNAL		EQU		0x2		; address 20007B08
;SYS_MEMCPY		EQU		0x3		; address 20007B0C
SYS_MALLOC		EQU		0x4		; address 20007B10
SYS_FREE		EQU		0x5		; address 20007B14

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Initialization
		EXPORT	_syscall_table_init
_syscall_table_init
	;; Implement by yourself
		IMPORT	_kfree
		IMPORT	_kalloc
		IMPORT	_signal_handler
		IMPORT	_timer_start
	
		MOV		pc, lr

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; System Call Table Jump Routine
        EXPORT	_syscall_table_jump
_syscall_table_jump
		PUSH	{LR} ; link to startup svc handler

		;; Implement by yourself
		CMP		R7, #SYS_ALARM
		BLEQ		_timer_start
		
		CMP		R7, #SYS_SIGNAL
		BLEQ		_signal_handler
		
		CMP		R7, #SYS_MALLOC
		BLEQ		_kalloc
		
		CMP		R7, #SYS_FREE
		BLEQ		_kfree
		
		POP		{LR}
		MOV		pc, lr		; return to svc handler	
		
		END


		
