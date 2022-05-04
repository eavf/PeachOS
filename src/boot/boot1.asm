ORG 0x7c00  ;   začiatok vykonávania inštrukcií na adrese, kde začína boot record
BITS 16

start:
    mov si, message    ; presun adresu návestia message do registra si
    call print
    jmp $


print:
    mov bx,0
.loop:          ;   začiatok slučky
    lodsb       ;   toto číta po jednom znaku z registra si do registra al
    cmp al,0    ;   toto porovna ci al nie je 0
    je .done    ;   ak je 0 skoci na .done
    call print_char     ;   vytlačí znak v al registri
    jmp .loop   ;   koniec slučky
.done:
    ret


print_char: ;toto posiela charakter na terminal
    mov ah,0eh
    int 0x10    ;volame interupt bios
    ret         ;   návrat zo subrutiny


message: db 'Hello World!', 0


times 510-($ - $$) db 0
dw 0xAA55   ;   nie je to 55AA lebo intel je little endian
