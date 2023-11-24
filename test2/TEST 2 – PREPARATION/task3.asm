; @author ~ Marek Čupr (xcuprm01)

%include "rw32-2022.inc"

section .data

section .text

; V tasku 3 se opauji tyto typy uloh:
;           1) Lucasovy cisla
;           2) Fibonacciho posloupnost
;	    3) Padovany cisla

; K TOMUHLE MAM JEN RESENI Z MEHO TESTU, KDE JSEM ZISKAL 8/9 (nevim kde byla chyba unfortunately)
; VSECHNY TY ZADANI JSOU Z 80% STEJNY, JEN SE TAM MENI CISLA NASLEDOVNE:
;
;
; FIBONACCI
;  F(0) = 0
;  F(1) = 1
;  F(n) = F(n-1) + F(n-2)

; LUCAS
;  L(0) = 2
;  L(1) = 1
;  L(n) = L(n-1) + L(n-1)

; PADOVAN 
;   P(0) = 1
;   P(1) = 1
;   P(2) = 1
;   P(n) = P(n-2) + P(n-3)

CMAIN:
push ebp
mov ebp,esp

    CEXTERN malloc

    mov ecx, 9
    call task23

	pop ebp
	ret
	
	
	
	
; RESENI Z MEHO TESTU
	
;
;--- Task 3 ---
;
; Create a function 'task23' to allocate and fill an array of the 32bit unsigned elements by the elements
; of the Padovan sequence P(0), P(1), ... , P(N-1). Requested count of the elements of the Padovan sequence
; is in the register ECX (32bit signed integer) and the function returns a pointer to the array
; allocated using the 'malloc' function from the standard C library in the register EAX.
;
; Elements of the Padovan sequence are defined as follows:
;
;   P(0) = 1
;   P(1) = 1
;   P(2) = 1
;   P(n) = P(n-2) + P(n-3)
;
; Function parameters:
;   ECX = requested count of the elements of the Padovan sequence (32bit signed integer).
;
; Return values:
;   EAX = 0, if ECX <= 0, do not allocate any memory and return value 0 (NULL),
;   EAX = 0, if memory allocation by the 'malloc' function fails ('malloc' returns 0),
;   EAX = pointer to the array of N 32bit unsigned integer elements of the Padovan sequence.
;
; Important:
;   - the function MUST preserve content of all the registers except for the EAX and flags registers,
;   - the 'malloc' function may change the content of the ECX and EDX registers.
;
; The 'malloc' function is defined as follows:
;
;   void* malloc(size_t N)
;     N: count of bytes to be allocated (32bit unsigned integer),
;     - in the EAX register it returns the pointer to the allocated memory,
;     - in the EAX register it returns 0 (NULL) in case of a memory allocation error,
;     - the function may change the content of the ECX and EDX registers.
;

	
task23:
    ; vytvorim si zasobnikovy ramec
    push ebp
    mov ebp, esp

    ; zalohuji si puvodni hodnoty registru
    push ebx
    push ecx
    push edx

    ; validace argumentu
    cmp ecx, 0 ; overeni, jestli je N <= 0
    jle .invalid ; nealokujeme zadnou pamet, skaceme na .invalid

    ; zjistime pocet bajtu potrebnych k alokaci
    shl ecx, 2 ; chceme alokovat N*4 (32bitove pole) bajtu
    ; shl ecx, 2 ---> vynasobi pocet prvku Padovanovych cisel * 4  (ecx * 4)

    mov ebx, ecx ; v ebx mame pocet bajtu k alokovani
    shr ecx, 2 ; ecx vydelime zpetne 4 --> v ecx mame pocet prvku Padovanovych cisel

    push ecx ; malloc nam muze prepsat registry ecx a edx ---> zalohujeme si ecx (pocet prvku Padovanovych cisel)
    push ebx ; na stack pushneme argumenty pro funkci malloc (size_t N)

    ; volani funkce
    call malloc ; malloc ulozi ukazatel na alokovane pole do registru eax
    add esp, 4 ; k esp pricteme 4, abychom mohli popnout ecx (jelikoz puvodni hodnotu eax ze stacku jiz nepotrebujeme)

    ; overeni spravnosti mallocu
    cmp eax, 0 ; porovnani, jestli malloc nevratil NULL pointer
    je .invalid

    pop ecx ; pocet prvku Padovanovych cisel

    mov [eax], dword 1 ; P(0) = 1
    cmp ecx, 1
    je .end ; pocet prvku Padovanovych cisel je 1 (mame splneno, skaceme na konec)
    mov [eax + 4], dword 1
    cmp ecx, 2
    je .end ; pocet prvku Padovanovych cisel je 2 (mame splneno, skaceme na konec)
    mov [eax + 8], dword 1
    cmp ecx, 3
    je .end ; pocet prvku Padovanovych cisel je 3 (mame splneno, skaceme na konec)

    mov edx, 3 ; int i = 3
    .for_loop:
        ; P(n)
        mov ebx, [eax + edx * 4 - 8] ; P(n-2)
        add ebx, [eax + edx * 4 - 12] ; P(n-2) + P(n-3)
        mov [eax + edx * 4], ebx ; Vysledek P(n-2) + P(n-3) presuneme na spravnou pozici v poli
        inc edx ; i++
        cmp edx, ecx ; porovnani i a N
        jne .for_loop ; skocime na .for_loop, pokud je i < N (i != N)

    jmp .end ; skocime na .end (abychom si neprepsali eax na 0)

    .invalid:
        mov eax, 0 ; chyba v mallocu / N <= 0; do EAX davame 0

    .end:
    ; zpetne vytahnuti hodnot ze stacku (v opacnem poradi, nez pushujeme)
    pop edx
    pop ecx
    pop ebx

    pop ebp
    ret
