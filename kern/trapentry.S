/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C - use functions[index]
 */
#define TRAPHANDLER(name, num)\
	.data;\
	.long name;\
	.text;\
	name:\
	pushl $(num);\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)\
	.data;\
	.long name;\
	.text;\
	name:\
	pushl $0;\
	pushl $(num);\
	jmp _alltraps

// To get functions table use extern void* functions[]
.data
	.globl functions

// Add necessary trap handlers to functions
functions:
	TRAPHANDLER_NOEC(t0, T_DIVIDE)
	TRAPHANDLER_NOEC(t1, T_DEBUG)
    TRAPHANDLER_NOEC(t2, T_NMI)
    TRAPHANDLER_NOEC(t3, T_BRKPT)
    TRAPHANDLER_NOEC(t4, T_OFLOW)
    TRAPHANDLER_NOEC(t5, T_BOUND)
    TRAPHANDLER_NOEC(t6, T_ILLOP)
    TRAPHANDLER_NOEC(t7, T_DEVICE)
	TRAPHANDLER_NOEC(t8, T_DBLFLT)
    TRAPHANDLER(t10, T_TSS)
    TRAPHANDLER(t11, T_SEGNP)
    TRAPHANDLER(t12, T_STACK)
    TRAPHANDLER(t13, T_GPFLT)
    TRAPHANDLER(t14, T_PGFLT)
    TRAPHANDLER_NOEC(t16, T_FPERR)
	TRAPHANDLER_NOEC(t17, T_ALIGN)
	TRAPHANDLER_NOEC(t18, T_MCHK)
	TRAPHANDLER_NOEC(t19, T_SIMDERR)
	TRAPHANDLER_NOEC(t48, T_SYSCALL)

_alltraps:
	// Build TrapFrame
    pushl %ds
    pushl %es
    pushal
	// Load GD_KD intp %ds and %es
    movl $GD_KD, %eax
    movw %ax, %ds
    movw %ax, %es
	// Pass pointer to TrapFrame as argument
    pushl %esp
	// Call trap
    call trap
