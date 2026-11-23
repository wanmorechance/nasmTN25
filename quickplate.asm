%macro print 2
    push eax
    push ebx
    push ecx
    push edx

    mov ebx, [output_fd]
    mov ecx, %1
    mov edx, %2
    call write_output

    pop edx
    pop ecx
    pop ebx
    pop eax
%endmacro

section .data
    menu db "==============================", 10
         db "          QUICKPLATE", 10 
         db "     Food Ordering System", 10
         db "==============================", 10
         db "1. View food menu", 10
         db "2. Place an order", 10
         db "3. View current order", 10
         db "4. Checkout", 10
         db "5. View saved receipt", 10
         db "6. Exit", 10

    menu_len equ $ - menu

    choice_prompt db "Enter your choice: "
    choice_prompt_len equ $ - choice_prompt

    food_menu db 10, "=== QUICKPLATE FOOD MENU ===", 10
              db "1. Pork Sisig      PHP 80", 10
              db "2. Fried Chicken   PHP 60", 10
              db "3. Chicken Adobo   PHP 75", 10
              db "4. Beef Kare-Kare  PHP 120", 10
              db "5. Chicken Tinola  PHP 75", 10
              db "6. Plain Rice      PHP 15", 10, 10
    food_menu_len equ $ - food_menu

    item_prompt db "Enter food item (1-6): "
    item_prompt_len equ $ - item_prompt

    qty_prompt db "Enter number of servings (1-9): "
    qty_prompt_len equ $ - qty_prompt

    added_msg db "Item added to your order.", 10, 10
    added_msg_len equ $ - added_msg

    error_msg db "Invalid input. Order not added.", 10, 10
    error_msg_len equ $ - error_msg

    order_heading db 10, "=== CURRENT ORDER ===", 10
    order_heading_len equ $ - order_heading

    dish1 db "Pork Sisig: "
    dish1_len equ $ - dish1

    dish2 db "Fried Chicken: "
    dish2_len equ $ - dish2

    dish3 db "Chicken Adobo: "
    dish3_len equ $ - dish3

    dish4 db "Beef Kare-Kare: "
    dish4_len equ $ - dish4

    dish5 db "Chicken Tinola: "
    dish5_len equ $ - dish5

    dish6 db "Plain Rice: "
    dish6_len equ $ - dish6

    newline db 10

    subtotal_label db " | PHP "
    subtotal_label_len equ $ - subtotal_label

    total_label db "TOTAL: PHP "
    total_label_len equ $ - total_label

    payment_prompt db "Enter payment in whole pesos: "
    payment_prompt_len equ $ - payment_prompt

    change_label db "Change: PHP "
    change_label_len equ $ - change_label

    empty_msg db "Your order is empty.", 10, 10
    empty_msg_len equ $ - empty_msg

    payment_error db "Enter a whole number from 0 to 999999.", 10
    payment_error_len equ $ - payment_error

    insufficient_msg db "Insufficient payment. Please try again.", 10
    insufficient_msg_len equ $ - insufficient_msg

    paid_msg db "Payment accepted. Thank you!", 10, 10
    paid_msg_len equ $ - paid_msg

    output_fd dd 1

    receipt_filename db "receipt.txt", 0

    receipt_heading db "=== QUICKPLATE RECEIPT ===", 10
    receipt_heading_len equ $ - receipt_heading

    payment_label db "Payment: PHP "
    payment_label_len equ $ - payment_label

    saved_msg db "Receipt saved to receipt.txt.", 10, 10
    saved_msg_len equ $ - saved_msg

    save_error_msg db "Could not save receipt. Order kept.", 10, 10
    save_error_msg_len equ $ - save_error_msg

    read_error_msg db "Could not open or read receipt.txt.", 10
                   db "Complete a successful checkout first.", 10, 10
    read_error_msg_len equ $ - read_error_msg

    ascii_art db 10
              db "           )  )  )", 10
              db "          (  (  (", 10
              db "        .----------.", 10
              db "       /            \", 10
              db "      /______________\", 10
              db "     ==================", 10
              db "         QUICKPLATE", 10, 10
    ascii_art_len equ $ - ascii_art

section .bss
    selected_item resd 1
    quantities resd 6
    number_buffer resb 10
    total resd 1
    payment resd 1
    change resd 1
    input_char resb 1
    receipt_fd resd 1
    output_error resd 1
    receipt_buffer resb 512

section .text
    global _start

_start:
    print ascii_art, ascii_art_len   

main_menu:
    print menu, menu_len
    print choice_prompt, choice_prompt_len

    call read_number

    cmp eax, 1
    je show_food

    cmp eax, 2
    je place_order

    cmp eax, 3
    je view_order

    cmp eax, 4
    je checkout

    cmp eax, 5
    je view_receipt

    cmp eax, 6
    je exit_program

    jmp main_menu

show_food:
    ;display food menu
    print food_menu, food_menu_len
    jmp main_menu

place_order:
    print food_menu, food_menu_len

    ;ask which item to order
    print item_prompt, item_prompt_len
    call read_number

    ;accept only items 1-6
    cmp eax, 1
    jb invalid_order
    cmp eax, 6
    ja invalid_order

    ;convert food number into index 0-5
    sub eax, 1
    mov [selected_item], eax

    ;ask for quantity
    print qty_prompt, qty_prompt_len
    call read_number

    ;accept only quantities 1-9
    cmp eax, 1
    jb invalid_order
    cmp eax, 9
    ja invalid_order

    ;add quantity to selected food existing quantity
    mov ebx, [selected_item]
    add eax, [quantities + ebx*4]

    cmp eax, 99
    ja invalid_order

    mov [quantities + ebx*4], eax

    print added_msg, added_msg_len
    jmp main_menu

invalid_order:
    print error_msg, error_msg_len
    jmp main_menu

view_order:
    call display_order
    jmp main_menu

display_order:
    ;reset total before calculating the order
    mov dword [total], 0

    print order_heading, order_heading_len

    print dish1, dish1_len
    mov eax, [quantities]
    mov ebx, 80
    call print_order_line

    print dish2, dish2_len
    mov eax, [quantities + 4]
    mov ebx, 60
    call print_order_line

    print dish3, dish3_len
    mov eax, [quantities + 8]
    mov ebx, 75
    call print_order_line

    print dish4, dish4_len
    mov eax, [quantities + 12]
    mov ebx, 120
    call print_order_line

    print dish5, dish5_len
    mov eax, [quantities + 16]
    mov ebx, 75
    call print_order_line

    print dish6, dish6_len
    mov eax, [quantities + 20]
    mov ebx, 15
    call print_order_line

    print total_label, total_label_len
    mov eax, [total]
    call print_number
    print newline, 1
    print newline, 1
    ret

checkout:
    call display_order

    cmp dword [total], 0
    je empty_order

ask_payment:
    print payment_prompt, payment_prompt_len
    call read_number

    ;the procedure returns -1 for invalid input
    cmp eax, -1
    je invalid_payment

    cmp eax, [total]
    jb insufficient_payment

    mov [payment], eax

    ;change = payment - total
    sub eax, [total]
    mov [change], eax

    print change_label, change_label_len
    mov eax, [change]
    call print_number
    print newline, 1

    call save_receipt
    cmp eax, -1
    je receipt_save_failed

    print paid_msg, paid_msg_len
    print saved_msg, saved_msg_len

    ;clear the completed order
    mov dword [quantities], 0
    mov dword [quantities + 4], 0
    mov dword [quantities + 8], 0
    mov dword [quantities + 12], 0
    mov dword [quantities + 16], 0
    mov dword [quantities + 20], 0
    mov dword [total], 0

    jmp main_menu

empty_order:
    print empty_msg, empty_msg_len
    jmp main_menu

invalid_payment:
    print payment_error, payment_error_len
    jmp ask_payment

insufficient_payment:
    print insufficient_msg, insufficient_msg_len
    jmp ask_payment

receipt_save_failed:
    print save_error_msg, save_error_msg_len
    jmp main_menu

view_receipt:
    ;open receipt.txt for reading
    mov eax, 5
    mov ebx, receipt_filename
    mov ecx, 0
    int 0x80

    cmp eax, 0
    jl receipt_read_failed

    mov [receipt_fd], eax
    mov dword [output_error], 0

read_receipt_loop:
    ;read a chunk from the file
    mov eax, 3
    mov ebx, [receipt_fd]
    mov ecx, receipt_buffer
    mov edx, 512
    int 0x80

    ;retry if the read was interrupted
    cmp eax, -4
    je read_receipt_loop

    cmp eax, 0
    jl receipt_read_close_error
    je receipt_read_done

    ;display exactly the number of bytes read
    mov edx, eax
    mov ecx, receipt_buffer
    mov ebx, 1
    call write_output

    cmp dword [output_error], 0
    jne receipt_read_close_error

    jmp read_receipt_loop

receipt_read_done:
    ;close the file after reaching its end
    mov eax, 6
    mov ebx, [receipt_fd]
    int 0x80

    cmp eax, 0
    jl receipt_read_failed

    print newline, 1
    jmp main_menu

receipt_read_close_error:
    ;close the opened file before displaying an error
    mov eax, 6
    mov ebx, [receipt_fd]
    int 0x80

receipt_read_failed:
    print read_error_msg, read_error_msg_len
    jmp main_menu

exit_program:
    mov eax, 1
    mov ebx, 0
    int 0x80

;prints the unsigned number from eax
print_number:
    push eax
    push ebx
    push ecx
    push edx
    push edi

    mov edi, number_buffer + 10
    mov ebx, 10
    mov ecx, 0

convert_digit:
    mov edx, 0
    div ebx

    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx

    cmp eax, 0
    jne convert_digit

    mov edx, ecx
    mov ecx, edi
    mov ebx, [output_fd]
    call write_output

    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

;eax = quantity, ebx = price per serving
print_order_line:
    call print_number

    ; Calculate this dish's subtotal
    imul eax, ebx
    add [total], eax

    print subtotal_label, subtotal_label_len
    call print_number
    print newline, 1
    ret

;returns EAX = number, or -1 for invalid input
read_number:
    push ebx
    push ecx
    push edx
    push esi
    push edi
    push ebp

    mov esi, 0             ;number being built
    mov edi, 0             ;digit count
    mov ebp, 0             ;invalid input flag

read_number_loop:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_char
    mov edx, 1
    int 0x80

    cmp eax, 0
    jle exit_program

    movzx eax, byte [input_char]

    ;enter ends the input
    cmp eax, 10
    je read_number_done

    cmp eax, '0'
    jb read_number_bad
    cmp eax, '9'
    ja read_number_bad

    ;accept at most six digits
    cmp edi, 6
    jae read_number_bad

    sub eax, '0'
    imul esi, esi, 10
    add esi, eax
    inc edi

    jmp read_number_loop

read_number_bad:
    mov ebp, 1
    ;continue reading until Enter, discarding the invalid line
    jmp read_number_loop

read_number_done:
    cmp edi, 0
    je read_number_invalid

    cmp ebp, 0
    jne read_number_invalid

    mov eax, esi
    jmp read_number_return

read_number_invalid:
    mov eax, -1

read_number_return:
    pop ebp
    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

;ebx = destination, ecx = text address, edx = byte count
write_output:
    cmp edx, 0
    je write_output_done

write_output_loop:
    mov eax, 4
    int 0x80

    ;retry if Linux interrupted the operation
    cmp eax, -4
    je write_output_loop

    cmp eax, 0
    jle write_output_failed

    ;continue if only part of the text was written
    add ecx, eax
    sub edx, eax
    cmp edx, 0
    jne write_output_loop

write_output_done:
    ret

write_output_failed:
    mov dword [output_error], 1
    ret

;returns EAX = 0 on success, -1 on failure
save_receipt:
    ;open or create receipt.txt, replacing its old contents
    mov eax, 5
    mov ebx, receipt_filename
    mov ecx, 577
    mov edx, 384
    int 0x80

    cmp eax, 0
    jl save_receipt_failed

    mov [receipt_fd], eax
    mov [output_fd], eax
    mov dword [output_error], 0

    ;these now write into the file
    print receipt_heading, receipt_heading_len
    call display_order

    print payment_label, payment_label_len
    mov eax, [payment]
    call print_number
    print newline, 1

    print change_label, change_label_len
    mov eax, [change]
    call print_number
    print newline, 1

    ;restore terminal output
    mov dword [output_fd], 1

    ;close the receipt file
    mov eax, 6
    mov ebx, [receipt_fd]
    int 0x80

    cmp eax, 0
    jl save_receipt_failed

    cmp dword [output_error], 0
    jne save_receipt_failed

    mov eax, 0
    ret

save_receipt_failed:
    mov eax, -1
    ret