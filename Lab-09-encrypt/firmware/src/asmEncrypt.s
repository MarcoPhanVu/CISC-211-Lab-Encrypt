/*** asmEncrypt.s   ***/

#include <xc.h>

/* Declare the following to be in data memory */
.data  

/* create a string */
.global nameStr
.type nameStr,%gnu_unique_object
	
/*** STUDENTS: Change the next line to your name!  **/
nameStr: .asciz "Ben Phan"  
.align
 
/* initialize a global variable that C can access to print the nameStr */
.global nameStrPtr
.type nameStrPtr,%gnu_unique_object
nameStrPtr: .word nameStr   /* Assign the mem loc of nameStr to nameStrPtr */

/* Define the globals so that the C code can access them */
/* (in this lab we return the pointer, so strictly speaking, */
/* does not really need to be defined as global) */
/* .global cipherText */
.type cipherText,%gnu_unique_object

.align
 
/* NOTE: THIS .equ MUST MATCH THE #DEFINE IN main.c !!!!!
 * TODO: create a .h file that handles both C and assembly syntax for this definition */
.equ CIPHER_TEXT_LEN, 200
 
/* space allocated for cipherText: 200 bytes, prefilled with 0x2A */
cipherText: .space CIPHER_TEXT_LEN,0x2A  

.align
 
.global cipherTextPtr
.type cipherTextPtr,%gnu_unique_object
cipherTextPtr: .word cipherText

/* Tell the assembler that what follows is in instruction memory     */
.text
.align

/* Tell the assembler to allow both 16b and 32b extended Thumb instructions */
.syntax unified

	
/********************************************************************
function name: asmEncrypt
function description:
	pointerToCipherText = asmEncrypt ( ptrToInputText , key )
	
where:
	input:
	ptrToInputText: location of first character in null-terminated
				 input string. Per calling convention, passed in via r0.
	key:            shift value (K). Range 0-25. Passed in via r1.
	
	output:
	pointerToCipherText: mem location (address) of first character of
					 encrypted text. Returned in r0
	
	function description: asmEncrypt reads each character of an input
					  string, uses a shifted alphabet to encrypt it,
					  and stores the new character value in memory
					  location beginning at "cipherText". After copying
					  a character to cipherText, a pointer is incremented 
					  so that the next letter is stored in the bext byte.
					  Only encrypt characters in the range [a-zA-Z].
					  Any other characters should just be copied as-is
					  without modifications
					  Stop processing the input string when a NULL (0)
					  byte is reached. Make sure to add the NULL at the
					  end of the cipherText string.
	
	notes:
	   The return value will always be the mem location defined by
	   the label "cipherText".
	
	
********************************************************************/    
.global asmEncrypt
.type asmEncrypt,%function
asmEncrypt:   

	/* save the caller's registers, as required by the ARM calling convention */
	push {r4-r11,LR}
	
	/* YOUR asmEncrypt CODE BELOW THIS LINE! VVVVVVVVVVVVVVVVVVVVV  */
	/* Keep base + key for safety*/
	LDR   R2, =cipherText
	MOV   R3, R1
	
	encryptLoop:
		LDRB	R4, [R0], 1	/*Auto-index, post-increament*/

		CMP		R4, 0
		BEQ		finshed		/* == 0 => null -> stop looping */

		CMP		R4, 'A'
		BLT		notUpper	/* < 65 */
		CMP		R4, 'Z'
		BGT		notUpper

		/* Encrypt uppercase (char − 'A'(65) + key) % 26 + 'A' */
		/* Had to subtract self's value since they won't be 0-26 to mod normally */
		SUB		R5, R4, 'A'
		ADD 	R5, R5, R3	/* + key */
		CMP		R5, 25
		BLE		upperInRange	/* B if Less than or Equal */
		SUB 	R5, R5, 26

	upperInRange:
		/* convert back to char */
		ADD		R4, R5, 'A'
		STRB	R4, [R2], 1 	/* post-inc, auto-indx */
		B		encryptLoop		/* Loop */

	notUpper: /* lower-case */
		CMP 	R4, 'a'
		BLT		copyNonLetter
		CMP		R4, 'z'
		BGT		copyNonLetter

		/* Encrypt lower-case, same with above */
		SUB 	R5, R4, 'a'
		ADD 	R5, R5, R3
		CMP		R5, 25
		BLE		lowerInRange
		SUB 	R5, R5, 26

	lowerInRange:
		ADD		R4, R5, 'a'
		STRB	R4, [R2], 1
		B		encryptLoop

	copyNonLetter:
		STRB 	R4, [R2], 1
		B	encryptLoop

	finshed:
		MOV		R4, 0
		STRB	R4, [R2]	/* stop incrementing */

		/*return pointer to cipherText in R0 as required */
		LDR		R0, =cipherText


	/* YOUR asmEncrypt CODE ABOVE THIS LINE! ^^^^^^^^^^^^^^^^^^^^^  */

	/* restore the caller's registers, as required by the ARM calling convention */
	pop {r4-r11,LR}

	mov pc, lr	 /* asmEncrypt return to caller */
   

/**********************************************************************/   
.end  /* The assembler will not process anything after this directive!!! */
		 




