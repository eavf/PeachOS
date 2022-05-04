ORG 0           ;   origin dáme do nuly, a nastavením všetkých segmentov zaručíme aby vždy štartoval boot proces na 0x7c00
BITS 16

jmp 0x7c0:start

start:
    cli         ;   clear interupts - zároveň ich zakáže
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00        ;   operácia so stack reg.
    mov ss, ax
    mov sp, 0x7c00      ;   stack pointer - začiatok vykonávania inštrukcií na adrese, kde začína boot record
    sti         ;   enable interupts

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
