; @author ~ Marek Čupr (xcuprm01)

%include "rw32-2022.inc"

section .data
    ; pole pro variantu 1
    task22A dd -2074456426,-701210901,-802797689,-1658204169,-1073467232,706416762,-1178549399,1430887681

    ; pole pro variantu 2
    task22B db 96,64,20,44,56,36,-12,-85

    ; pole pro variantu 3
    task22C dw 32025,17022,9261,-22282,32478,19709,-5575,6590

section .text

; V tasku 2 se opakuji tyto typy uloh (jen se meni velikosti a KONVENCE VOLANI!!):
;           1) V poli nalezt nejmensi/nejvetsi prvek
;           2) Nalezt prvni/posledni vyskyt hledaneho prvku v poli
;           3) Nalezt pocet prvku, ktere jsou vetsi/mensi nez hledany prvek


;
;--- Task 2 - Varianta 1 --- (nalezt nejvetsi prvek v poli)
;
; Create a function: int task22(const int *pA, int N) to find maximum in an array pA of N 32bit signed values.
; The parameters are passed, the stack is cleaned and the result is returned according to the CDECL convention.
;
; Function parameters:
;   pA: pointer to the array A
;    N: lenght of the array A
;
; Return values:
;   EAX = 0x80000000 if the pointer pA is invalid (pA == 0) or N <= 0
;   EAX = value of the 32bit signed maximum
;
; Important:
;   - the function MUST preserve content of all the registers except for the EAX and flags registers.
;

task22_varianta_1:
    ; na rozdil od tasku 1 je zde potreba vytvorit zasobnikovy ramec
    push ebp
    mov ebp, esp

    ; funkce musi zachovat obsahy registru, takze si ulozim jejich hodnoty na stack
    push ebx
    push ecx
    push edx

    ; CDECL pushuje zprava doleva, tudiz prvni argument v (const int *pA, int N) bude nejblize od ebp
    mov ebx, [ebp + 8] ; ebx = pA
    mov ecx, [ebp + 12] ; ecx = N
    
    mov eax, 0x80000000 ; defaultne nastavime eax na 0x80000000 (to mame vratit pri chybe)

    ; validace argumentu
    cmp ebx, 0 ; porovnam pA s NULL
    je .end    ; pokud je pA NULL pointer, tak skocim na konec a nemusim delat nic dal, jelikoz v EAX uz mame x80000000

    mov eax, [ebx + ecx * 4 - 4] ; do EAX nahrajeme posledni prvek, abychom meli s cim porovnavat
    dec ecx ; posledni prvek jsme jiz zpracovali, tudiz od ecx odecteme 1

    .for_loop:
        cmp [ebx + ecx * 4 - 4], eax ; porovname prvek na indexu ecx s eax
        jg .new_max ; pokud je vetsi, tak jsme nasli nove maximum; skocime na .new_max
        loop .for_loop ; ecx-- a skok na .for_loop, pokud ecx > 0

        jmp .end ; pokud jsme tady,tak jsme dosli na konec loopu, skocime na .end

        .new_max:
            mov eax, [ebx + ecx * 4 - 4] ; do EAX ulozime nove maximum
            loop .for_loop ; ecx-- a skok na .for_loop, pokud ecx > 0

    .end:

    ; ze stacku si vytahnu puvodni hodnoty registru (v opacnem poradi, nez jsem pushoval)
    pop edx
    pop ecx
    pop ebx

    pop ebp
    ret ; v konvenci CDECL se parametry uklizi v MAINU (ke kteremu nemame v testu pristup, takze neresime)

;
;--- Task 2 - Varianta 2 --- (nalezt posledni vyskyt v poli hledaneho x)
;
; Create a function: void* task22(const unsigned char *pA, int N, unsigned char x) to search an array pA of N 8bit unsigned
; values for the last occurrence of the value x. The function returns pointer to the value in the array.
; The parameters are passed, the stack is cleaned and the result is returned according to the PASCAL calling convention.
;
; Function parameters:
;   pA: pointer to the array A to search in
;    N: length of the array A
;    x: value to be searched for
;
; Return values:
;   EAX = 0 if the pointer pA is invalid (pA == 0) or N <= 0 or the value x has not been found in the array
;   EAX = pointer to the value x in the array (the array elements are indexed from 0)
;
; Important:
;   - the function MUST preserve content of all the registers except for the EAX and flags registers.
;


task22_varianta_2:

    ; u posledniho vyskytu se vyplati indexovat od konce, u prvniho vyskytu od zacatku

    ; na rozdil od tasku 1 je zde potreba vytvorit zasobnikovy ramec
    push ebp
    mov ebp, esp

    ; funkce musi zachovat obsahy registru, takze si ulozim jejich hodnoty na stack
    push ebx
    push ecx
    push edx
    
    ; PASCAL pushuje zleva doprava, tudiz prvni argument v (const unsigned char *pA, int N, unsigned char x) bude nejdale od ebp
    mov ebx, [ebp + 16] ; ebx = pA
    mov ecx, [ebp + 12] ; ecx = N
    mov dl, [ebp + 8]  ; dl = X 

    mov eax, 0 ; defaultne bude v eax 0

    ; validace argumentu
    cmp ecx, 0 ; porovnam N s 0
    jle .end   ; pokud je N <= 0, tak skocim na .end
    cmp ebx, 0 ; porovnam pA s NULL
    je .end    ; pokud je pA NULL pointer, tak skocim na .end

    .for_loop:
        cmp dl, byte [ebx + ecx  - 1] ; -1 (1 bajt), abychom neindexovali mimo pole (N - 1), nezapomenout na byte pred zavorkou!!
        je .match ; nasli jsme shodu, skocime na .match
        loop .for_loop ; ecx-- a skok na .for_loop, pokud ecx > 0

    ; pokud jsme nenasli shodu, tak se dostaneme sem; nulu uz v eax mame, takze skaceme na .end
    jmp .end

    .match:
        lea eax, [ebx + ecx - 1] ; nasli jsme shodu (chceme pointer na prvek, neboli adresu, kterou ziskame pomoci instrukce lea)
        ; kdyby chtel pouze index, tak bychom udelali ---> mov eax, ecx a potom dec eax

    .end:

    ; ze stacku si vytahnu puvodni hodnoty registru (v opacnem poradi, nez jsem pushoval)
    pop edx
    pop ecx
    pop ebx

    pop ebp
    ret 4*3 ; v konvenci PASCAL uklizime takhle, 4 - počet bajtu; 3 - počet parametru, ktere nam byly pushnuty na stack od FOGA


;
;--- Task 2 - Varianta 3 --- (nalezt pocet prvku v poli, ktere jsou vetsi nez x)
;
; Create a function: int task22(const unsigned char *pA, int N, unsigned char x) to count all occurrences of the values greater than x
; in an array pA of N 16bit unsigned values.
; The parameters are passed, the stack is cleaned and the result is returned according to the STDCALL calling convention.
;
; Function parameters:
;   pA: pointer to the array A
;    N: length of the array A
;    x: comparison value
;
; Return values:
;   EAX = -1 if the pointer pA is invalid (pA == 0) or N < 0
;   EAX = count of the elements of the array greater than x
;
; Important:
;   - the function MUST preserve content of all the registers except for the EAX and flags registers.
;

task22_varianta_3:
    ; zasobnikovy ramec
    push ebp
    mov ebp, esp

    ; funkce musi zachovat obsahy registru, takze si ulozim jejich hodnoty na stack
    push ebx
    push ecx
    push edx

    ; STDCALL pushuje zprava doleva, tudiz prvni argument v (const unsigned char *pA, int N, unsigned char x) bude nejblize ebp
    mov ebx, [ebp + 8] ; ebx = pA
    mov ecx, [ebp + 12] ; ecx = N
    mov dx, [ebp + 16]  ; dx = X 

    ; validace argumentu
    cmp ecx, 0 ; porovnam N s 0
    jl .invalid   ; pokud je N < 0, tak skocim na konec
    cmp ebx, 0 ; porovnam pA s NULL
    je .invalid    ; pokud je pA NULL pointer, tak skocim na konec

    mov eax, 0 ; zatim jsme nasli nula prvku, ktere jsou vetsi nez x

    .for_loop:
        cmp word [ebx + ecx * 2 - 2], dx ; porovname prvek na indexu ecx s dx; nezapomenout na word!!
        jg .greater ; pokud je vetsi, tak skocime na .greater
        loop .for_loop ; ecx-- a skok na .for_loop, pokud je ecx > 0

        jmp .end ; prosli jsme vsechny prvky pole, skaceme na .end (musime preskocit .invalid)

        .greater:
            inc eax ; zvetsime pocet prvku vetsich nez x o 1  
            loop .for_loop ; ecx-- a skok na .for_loop, pokud ecx > 0

    jmp .end ; prosli jsme vsechny prvky pole, skaceme na .end (musime preskocit .invalid)

    .invalid:
        mov eax, -1 ; argumenty nejsou validní, vracíme -1 

    .end:
    
    ; ze stacku si vytahnu puvodni hodnoty registru (v opacnem poradi, nez jsem pushoval)
    pop edx
    pop ecx
    pop ebx

    pop ebp
    ret 4*3 ; v konvenci STDCALL uklizime takhle, 4 - počet bajtu; 3 - počet parametru, ktere nam byly pushnuty na stack od FOGA

CMAIN:
	push ebp
	mov ebp,esp
	
    push 8
    push task22A
    call task22_varianta_1
    add esp, 8

    push task22B
    push 8
    push -85
    call task22_varianta_2

    push 32024
    push 8
    push task22C
    call task22_varianta_3

	pop ebp
	ret
