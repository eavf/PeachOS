;Zapracovaný workarround for BIOS Parameter Block - bootovanie z USB môže spôsobiť problémy
;operácie na disku
;musí byť kompilovaný cez make

ORG 0           ;   origin dáme do nuly, a nastavením všetkých segmentov zaručíme aby vždy štartoval boot proces na 0x7c00
BITS 16
_start:
    jmp short start
    nop

times 33 db 0   ;   vytvorí priestor potrebný pre BPB hneď za short jmp 33 bytov a keď BIOS začne tieto veci plniť, tak neprepíše náš kód
start:
    jmp 0x7c0:step2

step2:
    cli         ;   clear interupts - zároveň ich zakáže
    mov ax, 0x7c0
    mov ds, ax
    mov es, ax
    mov ax, 0x00        ;   operácia so stack reg.
    mov ss, ax
    mov sp, 0x7c00      ;   stack pointer - začiatok vykonávania inštrukcií na adrese, kde začína boot record
    sti         ;   enable interupts

    ;operácia s hdd
    mov ah, 2           ;   read sector command
    mov al, 1           ;   read 1 sector
    mov ch, 0           ;   cylinder number 0
    mov cl, 2           ;   read sector 2
    mov dh, 0           ;   head number 0
    mov bx, buffer
    int 0x13
    jc error

    mov si, buffer      ;   do si buffera presunie obsah nacitany na poziciu buffer
    call print          ;   a vytlaci
    jmp $

error:
    mov si, error_message
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

error_message: db 'Nepodarilo sa nacitat sektor', 0

times 510-($ - $$) db 0
dw 0xAA55   ;   nie je to 55AA lebo intel je little endian

buffer:     ;   na toto miesto v zivej pameti natiahne program nacitany sektor. Bude to na adrese 7c00 + 200 = 7e00
