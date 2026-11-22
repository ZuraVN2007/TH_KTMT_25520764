
        .data
n:      .word   15
msg:    .asciiz "F(n) = "

        .text
        .globl main
main:
        la    $t0, n
        lw    $a0, 0($t0)           # a0 = n
        jal   fib_opt               # v0 = F(n)
        move  $s0, $v0
        li    $v0, 4                # in "F(n) = "
        la    $a0, msg
        syscall
        move  $a0, $s0              # in gia tri F(n)
        li    $v0, 1
        syscall
        li    $v0, 10               # thoat
        syscall

fib_opt:
        slti  $t0, $a0, 2           # n < 2 ?
        beq   $t0, $zero, fo_rec
        move  $v0, $a0              # truong hop co so: tra ve ngay, khong cap khung
        jr    $ra
fo_rec:
        addi  $sp, $sp, -12
        sw    $ra, 8($sp)
        sw    $s0, 4($sp)
        sw    $s1, 0($sp)
        move  $s0, $a0
        addi  $a0, $s0, -1
        jal   fib_opt
        move  $s1, $v0
        addi  $a0, $s0, -2
        jal   fib_opt
        add   $v0, $v0, $s1
        lw    $s1, 0($sp)
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addi  $sp, $sp, 12
        jr    $ra

fib_iter:
        move  $v0, $zero        # a = F(0)
        li    $t0, 1            # b = F(1)
        move  $t1, $zero        # i = 0
fi_loop:
        slt   $t2, $t1, $a0
        beq   $t2, $zero, fi_done
        addu  $t3, $v0, $t0     # a + b
        move  $v0, $t0
        move  $t0, $t3
        addiu $t1, $t1, 1
        j     fi_loop
fi_done:
        jr    $ra
