
%macro print_text 2
    mov ecx, %1
    mov edx, %2
    call print_proc
%endmacro

section .data
    title db 10, "CERTIFICATE OF REGISTRATION", 10
    title_len equ $ - title

    prompt db "Enter total number of units: "
    prompt_len equ $ - prompt

    units_msg db "Total Units: "
    units_msg_len equ $ - units_msg

    tuition_msg db "Tuition Fee: PHP "
    tuition_msg_len equ $ - tuition_msg

    misc_msg db "Miscellaneous Fee: PHP 10540.00", 10
    misc_msg_len equ $ - misc_msg

    id_msg db "ID Validation Fee: PHP 78.00", 10
    id_msg_len equ $ - id_msg

    lab_msg db "Computer Laboratory Fee: PHP 3914.00", 10
    lab_msg_len equ $ - lab_msg

    nstp_msg db "NSTP Fee: PHP 2534.00", 10
    nstp_msg_len equ $ - nstp_msg

    total_msg db "Total Assessment: PHP "
    total_msg_len equ $ - total_msg

    decimal db ".00", 10
    decimal_len equ $ - decimal

    tuition_rate dd 2058
    misc_fee dd 10540
    id_fee dd 78
    lab_fee dd 3914
    nstp_fee dd 2534

section .bss
    input_buffer resb 32
    number_buffer resb 12
    tuition_fee resd 1

section .text
    global _start

_start:
    print_text title, title_len

    print_text prompt, prompt_len
    call read_number
    mov esi, eax               

    print_text units_msg, units_msg_len
    mov eax, esi
    call print_number
    print_text decimal, 1

    mov eax, esi
    call compute_tuition
    mov [tuition_fee], eax

    ;display tuition
    print_text tuition_msg, tuition_msg_len
    mov eax, [tuition_fee]
    call print_number
    print_text decimal, decimal_len

    ;display other fees
    print_text misc_msg, misc_msg_len
    print_text id_msg, id_msg_len
    print_text lab_msg, lab_msg_len
    print_text nstp_msg, nstp_msg_len

    call compute_total
    push eax

    print_text total_msg, total_msg_len

    pop eax
    call print_number
    print_text decimal, decimal_len

    mov eax, 1
    xor ebx, ebx
    int 0x80

print_proc:
    push ebx

    mov eax, 4              ; sys_write
    mov ebx, 1              ; stdout
    int 0x80

    pop ebx
    ret

read_number:
    mov eax, 3              
    mov ebx, 0              
    mov ecx, input_buffer
    mov edx, 32
    int 0x80

    xor eax, eax
    xor ecx, ecx

convert_input:
    movzx edx, byte [input_buffer + ecx]

    cmp dl, 10
    je input_done

    cmp dl, '0'
    jb input_done

    cmp dl, '9'
    ja input_done

    sub edx, '0'
    imul eax, 10
    add eax, edx

    inc ecx
    jmp convert_input

input_done:
    ret

compute_tuition:
    imul eax, dword [tuition_rate]
    ret

compute_total:
    mov eax, [tuition_fee]
    add eax, [misc_fee]
    add eax, [id_fee]
    add eax, [lab_fee]
    add eax, [nstp_fee]
    ret

print_number:
    cmp eax, 0
    jne convert_number

    mov byte [number_buffer], '0'
    print_text number_buffer, 1
    ret

convert_number:
    mov edi, number_buffer + 12
    mov ebx, 10

number_loop:
    xor edx, edx
    div ebx

    add dl, '0'
    dec edi
    mov [edi], dl

    cmp eax, 0
    jne number_loop

    mov ecx, edi
    mov edx, number_buffer + 12
    sub edx, edi
    call print_proc
    ret