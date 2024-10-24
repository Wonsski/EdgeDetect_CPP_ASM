; AsmLib.asm
.686
.model flat, stdcall
option casemap :none

public ProcessImage

.code

ProcessImage PROC
    ; Parametry b�d� przekazywane na stosie
    ; image: DWORD, result: DWORD, width: DWORD, height: DWORD
    push ebp
    mov ebp, esp           ; Ustawienie ramki stosu
    mov eax, [ebp + 8]     ; Za�aduj wska�nik do obrazu (image)
    mov ebx, [ebp + 12]    ; Za�aduj wska�nik do wyniku (result)
    mov ecx, [ebp + 16]    ; Za�aduj szeroko�� (width)
    mov edx, [ebp + 20]    ; Za�aduj wysoko�� (height)

    xor edi, edi           ; Zmienna do iteracji przez wysoko�� (y)
outer_loop:
    cmp edi, edx           ; Sprawd�, czy osi�gni�to wysoko��
    jge end_process        ; Je�li tak, zako�cz proces

    xor ebp, ebp           ; Zmienna do iteracji przez szeroko�� (x)
inner_loop:
    cmp ebp, ecx           ; Sprawd�, czy osi�gni�to szeroko��
    jge next_row           ; Je�li tak, przejd� do nast�pnego wiersza

    ; Oblicz index piksela
    ; imagePointer = image + (y * width + x)
    mov esi, edi           ; Ustaw ESI na aktualny wiersz (y)
    imul esi, ecx          ; ESI = y * width
    add esi, ebp           ; ESI = y * width + x

    ; Skopiuj warto�� piksela
    mov al, [eax + esi]    ; Za�aduj piksel (R=G=B dla grayscale)
    mov [ebx + esi], al    ; Zapisz do tablicy wynikowej

    inc ebp                ; Zwi�ksz zmienn� wewn�trzn� (x)
    jmp inner_loop         ; Kontynuuj wewn�trzn� p�tl�

next_row:
    inc edi                ; Zwi�ksz zmienn� zewn�trzn� (y)
    jmp outer_loop         ; Kontynuuj zewn�trzn� p�tl�

end_process:
    pop ebp
    ret
ProcessImage ENDP

end
