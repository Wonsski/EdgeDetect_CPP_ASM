; AsmLib.asm
; Implementacja funkcji przetwarzania obrazu w asemblerze 32-bitowym


.code

; Funkcja przetwarzaj¹ca obraz
ProcessImageAsm PROC
    push rbp              ; Zapisujemy bazowy wskaŸnik stosu
    mov rbp, rsp          ; Ustawiamy nowy wskaŸnik stosu
    sub rsp, 32           ; Rezerwujemy miejsce na stosie

    ; Tutaj mo¿na wczytaæ argumenty z rejestrów:
    ; rdx - wskaŸnik do danych obrazu (Scan0)
    ; r8  - szerokoœæ
    ; r9  - wysokoœæ

    ; W tej wersji funkcji po prostu zwracamy przekazany wskaŸnik i parametry,
    ; aby upewniæ siê, ¿e komunikacja dzia³a poprawnie.

    mov rax, rdx          ; Ustawiamy wynik w rax (adres danych bitmapy)
    
    ; Przywracamy oryginalny wskaŸnik stosu i powracamy
    mov rsp, rbp
    pop rbp
    ret
ProcessImageAsm ENDP

end
