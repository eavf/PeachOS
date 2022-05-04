ENTRY (_start)
OUTPUT_FORMAT(binary)       /*Bude nahraté do pamäte ako čistý binárny kód, takže nie je potrebné header files a pod.*/
SECTIONS
{
    . = 1M;     /*Kernel bude nahratý do pamete na adresu 0x1M (1000000)
                Sections will start at 1 M of memory                */
    .text : ALIGN(4096)     /*Definícia textovej sekcie*/
    {
        *(.text)
    }

    .rodata : ALIGN(4096)   /*Definícia read only dátovej sekcie*/
    {
        *(.rodata)
    }

    .data : ALIGN(4096)     /*Definícia dátovej sekcie*/
    {
        *(.data)
    }

    .bss : ALIGN(4096)      /*BSS sekcia - sekcia s konštantnými premennými, ktoré neboli zatiaľ zadefinované*/
    {
        *(COMMON)
        *(.bss)
    }

    /*riešenie problemov s alignement c kódu a asembléru*/
    /*načítanie asm kódu zvlášť a na záver, aby sa neposúvali a nemiešali c funkcie s asemblerom => problémy so zarovnaním*/
    .asm : ALIGN(4096)      /*nastavujeme aj ked to nemá na asm vplyv....*/
    {
        *(.asm)
    }
}









/*Tento linker script zabezpečí, že náš obj file bude nahratý od pamäte 1 M*/