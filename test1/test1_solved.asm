; @author ~ Marek Čupr (xcuprm01)
; @body   ~ 6/6

%include "rw32-2022.inc"

section .data
    ; krajní hodnoty pro test funkcionality

    a db -128            ; byte (8 bitů)
    b dd -2_147_483_648  ; double-word (32 bitů) 
    c dw -32_768         ; word (16 bitů)
    d dw -32_768         ; word (16 bitů)
    e dw -32_768         ; word (16 bitů)

    q dd 0               ; double-word (32 bitů) --> na ulozeni vysledku deleni
    r dd 0               ; double-word (32 bitů) --> na ulozeni zbytku deleni

section .text

CMAIN:
    push ebp
    mov ebp,esp


;--- Task 1 ---
;
; Create a function `task11` to swap bytes X1, X2, X3, X4 within the register EAX this way:
;
; original value: EAX = X4 X3 X2 X1
; result        : EAX = X2 X4 X1 X3
;
; The argument to the function is passed in the register EAX and it returns the result
; in the register EAX. The least significant byte is X1, the most significant byte is X4.
;
; Arguments:
;    - EAX = 32bit value
;
; Result:
;    - EAX = result
;    - the function does not have to preserve content of any register
;


    mov eax, 0x44332211  ; nahrani hodnoty pro testovani (na ISU HUB nepsat!)

; RESENI TASKU 1

    ; ORIGINÁLNÍ HODNOTA = X4 X3 X2 X1 (kazde 'Xn' predstavuje 8 bitu ~ 32bitu / 4 hodnoty X)
    rol eax, 8 ; EAX = X3 X2 X1 X4 (posun o 8 bitu v celem EAX (o jedno X) doleva)
    ror ax, 8 ; EAX = X3 X2 X4 X1 (posun o 8 bitu pouze v AX (v poslednich dvou X))
    rol eax, 8 ; EAX = X2 X4 X1 X3 (posun o 8 bitu v celem EAX (o jedno X) doleva)


;--- Task 2a ---
;
; Create a function `task12` to evaluate the following expression using SIGNED integer arithmetic:
;
; q = (a*b + c - 39)/(6*d + e - 1151) ... division quotient
; r = (a*b + c - 39)%(6*d + e - 1151) ... division remainder
;
; The arguments a, b, c, d and e are stored in the memory and are defined as follows:
;
;    [a] ...  8bit signed integer
;    [b] ... 32bit signed integer
;    [c] ... 16bit signed integer
;    [d] ... 16bit signed integer
;    [e] ... 16bit signed integer
;
; Store the result to the memory at the addresses q and r this way:
;
;    [q] ... low 32 bits of the division quotient (32bit signed integer)
;    [r] ... division remainder (32bit signed integer)
;
; Important notes:
;  - do NOT take into account division by zero
;  - the function does not have to preserve the original content of the registers


; RESENI TASKU 2

    ; q = (a*b + c - 39)/(6*d + e - 1151) ... division quotient
    ; r = (a*b + c - 39)%(6*d + e - 1151) ... division remainder

    ; (a*b + c - 39) ---> PRVNE DELAM TUTO ZAVORKU

    ; (a*b)
    movsx eax, byte [a]
    mov ecx, [b]
    imul ecx ; vysledek ulozen do --> EDX:EAX

    ; presun EDX:EAX ----> EBX:ESI (kvuli pozdejsimu preteceni)
    mov esi, eax ; docasne ulozeni EAX do ESI
    mov ebx, edx ; docasne ulozeni EDX do EBX

    ; (c - 39)
    movsx eax, word [c]
    sub eax, 39

    ; znamenkove rozsireni EAX na 64 bitu 
    cdq ; EAX ----> EDX:EAX

    ; scitani (a*b) + (c - 39) oddeleno kvuli preteceni
    add esi, eax ; pokud toto pretece, tak se nastavy carry flag na 1
    adc ebx, edx ; k ebx prictu edx + carry (bud 0 nebo 1) 

    ; VYSLEDEK PRVNI ZAVORKY MAM ULOZEN V EBX:ESI


    ; (6*d + e - 1151) ---> DRUHA ZAVORKA
    
    ; (6*d)
    movsx eax, word [d]
    mov ecx, 6
    imul ecx ; vysledek ulozen do ----> EDX:EAX (ale EDX je prazdne, jelikoz neumime delit 64bit cislo a tudiz nam fog neda hodnoty, ktere by pretekly)

    ; (e - 1151)
    movsx ecx, word [e]
    sub ecx, 1151

    add eax, ecx ; (6*d) + (e - 1151) 

    ; presun EAX do EDI kvuli deleni
    mov edi, eax

    ; presun EBX:ESI zpet do EDX:EAX kvuli deleni
    mov eax, esi
    mov edx, ebx

    idiv edi ; delim 32BIT hodnotu, takze se bere EDX:EAX / SRC (SRC = EDI v nasem pripade)

    mov [q], eax ; ULOZENI VYSLEDKU DO Q
    mov [r], edx ; ULOZENI ZBYTKU DO R



    ; BONUS PRIKLAD S 'UNSIGNED' HODNOTAMI

;--- Task 2b ---
;
; Create a function `task12` to evaluate the following expression using UNSIGNED integer arithmetic:
;
; q = (a*b + c + 24)/(9*d + e + 124) ... division quotient
; r = (a*b + c + 24)%(9*d + e + 124) ... division remainder
;
; The arguments a, b, c, d and e are stored in the memory and are defined as follows:
;
;    [a] ...  8bit unsigned integer
;    [b] ... 32bit unsigned integer
;    [c] ... 16bit unsigned integer
;    [d] ... 16bit unsigned integer
;    [e] ... 16bit unsigned integer
;
; Store the result to the memory at the addresses q and r this way:
;
;    [q] ... low 32 bits of the division quotient (32bit unsigned integer)
;    [r] ... division remainder (32bit unsigned integer)
;
; Important notes:
;  - do NOT take into account division by zero
;  - the function does not have to preserve the original content of the registers


; RESENI

    ; q = (a*b + c + 24)/(9*d + e + 124) ... division quotient
    ; r = (a*b + c + 24)%(9*d + e + 124) ... division remainder

    ; (9*d + e + 124) --> PRVNE DELAM DRUHOU ZAVORKU (nemusim nutne, pouze preference)

    ; (9*d)
    movzx eax, word [d]
    mov ebx, 9
    mul ebx ; ulozi se do EDX:EAX ----> v EDX ale nic nebude (16bit * 9bit se urcite vejde do 32bit)

    movzx ecx, word [e]
    add eax, ecx
    add eax, 124  ; neni potreba resit preteceni (nepretece tech 32bitu, jelikoz neumime delit 32bit hodnoty)

    mov esi, eax ; (9*d + e + 124) ---> Ulozim si EAX do ESI (dělitel)
 
    ; (a*b + c + 24) ----> PRVNI ZAVORKA

    ; (a*b)
    movzx eax, byte [a]
    mul dword [b] ; ulozi se do EDX:EAX ----> u vyssich hodnot tohle rozhodne pretece do EDX

    movzx ebx, word [c]
    add eax, ebx  ; pokud se nevejde do eax, tak se nastavi carry na 1
    adc edx, 0    ; pricteni carry do edx (bud 1 nebo 0)
    add eax, 24   ; pokud se nevejde do eax, tak se nastavi carry na 1
    adc edx, 0    ; pricteni carry do edx (bud 1 nebo 0)

    ; deleni
    div esi ; vydeli EDX:EAX / SRC (ESI) ---> vysledek se ulozi do eax, zbytek do edx

    mov [q], eax ; ULOZENI VYSLEDKU DO Q
    mov [r], edx ; ULOZENI ZBYTKU DO R

    pop ebp
    ret
