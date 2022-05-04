#include "kernel.h"

#include <stdint.h>
#include <stddef.h>

uint16_t* video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

uint16_t terminal_make_char (char c, char colour)
{
    //1. shift colour for 8 bits
    //2. OR with character in c
    return (colour << 8) | c;
}


void terminal_putchar (int x, int y, char c, char colour)
{
    video_mem[(y*VGA_WIDTH) + x] = terminal_make_char(c, colour);
}

void terminal_writechar (char c, char colour)
{
    if (c == '\n')
    {
        terminal_row += 1;
        terminal_col = 0;
        return;
    }

    terminal_putchar (terminal_col, terminal_row, c, colour);
    terminal_col += 1;
    if (terminal_col>=VGA_WIDTH)
    {
        terminal_col = 0;
        terminal_row += 1;
    }
}

void terminal_initialize ()
{
    video_mem = (uint16_t*)(0xB8000);
    terminal_row = 0;
    terminal_col = 0;
    for (int y = 0; y < VGA_HEIGHT; y++)
    {
        for (int x = 0; x < VGA_WIDTH; x++)
        {
            terminal_putchar(x, y, ' ', 0);
        }
    }
}

size_t strlen(const char* str)
{
    size_t len = 0;
    while (str[len])
    {
        len++;
    }

    return len;
}

void print(const char* str)
{
    size_t len = strlen(str);
    for (int i = 0; i < len; i++)
    {
        terminal_writechar(str[i], 15);
    }
}

void kernel_main() 
{
    terminal_initialize();
    /*terminal_writechar ('A', 15);
    terminal_writechar ('B', 15);*/
    print("Hello World \ntest");

    /*
    video_mem[0] = 0xC;
    video_mem[8] = 0x0641;      //0x41 = 65 dec = ASCII hodnota A doplnené o 03 = farba Keďže je to indian musí byť naopak : 0x0341
    // tot uloží 0x41 do prvého bytu a 0x03 do druhého, čo je to čo sme chceli
    video_mem[4] = terminal_make_char('G', 12);
    video_mem[6] = terminal_make_char((char)sizeof('G'), 14);
    video_mem[2] = 'C';
    video_mem[3] = 3;
    */
}