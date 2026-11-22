        .data
msg:    .asciiz "Ket qua: "

        .text
        .globl main
main:
        li    $a0, 5            # x = 5
        jal   outer             # v0 = outer(5)
        move  $s0, $v0
        li    $v0, 4            # in chuoi "Ket qua: "
        la    $a0, msg
        syscall
        move  $a0, $s0          # in so nguyen
        li    $v0, 1
        syscall
        li    $v0, 10           # thoat
        syscall
outer:
        addi  $sp, $sp, -4      # mo dau: cap khung 1 word
        sw    $ra, 0($sp)       #   cat dia chi tro ve ve main
        jal   inner             # v0 = inner(x) 
        addi  $v0, $v0, 1       # v0 = inner(x) + 1
        lw    $ra, 0($sp)       # ket thuc: nap lai $ra
        addi  $sp, $sp, 4       #   thu hoi khung
        jr    $ra               # tro ve main dung cho
inner:
        add   $v0, $a0, $a0
        jr    $ra
