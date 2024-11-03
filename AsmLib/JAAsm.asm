; AsmLib.asm
; Implementacja funkcji przetwarzania obrazu w asemblerze 32-bitowym


.code

; Funkcja przetwarzaj�ca obraz
ProcessImageAsm PROC
    push rbp              ; Zapisujemy bazowy wska�nik stosu
    mov rbp, rsp          ; Ustawiamy nowy wska�nik stosu
    sub rsp, 32           ; Rezerwujemy miejsce na stosie

    ; Tutaj mo�na wczyta� argumenty z rejestr�w:
    ; rdx - wska�nik do danych obrazu (Scan0)
    ; r8  - szeroko��
    ; r9  - wysoko��

    ; W tej wersji funkcji po prostu zwracamy przekazany wska�nik i parametry,
    ; aby upewni� si�, �e komunikacja dzia�a poprawnie.

    mov rax, rdx          ; Ustawiamy wynik w rax (adres danych bitmapy)
    
    ; Przywracamy oryginalny wska�nik stosu i powracamy
    mov rsp, rbp
    pop rbp
    ret
ProcessImageAsm ENDP

end
