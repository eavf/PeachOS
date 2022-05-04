;Zapracovaný workarround for BIOS Parameter Block - bootovanie z USB môže spôsobiť problémy
;ideme začať s interuptami


ORG 0           ;   origin dáme do nuly, a nastavením všetkých segmentov zaručíme aby vždy štartoval boot proces na 0x7c00
BITS 16
_start:
    jmp short start
    nop

times 33 db 0   ;   vytvorí priestor potrebný pre BPB hneď za short jmp 33 bytov a keď BIOS začne tieto veci plniť, tak neprepíše náš kód
start:
    jmp 0x7c0:step2


handle_zero:    ;   nahradený originál int 0, ktorý je volaný systémom, keď príde k deleniu nulou
    mov ah, 0eh
    mov al, 'A'
    mov bx, 0x00
    int 0x10
    iret

handle_one:
    mov ah, 0eh
    mov al, 'V'
    mov bx, 0x00
    int 0x10
    iret

step2:
    cli         ;   clear interupts - zároveň ich zakáže
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00        ;   operácia so stack reg.
    mov ss, ax
    mov sp, 0x7c00      ;   stack pointer - začiatok vykonávania inštrukcií na adrese, kde začína boot record
    sti         ;   enable interupts

    ;interupty...
    mov word[ss:0x00], handle_zero
    mov word[ss:0x02], 0x7c0

    mov ax, 0x00
    div ax              ;   Delenie nulou ax/ax. ax = 0x00

    mov word[ss:0x04], handle_one
    mov word[ss:0x06], 0x7c0

    int 1

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
    int 0x10    ;   volame interupt bios
    ret         ;   návrat zo subrutiny


message: db 'Hello World!', 0


times 510-($ - $$) db 0
dw 0xAA55   ;   nie je to 55AA lebo intel je little endian
