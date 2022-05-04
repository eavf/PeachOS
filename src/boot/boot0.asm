ORG 0x7c00  ;   začiatok vykonávania inštrukcií na adrese, kde začína boot record
BITS 16

start: ;toto posiela charakter na terminal
    mov ah,0eh
    mov al, 'A' ; presun charakter A do registra al
    mov bx,0
    int 0x10       ;volame interupt bios

    jmp $


times 510-($ - $$) db 0
dw 0xAA55   ;   nie je to 55AA lebo intel je little endian
