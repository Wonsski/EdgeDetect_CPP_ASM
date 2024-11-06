; AsmLib.asm
; Implementacja funkcji koloruj�cej ca�y obraz w asemblerze x64

.code

ProcessImageAsm PROC
    ; Arguments:
    ; rcx - pointer to the first pixel (unsigned char)
    ; rdx - width of the image (int, 32-bit)
    ; r8  - height of the image (int, 32-bit)
    ; r9  - stride of the image (number of bytes per row, including padding)

    xor r10, r10             ; r10 = 0 (licznik wierszy)

loop_rows:
    cmp r10, r8              ; Czy r10 (licznik wierszy) >= height?
    jge end_color            ; Je�li tak, ko�czymy p�tl�

    ; Obliczanie wska�nika do pierwszego piksela w danym wierszu
    mov r11, r10             ; r11 = r10 (licznik wierszy)
    imul r11, r9             ; r11 = r10 * stride (przesuni�cie o rozmiar pe�nego wiersza z paddingiem)
    add r11, rcx             ; r11 = rcx + r11 (wska�nik do pierwszego piksela w danym wierszu)

    ; Inicjalizacja p�tli wewn�trznej dla pikseli w danym wierszu
    xor r12, r12             ; r12 = 0 (licznik kolumn)

loop_cols:
    cmp r12, rdx             ; Czy r12 (licznik kolumn) >= width?
    jge end_row              ; Je�li tak, ko�czymy p�tl� wiersza

    ; Obliczanie wska�nika do pikseli w danej kolumnie w bie��cym wierszu
    mov r13, r12             ; r13 = r12 (licznik kolumn)
    imul r13, r13, 4         ; r13 = r13 * 4 (rozmiar piksela)
    add r13, r11             ; r13 = r11 + r13 (wska�nik do bie��cego piksela)

    ; Zmiana warto�ci piksela (Ustawianie warto�ci 30, 60, 255, 255)
    mov byte ptr [r13], 30   ; Ustaw warto�� dla kana�u B
    mov byte ptr [r13+1], 60 ; Ustaw warto�� dla kana�u G
    mov byte ptr [r13+2], 255; Ustaw warto�� dla kana�u R
    mov byte ptr [r13+3], 255; Ustaw warto�� dla kana�u A (nieprzezroczysty)

    inc r12                  ; Zwi�ksz licznik kolumn
    jmp loop_cols            ; Przejd� do kolejnej kolumny

end_row:
    inc r10                  ; Zwi�ksz licznik wierszy
    jmp loop_rows            ; Przejd� do kolejnego wiersza

end_color:
    ret
ProcessImageAsm ENDP


end
