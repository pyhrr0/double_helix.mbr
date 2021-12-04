bits 16                             ;Generate code for real mode.
org 0x7c00                          ;Set location where program is expected to be loaded.

init_stage1:
    mov ax, 0x3                     ;Set VGA video mode to 'mode 3'.
    int 0x10                        ;BIOS interrupt call.

    push 0xb800                     ;Address of VGA text buffer.
    pop es                          ;Store in ES register.
    mov si, text                    ;Point Source Index to outer image offset.
    xor di, di                      ;Clear Destination Index.
    mov dx, lut                     ;Point DX register to lookup table.
    jmp process_blob

set_color:
    test al, 0x30                   ;If current character is 0x30 (aka '0')
    jne green
    mov ah, 0x6                     ;Set color to red.
    ret

    green:
    mov ah, 0xa                     ;Set color to green.
    ret

process_blob:
    lodsb                           ;Get byte from image (and store in al register).
    test al, al                     ;Evaluate if fetched_byte is 0x0.
    jz newline                      ;If so, jump to newline.

    movzx cx, al                    ;Copy byte to cx.
    shr al, 0x4                     ;Get first_nibble.
    and cl, 0xf                     ;Get second_nibble.
    test al, al                     ;Evaluate if first_nibble is 0x0.
    jz whitespace                   ;If so jump to whitespace.

    mov al, byte [edx+eax]          ;Store lut[first_nibble] into al.
    call set_color
    one:
    stosw                           ;Output character to VGA text buffer.

    mov al, byte [edx+ecx]          ;Store lut[second_nibble] into al.
    call set_color
    two:
    stosw                           ;Output character to VGA text buffer.

    xor ax, ax                      ;Clear ax register.
    jmp process_blob                ;Process next byte.


whitespace:
    add di, cx                      ;Move Destination Index forward by second_nibble (character val)
    add di, cx                      ;Move Destination Index forward by second_nibble (attribute val)
    jmp process_blob                ;Process next byte.

newline:
    add bx, 80*2                    ;current_position += $num_bytes_in_line.
    mov di, bx                      ;Set Destination Index to $current_position.
    cmp bx, 0x960                   ;Evalutate if all lines have been printed.
    jb process_blob                 ;If not, Process next byte.

finish:
    mov ah, 0x1                     ;Disable cursor
    mov ch, 0x3f                    ;^
    int 0x10                        ;BIOS interrupt call
    hlt

text:
    incbin "double_helix.bin"       ;Blob containing encoded image data.

lut:
    incbin "lookup_table.bin"       ;Lookup table

times 510-($-$$) db 0               ;Padding
dw 0xAA55                           ;BIOS signature
