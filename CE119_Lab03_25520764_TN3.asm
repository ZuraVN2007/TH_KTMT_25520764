
        .data
n:      .word   20
msg:    .asciiz "F(n) = "

        .text
        .globl main
main:
        la    $t0, n
        lw    $a0, 0($t0)           # a0 = n
        jal   fib_rec               # v0 = F(n) 
        move  $s0, $v0
        li    $v0, 4                # in "F(n) = "
        la    $a0, msg
        syscall
        move  $a0, $s0              # in gia tri F(n)
        li    $v0, 1
        syscall
        li    $v0, 10               # thoat
        syscall

fib_rec:
        addi  $sp, $sp, -12         # mo dau: cap khung 3 word
        sw    $ra, 8($sp)
        sw    $s0, 4($sp)
        sw    $s1, 0($sp)
        slti  $t0, $a0, 2           # n < 2 ?
        beq   $t0, $zero, fr_rec
fr_base:
        move  $v0, $a0              # truong hop co so: F(0)=0, F(1)=1 -> F(n)=n
        j     fr_ret
fr_rec:
        move  $s0, $a0              # s0 = n
        addi  $a0, $s0, -1
        jal   fib_rec               # v0 = F(n-1)
        move  $s1, $v0              # giu F(n-1) qua loi goi tiep theo
        addi  $a0, $s0, -2
        jal   fib_rec               # v0 = F(n-2)
        add   $v0, $v0, $s1         # F(n) = F(n-2) + F(n-1)
fr_ret:
        lw    $s1, 0($sp)           # ket thuc: nap lai dung offset
        lw    $s0, 4($sp)
        lw    $ra, 8($sp)
        addi  $sp, $sp, 12          # thu hoi khung
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
