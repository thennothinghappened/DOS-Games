; --------------------------------------------------------------------------------------------
; # "DOS test"
; 
; Initially, this is a basic test program as I learn the very first steps!
; See https://crocidb.com/post/bootsector-game/ as the main source.
;
; ## Issues/Comments:
;
;   
; --------------------------------------------------------------------------------------------


; Position program will run from in memory.
; DOS allocates before 0x100 as "Program Segment Prefix" (https://forum.osdev.org/viewtopic.php?f=1&t=2600)
; The BIOS expects bootloader code to be at 0x7c00 when we write bootloader code.
[org 0x0100]

start:
    mov ax, 0x0002              ; Set 80-25 text mode
    int 0x10

    jmp .exit

    mov ax, 0xb800              ; Segment for the video data
    mov es, ax
    cld

    .exit:
        int 0x20
