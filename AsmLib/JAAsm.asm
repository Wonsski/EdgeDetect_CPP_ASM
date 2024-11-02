.data
    ; Zdefiniowanie kolorów do przeliczania skali szaroœci
    red_coeff   REAL4 0.299
    green_coeff REAL4 0.587
    blue_coeff  REAL4 0.114

.code
; Parametry wejœciowe:
; - rcx: wskaŸnik na dane bitmapy
; - rdx: szerokoœæ obrazu
; - r8 : wysokoœæ obrazu
; - r9 : odstêp miêdzy wierszami (stride)
toGrayscale proc
    push rsi              ; Zachowanie rejestrów u¿ywanych w funkcji
    push rbx

    mov rsi, rcx          ; rsi = wskaŸnik na dane bitmapy

    xor rcx, rcx          ; rcx = y (licznik wierszy)
y_loop:
    cmp rcx, r8           ; jeœli y >= wysokoœæ, zakoñcz pêtlê
    jge end_y_loop

    xor rbx, rbx          ; rbx = x (licznik kolumn)
x_loop:
    cmp rbx, rdx          ; jeœli x >= szerokoœæ, zakoñcz pêtlê
    jge end_x_loop

    ; Obliczenie indeksu piksela: pixelIndex = y * stride + x * 3 (3 bajty na piksel)
    mov rax, rcx
    imul rax, r9          ; rax = y * stride
    add rax, rbx          ; rax = pixelIndex = y * stride + x
    imul rax, 3           ; przelicz piksel na indeks w tablicy (3 bajty na piksel)

    ; Pobieranie wartoœci kana³ów RGB
    movzx eax, byte ptr [rsi + rax]      ; za³aduj wartoœæ kana³u czerwonego do eax
    cvtsi2ss xmm0, eax                   ; konwersja int do float
    mulss xmm0, dword ptr [red_coeff]    ; czerwony * wspó³czynnik

    movzx eax, byte ptr [rsi + rax + 1]  ; za³aduj wartoœæ kana³u zielonego
    cvtsi2ss xmm1, eax
    mulss xmm1, dword ptr [green_coeff]  ; zielony * wspó³czynnik

    movzx eax, byte ptr [rsi + rax + 2]  ; za³aduj wartoœæ kana³u niebieskiego
    cvtsi2ss xmm2, eax
    mulss xmm2, dword ptr [blue_coeff]   ; niebieski * wspó³czynnik

    ; Oblicz sumê wartoœci (konwersja na skalê szaroœci)
    addss xmm0, xmm1                     ; czerwony + zielony
    addss xmm0, xmm2                     ; + niebieski

    ; Konwersja wartoœci na int i zapisanie wartoœci do bitmapy (wszystkie kana³y RGB = szaroœæ)
    cvttss2si eax, xmm0
    mov byte ptr [rsi + rax], al         ; zapisanie wartoœci szaroœci dla czerwonego
    mov byte ptr [rsi + rax + 1], al     ; zapisanie wartoœci szaroœci dla zielonego
    mov byte ptr [rsi + rax + 2], al     ; zapisanie wartoœci szaroœci dla niebieskiego

    ; Nastêpny piksel
    inc rbx
    jmp x_loop

end_x_loop:
    ; Nastêpny wiersz
    inc rcx
    jmp y_loop

end_y_loop:
    pop rbx
    pop rsi
    ret
toGrayscale endp

end