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
    imul r11, rdx
    imul r11, 4              ; r11 = r10 * stride (przesuniêcie o rozmiar pe³nego wiersza z paddingiem)
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
    imul eax, 28                     ; Przemnó¿ kana³ B przez 28
    movzx ebx, byte ptr [r13+1]      ; Wczytaj kana³ G do ebx
    imul ebx, 151                    ; Przemnó¿ kana³ G przez 151
    add eax, ebx                     ; Dodaj wynik do eax
    movzx ebx, byte ptr [r13+2]      ; Wczytaj kana³ R do ebx
    imul ebx, 77                     ; Przemnó¿ kana³ R przez 77
    add eax, ebx                     ; Dodaj wynik do eax
    shr eax, 8                       ; Podziel przez 256, aby uzyskaæ koñcowy wynik w skali szaroœci

    mov byte ptr [r13], al           ; Wpisz szaroœæ do kana³u B
    mov byte ptr [r13+1], al         ; Wpisz szaroœæ do kana³u G
    mov byte ptr [r13+2], al         ; Wpisz szaroœæ do kana³u R
    mov byte ptr [r13+3], 255        ; Ustaw kana³ A jako 255 (pe³na nieprzezroczystoœæ)


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
    imul r11, rdx
    imul r11, 4             ; r11 = r10 * stride (przesuniêcie o rozmiar pe³nego wiersza z paddingiem)
    add r11, rcx             ; r11 = rcx + r11 (wskaŸnik do pierwszego piksela w danym wierszu)

    ; Inicjalizacja pêtli wewnêtrznej dla pikseli w danym wierszu
    xor r12, r12             ; r12 = 0 (licznik kolumn)

loop_cols:
    cmp r12, rdx             ; Czy r12 (licznik kolumn) >= width?
    jge end_row              ; Jeœli tak, koñczymy pêtlê wiersza

    ; Inicjalizacja maksymalnej wartoœci dla komponentów B, G, R
    mov rbx, 0               ; rax przechowuje maksymaln¹ wartoœæ (0)

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
    movzx rax, byte ptr [r15]        ; Za³aduj kana³ B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za³aduj kana³ G lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za³aduj kana³ R lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)



check_right:
    ; Sprawdzamy praw¹ granicê (r12 + 1 >= width?)
    mov r14, r12
    inc r14
    cmp r14, rdx
    je check_top

    mov r15, r13
    add r15, 4  ; WskaŸnik do piksela po prawej

    ; PRAWY PIXEL
    movzx rax, byte ptr [r15]        ; Za³aduj kana³ B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                    ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za³aduj kana³ G lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za³aduj kana³ R lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

check_top:
    ; Sprawdzamy górn¹ granicê (r10 - 1 < 0?)
    cmp r10, 0
    je check_bottom

    mov r15, r13
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx    ; WskaŸnik do piksela powy¿ej

    ; GORNY PIXEL
    movzx rax, byte ptr [r15]        ; Za³aduj kana³ B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za³aduj kana³ G lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za³aduj kana³ R lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

check_bottom:
    ; Sprawdzamy doln¹ granicê (r10 + 1 >= height?)
    mov r14, r10
    inc r14
    cmp r14, r8
    je check_left_top

    mov r15, r13
    add r15, rdx
    add r15, rdx
    add r15, rdx
    add r15, rdx    ; WskaŸnik do piksela poni¿ej

    ; DOLNY PIXEL
    movzx rax, byte ptr [r15]        ; Za³aduj kana³ B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za³aduj kana³ G lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za³aduj kana³ R lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

check_left_top:
    ; Sprawdzamy lewy górny róg (r10 - 1 < 0 || r12 - 1 < 0?)
    cmp r10, 0
    je check_right_top
    cmp r12, 0
    je check_right_top

    mov r15, r13
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx
    sub r15, 4   ; WskaŸnik do piksela w lewym górnym rogu

    ; LEWY GORNY PIXEL
    movzx rax, byte ptr [r15]        ; Za³aduj kana³ B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za³aduj kana³ G lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za³aduj kana³ R lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

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
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx
    add r15, 4   ; WskaŸnik do piksela w prawym górnym rogu

    ; PRAWY GORNY PIXEL
    movzx rax, byte ptr [r15]        ; Za³aduj kana³ B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za³aduj kana³ G lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za³aduj kana³ R lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)
    

check_left_bottom:
    ; Sprawdzamy lewy dolny róg (r10 + 1 >= height? || r12 - 1 < 0?)
    mov r14, r10
    inc r14
    cmp r14, r8
    jge check_right_bottom
    cmp r12, 0
    jl check_right_bottom

    mov r15, r13
    add r15, rdx
    add r15, rdx
    add r15, rdx
    add r15, rdx
    sub r15, 4   ; WskaŸnik do piksela w lewym dolnym rogu

    ; LEWY DOLNY PIXEL
    movzx rax, byte ptr [r15]        ; Za³aduj kana³ B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za³aduj kana³ G lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za³aduj kana³ R lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

check_right_bottom:
    ; Sprawdzamy prawy dolny róg (r10 + 1 >= height? || r12 + 1 >= width?)
    mov r14, r10
    inc r14
    cmp r14, r8
    jge save_max_value
    mov r14, r12
    inc r14
    cmp r14, rdx
    jge save_max_value

    ; WskaŸnik do piksela w prawym dolnym rogu (r13 + stride + 4) - nadpisujemy r15
    mov r15, r13
    add r15, rdx
    add r15, rdx
    add r15, rdx
    add r15, rdx
    add r15, 4   ; WskaŸnik do piksela w prawym dolnym rogu

    ; PRAWY DOLNY PIXEL
    movzx rax, byte ptr [r15]        ; Za³aduj kana³ B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za³aduj kana³ G lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za³aduj kana³ R lewego piksela do rax
    cmp rax, rbx                     ; Porównaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Jeœli rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

save_max_value:

    sub r13, rcx
    add r13, [rsp+40]

    mov byte ptr [r13], al           ; Ustaw wartoœæ kana³u B na wartoœæ szaroœci
    mov byte ptr [r13+1], al         ; Ustaw wartoœæ kana³u G na wartoœæ szaroœci
    mov byte ptr [r13+2], al         ; Ustaw wartoœæ kana³u R na wartoœæ szaroœci

    mov byte ptr [r13+3], 255        ; Kana³ A (nieprzezroczysty)

    inc r12
    jmp loop_cols

end_row:
    ; Przejœcie do kolejnego wiersza
    inc r10
    jmp loop_rows

end_color:
    ret
DilateImageAsm ENDP


CombineImages PROC

    ; RCX: dilatedImageData
    ; RDX: width
    ; R8:  height
    ; R9:  grayscaleImageData (wynik operacji zostanie zapisany tutaj)

    xor r10, r10             ; r10 = 0 (licznik wierszy)

loop_rows:
    cmp r10, r8              ; Czy r10 (licznik wierszy) >= height?
    jge end_color            ; Jeœli tak, koñczymy pêtlê

    ; Obliczanie wskaŸnika do pierwszego piksela w danym wierszu
    mov r11, r10             ; r11 = r10 (licznik wierszy)
    imul r11, rdx
    imul r11, 4              ; r11 = r10 * stride (przesuniêcie o rozmiar pe³nego wiersza z paddingiem)

    lea r12, [rcx + r11]     ; r12 = wskaŸnik do wiersza w dilatedImageData
    lea r13, [r9 + r11]      ; r13 = wskaŸnik do wiersza w grayscaleImageData (gdzie zapiszemy wynik)

    ; Inicjalizacja pêtli wewnêtrznej dla pikseli w danym wierszu
    xor r14, r14             ; r14 = 0 (licznik kolumn)

loop_cols:
    cmp r14, rdx             ; Czy r14 (licznik kolumn) >= width?
    jge end_row              ; Jeœli tak, koñczymy pêtlê wiersza

    ; Obliczanie wskaŸnika do bie¿¹cego piksela
    mov r15, r14             ; r15 = r14 (licznik kolumn)
    imul r15, 4              ; r15 = r15 * 4 (rozmiar piksela)

    lea rsi, [r12 + r15]     ; rsi = wskaŸnik do bie¿¹cego piksela w dilatedImageData
    lea rdi, [r13 + r15]     ; rdi = wskaŸnik do bie¿¹cego piksela w grayscaleImageData (gdzie zapiszemy wynik)

    ; Kana³ B
    movzx eax, byte ptr [rsi]    ; Wczytaj kana³ B z dilatedImageData do eax
    movzx ebx, byte ptr [rdi]    ; Wczytaj kana³ B z grayscaleImageData do ebx
    cmp eax, ebx                 ; Porównaj wartoœci
    jbe zero_pixel_b             ; Jeœli dilatedData <= grayscaleData, ustaw 0
    sub eax, ebx                 ; Odejmij wartoœci
    mov byte ptr [rdi], al       ; Zapisz wynik do kana³u B w grayscaleImageData
    jmp next_channel_b

zero_pixel_b:
    mov byte ptr [rdi], 0        ; Zapisz 0 do kana³u B w grayscaleImageData

next_channel_b:

    ; Kana³ G
    movzx eax, byte ptr [rsi+1]  ; Wczytaj kana³ G z dilatedImageData do eax
    movzx ebx, byte ptr [rdi+1]  ; Wczytaj kana³ G z grayscaleImageData do ebx
    cmp eax, ebx                 ; Porównaj wartoœci
    jbe zero_pixel_g             ; Jeœli dilatedData <= grayscaleData, ustaw 0
    sub eax, ebx                 ; Odejmij wartoœci
    mov byte ptr [rdi+1], al     ; Zapisz wynik do kana³u G w grayscaleImageData
    jmp next_channel_g

zero_pixel_g:
    mov byte ptr [rdi+1], 0      ; Zapisz 0 do kana³u G w grayscaleImageData

next_channel_g:

    ; Kana³ R
    movzx eax, byte ptr [rsi+2]  ; Wczytaj kana³ R z dilatedImageData do eax
    movzx ebx, byte ptr [rdi+2]  ; Wczytaj kana³ R z grayscaleImageData do ebx
    cmp eax, ebx                 ; Porównaj wartoœci
    jbe zero_pixel_r             ; Jeœli dilatedData <= grayscaleData, ustaw 0
    sub eax, ebx                 ; Odejmij wartoœci
    mov byte ptr [rdi+2], al     ; Zapisz wynik do kana³u R w grayscaleImageData
    jmp next_channel_r

zero_pixel_r:
    mov byte ptr [rdi+2], 0      ; Zapisz 0 do kana³u R w grayscaleImageData

next_channel_r:

    ; Kana³ A (pozostaje bez zmian, ustawiony na 255)
    ;mov byte ptr [rdi+3], 255    ; Kana³ A (nieprzezroczysty)

    inc r14                  ; Zwiêksz licznik kolumn
    jmp loop_cols            ; PrzejdŸ do kolejnej kolumny

end_row:
    inc r10                  ; Zwiêksz licznik wierszy
    jmp loop_rows            ; PrzejdŸ do kolejnego wiersza

end_color:
    ret
CombineImages ENDP



end
