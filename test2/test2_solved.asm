; @author ~ Marek Čupr (xcuprm01)
; @body   ~ 8/9

%include "rw32-2022.inc"

section .data
    ; TOHLE BYLO UZ V KOSTRE
    task21_A dw 53708,37865,52751,8876,13005,40487,36831,23465
    task21_B dw 54437,63750,33437,50629,13729,57224,57305,60686
    task22_A dw 36043,45896,26402,7801,22934,55456,42482,57412
    task22_B dw 32497,18963,9744,8083,18819,61103,18438,1111
    task23_A dd 3405259695,649070965,3298100571,4125634372,2724234821,2603132008,3972811087,1143418644

section .text
CMAIN:

    ; TOHLE JSEM VOLAL SAM
    CEXTERN malloc

    ; TOHLE BYLO UZ V KOSTRE
    push ebp
    mov ebp,esp

    mov eax,task21_A
    mov BX,127
    mov ecx,8
    call task21

    ; eax = task22(task22_A,8,146)

    ; CDECL -> zprava doleva (nejprve pushujeme posledni argument, nakonec prvni)
    ; store parameters according to the calling convention
    
    
    ; TOHLE JSEM PRIDAVAL DO KOSTRY (pushuje podle konvence CDECL --> viz. zadani)
    push 146 ; posledni argument
    push 8 ; druhy argument
    push task22_A ; prvni argument

    ; TOHLE BYLO UZ V KOSTRE
    call task22

    ; TOHLE JSEM PRIDAVAL DO KOSTRY
    add esp, 12 ; uklizeni argumentu podle konvecne CDECL (pushnuli jsme 3 argumenty, tudiz ret 3*4)

    ; TOHLE BYLO UZ V KOSTRE
    mov ecx,9
    call task23

    pop ebp
    ret
;
;--- Task 1 ---
;
; Create a function 'task21' to find if there is a value in an array of the 16bit unsigned values.
; Pointer to the array is in the register EAX, the value to be found is in the register BX
; and the count of the elements of the array is in the register ECX.
;
; Function parameters:
;   EAX = pointer to the array of the 16bit unsigned values (EAX is always a valid pointer)
;   BX = 16bit unsigned value to be found
;   ECX = count of the elements of the array (ECX is an unsigned 32bit value, always greater than 0)
;
; Return values:
;   EAX = 1, if the value has been found in the array, otherwise EAX = 0
;
; Important:
;   - the function does not have to preserve content of any register
;

task21:
    ; vychazim z:
    ; for (int i = N; i > 0; i--)
    ;   if (BX == EAX[i - 1]) EAX = 1;

    .for_loop:
        cmp bx, [eax + ecx * 2 - 2] ; indexujeme od konce (od N - 1), porovnavame hledane x s prvkem na indexu 'ecx - 1'
        je .found ; nasli jsme shodu s x, skocime na .found
        loop .for_loop ; ecx-- a skok na .for_loop, pokud se ecx != 0

    mov eax, 0 ; prosli jsme cely cyklus a nenasli jsme shodu, do eax ukladame 0
    jmp .end ; skocime na .end (abychom si v .found neprepsali eax na 1)
        
    .found:
        mov eax, 1 ; nasli jsme shodu, do eax ukladame 1

    .end:
    ret


;
;--- Task 2 ---
;
; Create a function: int task22(const unsigned short *pA, int N, unsigned short x) to search an array pA of N 16bit unsigned
; values for the first occurrence of the value x. The function returns position of the value in the array.
; The parameters are passed, the stack is cleaned and the result is returned according to the CDECL calling convention.
;
; Function parameters:
;   pA: pointer to the array A to search in
;    N: length of the array A
;    x: value to be searched for
;
; Return values:
;   EAX = -1 if the pointer pA is invalid (pA == 0) or N <= 0 or the value x has not been found in the array
;   EAX = position of the value x in the array (the array elements are indexed from 0)
;
; Important:
;   - the function MUST preserve content of all the registers except for the EAX and flags registers.
;

task22:
    ; vytvorim si zasobnikovy ramec
    push ebp
    mov ebp, esp

    ; zalohuji si puvodni hodnoty registru
    push ebx
    push ecx
    push edx

    ; zpracovani argumentu
    ; CDECL predava arugmenty zprava doleva (prvni argument je nejblize ebp)
    mov ebx, [ebp + 8]  ; pA
    mov ecx, [ebp + 12] ; N
    mov dx, [ebp + 16]  ; x

    ; validace argumentu
    cmp ebx, 0 ; overeni, jestli je pA NULL pointer
    je .invalid
    cmp ecx, 0 ; overeni, jestli je N <= 0
    jle .invalid

    ; vychazim z:
    ; for (int i = 0; i < N; i++)
    ; {
    ;   if (DX == EBX[i])
    ;   { 
    ;       EAX = i; 
    ;       return
    ;   }
    ; }

    ; hledame prvni vyskyt v poli (indexujeme od nuly)
    mov eax, 0 ; int i = 0

    .for_loop:
        cmp dx, [ebx + eax * 2] ; indexujeme od zacatku, porovnavame hledane x s prvkem na indexu 'eax' 
        je .found ; nasli jsme prvni vyskyt, skocime na .found
        inc eax ; i++
        cmp eax, ecx ; porovnani i a N
        jne .for_loop ; skocime na .for_loop, kdyz i < N (i != N)

    jmp .invalid ; prosli jsme cely cyklus a shodu jsme nenasli (skaceme na .invalid)

    .found:
        ; mame vratit index, na kterem jsme nasli prvni shodu (ten v eax jiz mame nahrany)
        jmp .end ; skocime na konec (abychom si neprepsali eax v .invalid)

    .invalid:
        mov eax, -1 ; argumenty nejsou validni / nenasli jsme shodu

    .end:
    
    ; zpetne vytahnuti hodnot ze stacku (v opacnem poradi, nez pushujeme)
    pop edx
    pop ecx
    pop ebx

    pop ebp
    ret ; parametry se u CDECL uklizi v mainu


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
