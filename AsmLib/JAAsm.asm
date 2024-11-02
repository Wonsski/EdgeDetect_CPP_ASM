.data
    ; Zdefiniowanie kolor�w do przeliczania skali szaro�ci
    red_coeff   REAL4 0.299
    green_coeff REAL4 0.587
    blue_coeff  REAL4 0.114

.code
; Parametry wej�ciowe:
; - rcx: wska�nik na dane bitmapy
; - rdx: szeroko�� obrazu
; - r8 : wysoko�� obrazu
; - r9 : odst�p mi�dzy wierszami (stride)
toGrayscale proc
    push rsi              ; Zachowanie rejestr�w u�ywanych w funkcji
    push rbx

    mov rsi, rcx          ; rsi = wska�nik na dane bitmapy

    xor rcx, rcx          ; rcx = y (licznik wierszy)
y_loop:
    cmp rcx, r8           ; je�li y >= wysoko��, zako�cz p�tl�
    jge end_y_loop

    xor rbx, rbx          ; rbx = x (licznik kolumn)
x_loop:
    cmp rbx, rdx          ; je�li x >= szeroko��, zako�cz p�tl�
    jge end_x_loop

    ; Obliczenie indeksu piksela: pixelIndex = y * stride + x * 3 (3 bajty na piksel)
    mov rax, rcx
    imul rax, r9          ; rax = y * stride
    add rax, rbx          ; rax = pixelIndex = y * stride + x
    imul rax, 3           ; przelicz piksel na indeks w tablicy (3 bajty na piksel)

    ; Pobieranie warto�ci kana��w RGB
    movzx eax, byte ptr [rsi + rax]      ; za�aduj warto�� kana�u czerwonego do eax
    cvtsi2ss xmm0, eax                   ; konwersja int do float
    mulss xmm0, dword ptr [red_coeff]    ; czerwony * wsp�czynnik

    movzx eax, byte ptr [rsi + rax + 1]  ; za�aduj warto�� kana�u zielonego
    cvtsi2ss xmm1, eax
    mulss xmm1, dword ptr [green_coeff]  ; zielony * wsp�czynnik

    movzx eax, byte ptr [rsi + rax + 2]  ; za�aduj warto�� kana�u niebieskiego
    cvtsi2ss xmm2, eax
    mulss xmm2, dword ptr [blue_coeff]   ; niebieski * wsp�czynnik

    ; Oblicz sum� warto�ci (konwersja na skal� szaro�ci)
    addss xmm0, xmm1                     ; czerwony + zielony
    addss xmm0, xmm2                     ; + niebieski

    ; Konwersja warto�ci na int i zapisanie warto�ci do bitmapy (wszystkie kana�y RGB = szaro��)
    cvttss2si eax, xmm0
    mov byte ptr [rsi + rax], al         ; zapisanie warto�ci szaro�ci dla czerwonego
    mov byte ptr [rsi + rax + 1], al     ; zapisanie warto�ci szaro�ci dla zielonego
    mov byte ptr [rsi + rax + 2], al     ; zapisanie warto�ci szaro�ci dla niebieskiego

    ; Nast�pny piksel
    inc rbx
    jmp x_loop

end_x_loop:
    ; Nast�pny wiersz
    inc rcx
    jmp y_loop

end_y_loop:
    pop rbx
    pop rsi
    ret
toGrayscale endp

end