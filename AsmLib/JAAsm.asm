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
    imul r11, rdx
    imul r11, 4              ; r11 = r10 * stride (przesuni�cie o rozmiar pe�nego wiersza z paddingiem)
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

    movzx eax, byte ptr [r13]        ; Wczytaj kana� B do eax
    imul eax, 28                     ; Przemn� kana� B przez 28
    movzx ebx, byte ptr [r13+1]      ; Wczytaj kana� G do ebx
    imul ebx, 151                    ; Przemn� kana� G przez 151
    add eax, ebx                     ; Dodaj wynik do eax
    movzx ebx, byte ptr [r13+2]      ; Wczytaj kana� R do ebx
    imul ebx, 77                     ; Przemn� kana� R przez 77
    add eax, ebx                     ; Dodaj wynik do eax
    shr eax, 8                       ; Podziel przez 256, aby uzyska� ko�cowy wynik w skali szaro�ci

    mov byte ptr [r13], al           ; Wpisz szaro�� do kana�u B
    mov byte ptr [r13+1], al         ; Wpisz szaro�� do kana�u G
    mov byte ptr [r13+2], al         ; Wpisz szaro�� do kana�u R
    mov byte ptr [r13+3], 255        ; Ustaw kana� A jako 255 (pe�na nieprzezroczysto��)


    inc r12                  ; Zwi�ksz licznik kolumn
    jmp loop_cols            ; Przejd� do kolejnej kolumny

end_row:
    inc r10                  ; Zwi�ksz licznik wierszy
    jmp loop_rows            ; Przejd� do kolejnego wiersza

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
    jge end_color            ; Je�li tak, ko�czymy p�tl�

    ; Obliczanie wska�nika do pierwszego piksela w danym wierszu
    mov r11, r10             ; r11 = r10 (licznik wierszy)
    imul r11, rdx
    imul r11, 4             ; r11 = r10 * stride (przesuni�cie o rozmiar pe�nego wiersza z paddingiem)
    add r11, rcx             ; r11 = rcx + r11 (wska�nik do pierwszego piksela w danym wierszu)

    ; Inicjalizacja p�tli wewn�trznej dla pikseli w danym wierszu
    xor r12, r12             ; r12 = 0 (licznik kolumn)

loop_cols:
    cmp r12, rdx             ; Czy r12 (licznik kolumn) >= width?
    jge end_row              ; Je�li tak, ko�czymy p�tl� wiersza

    ; Inicjalizacja maksymalnej warto�ci dla komponent�w B, G, R
    mov rbx, 0               ; rax przechowuje maksymaln� warto�� (0)

    ; Obliczanie wska�nika do pikseli w danej kolumnie w bie��cym wierszu
    mov r13, r12             ; r13 = r12 (licznik kolumn)
    imul r13, r13, 4         ; r13 = r13 * 4 (rozmiar piksela)
    add r13, r11             ; r13 = r11 + r13 (wska�nik do bie��cego piksela)

    ; Sprawdzanie granic i obliczanie wska�nik�w s�siednich pikseli

    ; Sprawdzamy, czy bie��cy piksel znajduje si� w obr�bie obrazu
    ; Je�li nie, to przechodzimy do nast�pnego piksela (pomijamy obliczenia dla s�siad�w)

    ; Sprawdzanie lewej granicy (r12 - 1 < 0?)
    cmp r12, 0
    je check_right

    mov r15, r13
    sub r15, 4  ; Wska�nik do piksela po lewej

    ; LEWY PIXEL
    movzx rax, byte ptr [r15]        ; Za�aduj kana� B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za�aduj kana� G lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za�aduj kana� R lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)



check_right:
    ; Sprawdzamy praw� granic� (r12 + 1 >= width?)
    mov r14, r12
    inc r14
    cmp r14, rdx
    je check_top

    mov r15, r13
    add r15, 4  ; Wska�nik do piksela po prawej

    ; PRAWY PIXEL
    movzx rax, byte ptr [r15]        ; Za�aduj kana� B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                    ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za�aduj kana� G lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za�aduj kana� R lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

check_top:
    ; Sprawdzamy g�rn� granic� (r10 - 1 < 0?)
    cmp r10, 0
    je check_bottom

    mov r15, r13
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx    ; Wska�nik do piksela powy�ej

    ; GORNY PIXEL
    movzx rax, byte ptr [r15]        ; Za�aduj kana� B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za�aduj kana� G lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za�aduj kana� R lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

check_bottom:
    ; Sprawdzamy doln� granic� (r10 + 1 >= height?)
    mov r14, r10
    inc r14
    cmp r14, r8
    je check_left_top

    mov r15, r13
    add r15, rdx
    add r15, rdx
    add r15, rdx
    add r15, rdx    ; Wska�nik do piksela poni�ej

    ; DOLNY PIXEL
    movzx rax, byte ptr [r15]        ; Za�aduj kana� B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za�aduj kana� G lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za�aduj kana� R lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

check_left_top:
    ; Sprawdzamy lewy g�rny r�g (r10 - 1 < 0 || r12 - 1 < 0?)
    cmp r10, 0
    je check_right_top
    cmp r12, 0
    je check_right_top

    mov r15, r13
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx
    sub r15, 4   ; Wska�nik do piksela w lewym g�rnym rogu

    ; LEWY GORNY PIXEL
    movzx rax, byte ptr [r15]        ; Za�aduj kana� B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za�aduj kana� G lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za�aduj kana� R lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

check_right_top:
    ; Sprawdzamy prawy g�rny r�g (r10 - 1 < 0 || r12 + 1 >= width?)
    cmp r10, 0
    je check_left_bottom
    mov r14, r12
    inc r14
    cmp r14, rdx
    je check_left_bottom

    ; Wska�nik do piksela w prawym g�rnym rogu (r13 - stride + 4) - nadpisujemy r15
    mov r15, r13
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx
    sub r15, rdx
    add r15, 4   ; Wska�nik do piksela w prawym g�rnym rogu

    ; PRAWY GORNY PIXEL
    movzx rax, byte ptr [r15]        ; Za�aduj kana� B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za�aduj kana� G lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za�aduj kana� R lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)
    

check_left_bottom:
    ; Sprawdzamy lewy dolny r�g (r10 + 1 >= height? || r12 - 1 < 0?)
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
    sub r15, 4   ; Wska�nik do piksela w lewym dolnym rogu

    ; LEWY DOLNY PIXEL
    movzx rax, byte ptr [r15]        ; Za�aduj kana� B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za�aduj kana� G lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za�aduj kana� R lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

check_right_bottom:
    ; Sprawdzamy prawy dolny r�g (r10 + 1 >= height? || r12 + 1 >= width?)
    mov r14, r10
    inc r14
    cmp r14, r8
    jge save_max_value
    mov r14, r12
    inc r14
    cmp r14, rdx
    jge save_max_value

    ; Wska�nik do piksela w prawym dolnym rogu (r13 + stride + 4) - nadpisujemy r15
    mov r15, r13
    add r15, rdx
    add r15, rdx
    add r15, rdx
    add r15, rdx
    add r15, 4   ; Wska�nik do piksela w prawym dolnym rogu

    ; PRAWY DOLNY PIXEL
    movzx rax, byte ptr [r15]        ; Za�aduj kana� B lewego piksela do rax (rozszerzenie zero)
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                     ; Skopiuj rax do rbx
    movzx rax, byte ptr [r15+1]      ; Za�aduj kana� G lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    movzx rax, byte ptr [r15+2]      ; Za�aduj kana� R lewego piksela do rax
    cmp rax, rbx                     ; Por�wnaj z poprzednim maksimum (rx)
    cmovg rbx, rax                   ; Je�li rax > rbx, ustaw rbx = rax
    mov al, bl                       ; Skopiuj wynik do rejestru al (8-bitowy)

save_max_value:

    sub r13, rcx
    add r13, [rsp+40]

    mov byte ptr [r13], al           ; Ustaw warto�� kana�u B na warto�� szaro�ci
    mov byte ptr [r13+1], al         ; Ustaw warto�� kana�u G na warto�� szaro�ci
    mov byte ptr [r13+2], al         ; Ustaw warto�� kana�u R na warto�� szaro�ci

    mov byte ptr [r13+3], 255        ; Kana� A (nieprzezroczysty)

    inc r12
    jmp loop_cols

end_row:
    ; Przej�cie do kolejnego wiersza
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
    jge end_color            ; Je�li tak, ko�czymy p�tl�

    ; Obliczanie wska�nika do pierwszego piksela w danym wierszu
    mov r11, r10             ; r11 = r10 (licznik wierszy)
    imul r11, rdx
    imul r11, 4              ; r11 = r10 * stride (przesuni�cie o rozmiar pe�nego wiersza z paddingiem)

    lea r12, [rcx + r11]     ; r12 = wska�nik do wiersza w dilatedImageData
    lea r13, [r9 + r11]      ; r13 = wska�nik do wiersza w grayscaleImageData (gdzie zapiszemy wynik)

    ; Inicjalizacja p�tli wewn�trznej dla pikseli w danym wierszu
    xor r14, r14             ; r14 = 0 (licznik kolumn)

loop_cols:
    cmp r14, rdx             ; Czy r14 (licznik kolumn) >= width?
    jge end_row              ; Je�li tak, ko�czymy p�tl� wiersza

    ; Obliczanie wska�nika do bie��cego piksela
    mov r15, r14             ; r15 = r14 (licznik kolumn)
    imul r15, 4              ; r15 = r15 * 4 (rozmiar piksela)

    lea rsi, [r12 + r15]     ; rsi = wska�nik do bie��cego piksela w dilatedImageData
    lea rdi, [r13 + r15]     ; rdi = wska�nik do bie��cego piksela w grayscaleImageData (gdzie zapiszemy wynik)

    ; Kana� B
    movzx eax, byte ptr [rsi]    ; Wczytaj kana� B z dilatedImageData do eax
    movzx ebx, byte ptr [rdi]    ; Wczytaj kana� B z grayscaleImageData do ebx
    cmp eax, ebx                 ; Por�wnaj warto�ci
    jbe zero_pixel_b             ; Je�li dilatedData <= grayscaleData, ustaw 0
    sub eax, ebx                 ; Odejmij warto�ci
    mov byte ptr [rdi], al       ; Zapisz wynik do kana�u B w grayscaleImageData
    jmp next_channel_b

zero_pixel_b:
    mov byte ptr [rdi], 0        ; Zapisz 0 do kana�u B w grayscaleImageData

next_channel_b:

    ; Kana� G
    movzx eax, byte ptr [rsi+1]  ; Wczytaj kana� G z dilatedImageData do eax
    movzx ebx, byte ptr [rdi+1]  ; Wczytaj kana� G z grayscaleImageData do ebx
    cmp eax, ebx                 ; Por�wnaj warto�ci
    jbe zero_pixel_g             ; Je�li dilatedData <= grayscaleData, ustaw 0
    sub eax, ebx                 ; Odejmij warto�ci
    mov byte ptr [rdi+1], al     ; Zapisz wynik do kana�u G w grayscaleImageData
    jmp next_channel_g

zero_pixel_g:
    mov byte ptr [rdi+1], 0      ; Zapisz 0 do kana�u G w grayscaleImageData

next_channel_g:

    ; Kana� R
    movzx eax, byte ptr [rsi+2]  ; Wczytaj kana� R z dilatedImageData do eax
    movzx ebx, byte ptr [rdi+2]  ; Wczytaj kana� R z grayscaleImageData do ebx
    cmp eax, ebx                 ; Por�wnaj warto�ci
    jbe zero_pixel_r             ; Je�li dilatedData <= grayscaleData, ustaw 0
    sub eax, ebx                 ; Odejmij warto�ci
    mov byte ptr [rdi+2], al     ; Zapisz wynik do kana�u R w grayscaleImageData
    jmp next_channel_r

zero_pixel_r:
    mov byte ptr [rdi+2], 0      ; Zapisz 0 do kana�u R w grayscaleImageData

next_channel_r:

    ; Kana� A (pozostaje bez zmian, ustawiony na 255)
    ;mov byte ptr [rdi+3], 255    ; Kana� A (nieprzezroczysty)

    inc r14                  ; Zwi�ksz licznik kolumn
    jmp loop_cols            ; Przejd� do kolejnej kolumny

end_row:
    inc r10                  ; Zwi�ksz licznik wierszy
    jmp loop_rows            ; Przejd� do kolejnego wiersza

end_color:
    ret
CombineImages ENDP



end
