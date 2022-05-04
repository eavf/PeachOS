#include "idt.h"
#include "config.h"
#include "memory/memory.h"

struct idt_desc idt_descriptors[PEACHOS_TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor[];

void idt_init ()
{
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limits = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = idt_descriptors;
}