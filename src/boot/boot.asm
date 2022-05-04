;Zapracovaný workarround for BIOS Parameter Block - bootovanie z USB môže spôsobiť problémy
;Entering protected mode
;odseparovaný protected mode do samostatneho suboru kernel.asm

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
    jmp CODE_SEG:load32     ;   TU SA BUDE SKAKAT DO KERNEL.ASM


;GDT                general descriptor table
gdt_start: 

gdt_null:           ;  vytvoriť 64 bits 0 = null descriptor
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
load32:             ;   driver, ktory nacita kernel do pamete
    mov eax, 1                  ;   starting sector for load from
    mov ecx, 100                ;   total of sector to read
    mov edi, 0x0100000          ;   adekvatne 1M, adresa, na ktorú chhceme aby bol kernel načítaný
    call ata_lba_read           ;   načítaj sektory do pamäti
    jmp CODE_SEG:0x0100000      ;   po načítaní do pamete skoč na začiatok načítaného = adresa 0x100000 (v dec sústave je to cez milion)


ata_lba_read:               ;   toto je vlastne driver
    mov ebx, eax            ;   backup LBA   - iba ako prevencia
    ;   send the highest 8 bits of the lba to hard disk controler
    shr eax, 24             ;   32 - 24 = 8 - highest 8 bits
    or eax, 0xe0            ;   Select the master drive
    mov dx, 0x1F6
    out dx, al              ;   S out inštrukciou sa bavíme s bus matherboard
    ;   Finished sending highest 8 bits of the lba

    ;   Send total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ;   Finished sending the total sectors to reads

    ;   Send more bits of the LBA
    mov eax, ebx            ;   Restore the backup of LBA   - iba ako prevencia
    mov dx, 0x1F3
    out dx, al
    ;   Finished sending more bits of the LBA

    ;   Send few more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx            ;   Restore the backup of LBA   - iba ako prevencia
    shr eax, 8              ;   shift eax 8 bits to right
    out dx, al
    ;   Finished sending few more bits of the LBA

    ;   Send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx            ;   Restore the backup of LBA   - iba ako prevencia
    shr eax, 16             ;   shift eax 16 bits to right
    out dx, al
    ;   Finishing sending upper 16 bits of the LBA

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ;   read all sectors into memory
.next_sector:
    push ecx

;   checking if we need to read
.try_again:
    mov dx, 0x1f7
    in al, dx               ;   čítame do al z adresy 0x1f7
    test al, 8              ;   testujeme al register, či je bit nastavený
    jz .try_again

;   we need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw                ;   insw číta zo sektora 1 slovo z i/o portu špecifikovaného v DX na pamäťovú pozíciu definovanú v ES
    ;   rep hovorí aby čítal 256 slov = 512 bytes = 1 sektor
    pop ecx
    loop .next_sector       ;   zníži sa požadovaný počet nahrávaných dát = dekrementuje ecx
    ;   end of reading sectors into memory
    ret                     ;   návrat zo subrutiny

times 510-($ - $$) db 0
dw 0xAA55   ;   nie je to 55AA lebo intel je little endian
