; @author ~ Marek Čupr (xcuprm01)

%include "rw32-2022.inc"

section .data
    ;pole pro variantu 1 (typ ulohy 1)
    task21A dw 18734,-28251,-10526,-9352,22250,9242,-2652,30871 ; 16 bitove pole
    
    ; pole pro variantu 2 (typ ulohy 2)
    task21B dd 1430887681,-701210901,-802797689,-1658204169,-1073467232,706416762,-1178549399,-2074456426 ; 32 bitove pole
    task21C dd 1430887681,-701210901,-802797689,-1658204169,-1073467232,706416762,-1178549399,-2074456426 ; 32 bitove pole

section .text

; V tasku 1 se opakuji 2 typy uloh, jen se meni velikosti registru atd... :
;           1) zjisti, jestli se v poli naleza konkretni hodnota
;           2) zjisti, jestli jsou 2 pole stejna
;           3) vzacne se tam asi jednou objevilo zkopirovat hodnoty z pole A do pole B

; OBCAS CHCE VRACET V EAX -1, JINDY 0, ATD.... ---> DOBRE CIST ZADANI!!

;
;--- Task 1 - VARIANTA 1 --- (zjisti, jestli je hledana hodnota v poli)
;
; Create a function 'task21' to find if there is a value in an array of the 16bit signed values.  
; Pointer to the array is in the register EAX, the value to be found is in the register BX 
; and the count of the elements of the array is in the register ECX.
;
; Function parameters:
;   EAX = pointer to the array of the 16bit signed values (EAX is always a valid pointer)
;   BX = 16bit signed value to be found
;   ECX = count of the elements of the array (ECX is an unsigned 32bit value, always greater than 0)
;
; Return values:
;   EAX = 1, if the value has been found in the array, otherwise EAX = 0
;
; Important:
;   - the function does not have to preserve content of any register


task21_varianta_1_index_od_konce: ; prochazeni pole od konce (rychlejsi zpusob)

    ; VYCHAZIM Z:
    ;
    ; for (int i = N; i > 0; i--)
    ;        if { EAX[i - 1] == BX } EAX = 1;

    .for_loop:
        cmp bx, word [eax + ecx * 2 - 2] ; - 2 na konci je tam proto, ze nejvyssi index je (N - 1); v nasem pripade -2 bajty dolu, abychom neindexovali mimo pole 
        je .match ; pokud se prvky rovnaji, tak skocime do .match
        loop .for_loop ; instrukce loop udela: ecx-- a pokracuje, dokud se ecx nerovna 0, potom se ten .for_loop ukonci

    mov eax, 0 ; pokud jsme tady, tak jsme prosli cely loop a shodu nenasli, do eax davame 0
    jmp .end ; musime preskocit .match, abysme si eax neprepsali na 1

    .match:
        mov eax, 1 ; nasli jsme shodu, do eax davame 1

    .end:

    ret
    


;
;--- Task 1 - VARIANTA 2 --- (porovnani 2 poli)
;
; Create a function 'task21' to compare elements of two arrays of the 32bit signed values.  
; Pointer to the first array is in the register EAX, pointer to the second array is in the register EBX, 
; and the count of the elements of both arrays is in the register ECX.
;
; Function parameters:
;   EAX = pointer to the first array of the 32bit signed values (EAX is always a valid pointer)
;   EBX = pointer to the second array of the 32bit signed values (EBX is always a valid pointer)
;   ECX = count of the elements of the arrays (ECX is an unsigned 32bit value, always greater than 0)
;
; Return values:
;   EAX = 1, if the arrays contain the same values, otherwise EAX = 0
;
; Important:
;   - the function does not have to preserve content of any register


task21_varianta_2_index_od_konce:

    ; VYCHAZIM Z:   
    ;
    ; for (int i = N; i > 0; i--) 
    ;         if { EAX[i - 1] != EBX[i - 1] } EAX = 0;
    

    .for_loop:
        ; nemuzeme udelat cmp [eax + edx * 4], [ebx + edx * 4] ----> musime si pomoct mezikrokem
        mov esi, [eax + ecx * 4 - 4] ; musime odecist 4 (32bit pole), abychom neindexovali mimo pole
        cmp [ebx + ecx * 4 - 4], esi ; porovna prvky na indexu edx v obou polich
        jne .mismatch ; nasli jsme neshodu, skocime na .mismatch
        loop .for_loop ; loopuju, pokud i < N

    mov eax, 1 ; pokud jsme tady, tak jsme prosli cely loop a pole se rovnaji, do eax davame 1
    jmp .end ; musime preskocit .mismatch, abysme si eax neprepsali na 0

    .mismatch:
        mov eax, 0 ; pole se nerovnaji

    .end:

    ret



CMAIN:
	push ebp
	mov ebp,esp
	

    ; VARIANTA 1
    mov eax, task21A
    mov ebx, 30871
    mov ecx, 8
    call task21_varianta_1_index_od_konce

    ; VARIANTA 2
    mov eax, task21B
    mov ebx, task21C
    mov ecx, 8
    call task21_varianta_2_index_od_konce

	pop ebp
	ret
