; AsmLib.asm
; Implementacja funkcji koloruj¹cej ca³y obraz w asemblerze x64

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
    jge end_color            ; Jeœli tak, koñczymy pêtlê

    ; Obliczanie wskaŸnika do pierwszego piksela w danym wierszu
    mov r11, r10             ; r11 = r10 (licznik wierszy)
    imul r11, r9             ; r11 = r10 * stride (przesuniêcie o rozmiar pe³nego wiersza z paddingiem)
    add r11, rcx             ; r11 = rcx + r11 (wskaŸnik do pierwszego piksela w danym wierszu)

    ; Inicjalizacja pêtli wewnêtrznej dla pikseli w danym wierszu
    xor r12, r12             ; r12 = 0 (licznik kolumn)

loop_cols:
    cmp r12, rdx             ; Czy r12 (licznik kolumn) >= width?
    jge end_row              ; Jeœli tak, koñczymy pêtlê wiersza

    ; Obliczanie wskaŸnika do pikseli w danej kolumnie w bie¿¹cym wierszu
    mov r13, r12             ; r13 = r12 (licznik kolumn)
    imul r13, r13, 4         ; r13 = r13 * 4 (rozmiar piksela)
    add r13, r11             ; r13 = r11 + r13 (wskaŸnik do bie¿¹cego piksela)

    movzx eax, byte ptr [r13]        ; Wczytaj kana³ B do eax
    imul eax, 29                     ; Przemnó¿ kana³ B przez 29
    movzx ebx, byte ptr [r13+1]      ; Wczytaj kana³ G do ebx
    imul ebx, 150                    ; Przemnó¿ kana³ G przez 150
    add eax, ebx                     ; Dodaj wynik do eax
    movzx ebx, byte ptr [r13+2]      ; Wczytaj kana³ R do ebx
    imul ebx, 77                     ; Przemnó¿ kana³ R przez 77
    add eax, ebx                     ; Dodaj wynik do eax
    shr eax, 8                       ; Podziel przez 256, aby uzyskaæ koñcowy wynik w skali szaroœci

   ; Zapisz wynik w skali szaroœci do wszystkich kana³ów koloru (B, G, R) - efekt szaroœci
    mov byte ptr [r13], al           ; Ustaw wartoœæ kana³u B na wartoœæ szaroœci
    mov byte ptr [r13+1], al         ; Ustaw wartoœæ kana³u G na wartoœæ szaroœci
    mov byte ptr [r13+2], al         ; Ustaw wartoœæ kana³u R na wartoœæ szaroœci

    mov byte ptr [r13+3], 255        ; Kana³ A (nieprzezroczysty)

    inc r12                  ; Zwiêksz licznik kolumn
    jmp loop_cols            ; PrzejdŸ do kolejnej kolumny

end_row:
    inc r10                  ; Zwiêksz licznik wierszy
    jmp loop_rows            ; PrzejdŸ do kolejnego wiersza

end_color:
    ret
ProcessImageAsm ENDP


DilateImageAsm PROC
    ; Arguments:
    ; rcx - pointer to the first pixel (unsigned char)
    ; rdx - width of the image (int, 32-bit)
    ; r8  - height of the image (int, 32-bit)
    ; r9  - stride of the image (number of bytes per row, including padding)

    xor r10, r10             ; r10 = 0 (licznik wierszy)

loop_rows:
    cmp r10, r8              ; Czy r10 (licznik wierszy) >= height?
    jge end_color            ; Jeœli tak, koñczymy pêtlê

    ; Obliczanie wskaŸnika do pierwszego piksela w danym wierszu
    mov r11, r10             ; r11 = r10 (licznik wierszy)
    imul r11, r9             ; r11 = r10 * stride (przesuniêcie o rozmiar pe³nego wiersza z paddingiem)
    add r11, rcx             ; r11 = rcx + r11 (wskaŸnik do pierwszego piksela w danym wierszu)

    ; Inicjalizacja pêtli wewnêtrznej dla pikseli w danym wierszu
    xor r12, r12             ; r12 = 0 (licznik kolumn)

loop_cols:
    cmp r12, rdx             ; Czy r12 (licznik kolumn) >= width?
    jge end_row              ; Jeœli tak, koñczymy pêtlê wiersza

    ; Obliczanie wskaŸnika do pikseli w danej kolumnie w bie¿¹cym wierszu
    mov r13, r12             ; r13 = r12 (licznik kolumn)
    imul r13, r13, 4         ; r13 = r13 * 4 (rozmiar piksela)
    add r13, r11             ; r13 = r11 + r13 (wskaŸnik do bie¿¹cego piksela)

    ; Sprawdzanie granic i obliczanie wskaŸników s¹siednich pikseli

    ; Sprawdzamy, czy bie¿¹cy piksel znajduje siê w obrêbie obrazu
    ; Jeœli nie, to przechodzimy do nastêpnego piksela (pomijamy obliczenia dla s¹siadów)

    ; Sprawdzanie lewej granicy (r12 - 1 < 0?)
    cmp r12, 0
    je check_right

    mov r15, r13
    sub r15, 4  ; WskaŸnik do piksela po lewej

    ; LEWY PIXEL

check_right:
    ; Sprawdzamy praw¹ granicê (r12 + 1 >= width?)
    mov r14, r12
    inc r14
    cmp r14, rdx
    je check_top

    mov r15, r13
    add r15, 4  ; WskaŸnik do piksela po prawej

    ; PRAWY PIXEL

check_top:
    ; Sprawdzamy górn¹ granicê (r10 - 1 < 0?)
    cmp r10, 0
    je check_bottom

    mov r15, r13
    sub r15, r9  ; WskaŸnik do piksela powy¿ej

    ; GORNY PIXEL

check_bottom:
    ; Sprawdzamy doln¹ granicê (r10 + 1 >= height?)
    mov r14, r10
    inc r14
    cmp r14, r8
    je check_left_top

    mov r15, r13
    add r15, r9  ; WskaŸnik do piksela poni¿ej

    ; DOLNY PIXEL

check_left_top:
    ; Sprawdzamy lewy górny róg (r10 - 1 < 0 || r12 - 1 < 0?)
    cmp r10, 0
    je check_right_top
    cmp r12, 0
    je check_right_top

    mov r15, r13
    sub r15, r9
    sub r15, 4   ; WskaŸnik do piksela w lewym górnym rogu

    ; LEWY GORNY PIXEL

check_right_top:
    ; Sprawdzamy prawy górny róg (r10 - 1 < 0 || r12 + 1 >= width?)
    cmp r10, 0
    je check_left_bottom
    mov r14, r12
    inc r14
    cmp r14, rdx
    je check_left_bottom

    ; WskaŸnik do piksela w prawym górnym rogu (r13 - stride + 4) - nadpisujemy r15
    mov r15, r13
    sub r15, r9
    add r15, 4   ; WskaŸnik do piksela w prawym górnym rogu

    ; PRAWY GORNY PIXEL
    

check_left_bottom:
    ; Sprawdzamy lewy dolny róg (r10 + 1 >= height? || r12 - 1 < 0?)
    mov r14, r10
    inc r14
    cmp r14, r8
    jge check_right_bottom
    cmp r12, 0
    jl check_right_bottom

    mov r15, r13
    add r15, r9
    sub r15, 4   ; WskaŸnik do piksela w lewym dolnym rogu

    ; LEWY DOLNY PIXEL

check_right_bottom:
    ; Sprawdzamy prawy dolny róg (r10 + 1 >= height? || r12 + 1 >= width?)
    mov r14, r10
    inc r14
    cmp r14, r8
    jge skip
    mov r14, r12
    inc r14
    cmp r14, rdx
    jge skip

    ; WskaŸnik do piksela w prawym dolnym rogu (r13 + stride + 4) - nadpisujemy r15
    mov r15, r13
    add r15, r9
    add r15, 4   ; WskaŸnik do piksela w prawym dolnym rogu

    ; PRAWY DOLNY PIXEL

skip:

    inc r12
    jmp loop_cols

end_row:
    ; Przejœcie do kolejnego wiersza
    inc r10
    jmp loop_rows

end_color:
    ret
DilateImageAsm ENDP





end
