; AsmLib.asm
.686
.model flat, stdcall
option casemap :none

public ProcessImage

.code

ProcessImage PROC
    ; Parametry bêd¹ przekazywane na stosie
    ; image: DWORD, result: DWORD, width: DWORD, height: DWORD
    push ebp
    mov ebp, esp           ; Ustawienie ramki stosu
    mov eax, [ebp + 8]     ; Za³aduj wskaŸnik do obrazu (image)
    mov ebx, [ebp + 12]    ; Za³aduj wskaŸnik do wyniku (result)
    mov ecx, [ebp + 16]    ; Za³aduj szerokoœæ (width)
    mov edx, [ebp + 20]    ; Za³aduj wysokoœæ (height)

    xor edi, edi           ; Zmienna do iteracji przez wysokoœæ (y)
outer_loop:
    cmp edi, edx           ; SprawdŸ, czy osi¹gniêto wysokoœæ
    jge end_process        ; Jeœli tak, zakoñcz proces

    xor ebp, ebp           ; Zmienna do iteracji przez szerokoœæ (x)
inner_loop:
    cmp ebp, ecx           ; SprawdŸ, czy osi¹gniêto szerokoœæ
    jge next_row           ; Jeœli tak, przejdŸ do nastêpnego wiersza

    ; Oblicz index piksela
    ; imagePointer = image + (y * width + x)
    mov esi, edi           ; Ustaw ESI na aktualny wiersz (y)
    imul esi, ecx          ; ESI = y * width
    add esi, ebp           ; ESI = y * width + x

    ; Skopiuj wartoœæ piksela
    mov al, [eax + esi]    ; Za³aduj piksel (R=G=B dla grayscale)
    mov [ebx + esi], al    ; Zapisz do tablicy wynikowej

    inc ebp                ; Zwiêksz zmienn¹ wewnêtrzn¹ (x)
    jmp inner_loop         ; Kontynuuj wewnêtrzn¹ pêtlê

next_row:
    inc edi                ; Zwiêksz zmienn¹ zewnêtrzn¹ (y)
    jmp outer_loop         ; Kontynuuj zewnêtrzn¹ pêtlê

end_process:
    pop ebp
    ret
ProcessImage ENDP

end
