section .text:
	global murmurhash	;
murmurhash:
	mov ecx,edx	; Salt or variable "h"
			; rdi is current location in string. String processed in DWORDs.
	mov r13,rsi	; Process length of string
	and r13,3	; Modulo 4 = Length of remainder
	lea rbx,[rdi+rsi]; End of string
	sub rbx,r13	; Without remainder 

	mov r12d,0x00000005	; Variable "m" = 5
	mov r11d,0xe6546b64	; Variable "n"

	mov r10d,0xcc9e2d51	; Constant "c1"
	mov r9d ,0x1b873593	; Constant "c2"

	.loop1:
		mov eax,[rdi]	; Move 4 byte chunk at [r15] to eax. Also variable "k".
		mul r10d	; Multiply eax by c1 > edx,eax. We don't need edx.
		rol eax,15	; Rotate eax left by r1 (or 15)
		mul r9d		; Multiply eax by c2.

		xor eax,ecx	; Xor eax into hash, and move result into eax
		rol eax,13	; Rotate hash left by r3 (or 13)
		mul r12d	; Multiply eax by r12d
		lea ecx,[eax+r11d]	; Move eax back to ecx after adding r11d

		add rdi,4	; Increment where we are by 4
		cmp rdi,rbx	; Compare to the end of the dword array
		jl .loop1	;

	xor eax,eax	; Set eax to 0
	test r13b,r13b	; Switch statement: little-endianize remaining bytes
	jz .case0	;
	cmp r13b,1	;
	je .case1	;
	cmp r13b,2	;
	je .case2	;
		mov al,[rdi+2]	;
		shl eax,8	;
	.case2:
		mov al,[rdi+1]	;
		shl eax,8	;
	.case1:
		mov al,[rdi]	; After adding last byte, do murmurhash mixing.
		mul r10d	;
		rol eax,15	; Rotate eax left by r1 (or 15)
		mul r9d		;
		xor ecx,eax	; Xor eax into ecx
	.case0:
		xor ecx,esi	; Xor length into ecx

	mov eax,ecx	; Move ecx to eax
	shr ecx,16	; Shift ecx right by 16 bits
	xor eax,ecx	; Xor it back into eax

	mov ebx,0x85ebca6b;
	mul ebx 	;

	mov ecx,eax	; Move eax to ecx
	shr ecx,13	; Shift ecx right by 13
	xor eax,ecx	; Xor it back into eax

	mov ebx,0xc2b2ae35;
	mul ebx 	;

	mov ecx,eax	; Move eax to ecx
	shr ecx,16	; Shift ecx right by 16
	xor eax,ecx	; Xor it back into eax

	ret		; Return eax.
	