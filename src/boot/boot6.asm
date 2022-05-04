;Zapracovaný workarround for BIOS Parameter Block - bootovanie z USB môže spôsobiť problémy
;Entering protected mode

ORG 0x7c00           ;   
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start


_start:
    jmp short start
    nop

times 33 db 0   ;   vytvorí priestor potrebný pre BPB hneď za short jmp 33 bytov a keď BIOS začne tieto veci plniť, tak neprepíše náš kód
start:
    jmp 0:step2

step2:
    cli         ;   clear interupts - zároveň ich zakáže
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00      ;   stack pointer - začiatok vykonávania inštrukcií na adrese, kde začína boot record
    sti         ;   enable interupts

load_protected:
    cli                     ;   clear interupts
    lgdt [gdt_descriptor]   ;   load gdt descriptor pamäť od návestia gdt_start po gdt_end -1
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32


;GDT                general descriptor table
gdt_start: 

gdt_null:           ;v  vytvoriť 64 bits 0 = null descriptor
    dd 0x0
    dd 0x0

;   offset 0x8
gdt_code:           ;   CS should point to this
    dw 0xffff       ;   Segment limit first 0-15 bits
    dw 0            ;   Base first 0 - 15 bits
    db 0            ;   Base 16 - 23 bits
    db 0x9a         ;   Access byte
    db 11001111b    ;   High 4 bit flags and the low 4 bit flags
    db 0            ;   Base 24 - 31 bits

;   offset 0x10
gdt_data:           ;   DS, SS, ES, FS, GS
    dw 0xffff       ;   Segment limit first 0-15 bits
    dw 0            ;   Base first 0 - 15 bits
    db 0            ;   Base 16 - 23 bits
    db 0x92         ;   Access byte
    db 11001111b    ;   High 4 bit flags and the low 4 bit flags
    db 0            ;   Base 24 - 31 bits

gdt_end:


gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start


[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    jmp $


times 510-($ - $$) db 0
dw 0xAA55   ;   nie je to 55AA lebo intel je little endian
