
        .data
t1:     .asciiz "kien truc may tinh"
t2:     .asciiz "mips"
t3:     .asciiz ""
t4:     .asciiz "a bc def"
t5:     .asciiz "lenh jal ghi dia chi vao ra"
        .align 2
tbl:    .word   t1, t2, t3, t4, t5                # bang dia chi 5 chuoi kiem thu
bar:    .asciiz "|"
nl:     .asciiz "\n"

        .text
        .globl main

main:
        la    $s0, tbl
        addi  $s1, $s0, 20          # 5 phan tu x 4 byte
m_loop:
        beq   $s0, $s1, m_end
        lw    $a0, 0($s0)           # a0 = dia chi chuoi
        jal   reverse_words
        li    $v0, 4                # in "|"
        la    $a0, bar
        syscall
        lw    $a0, 0($s0)           # in chuoi (da bi dao)
        li    $v0, 4
        syscall
        la    $a0, bar              # in "|"
        li    $v0, 4
        syscall
        la    $a0, nl               # xuong dong
        li    $v0, 4
        syscall
        addi  $s0, $s0, 4
        j     m_loop
m_end:
        li    $v0, 10
        syscall

strlen:
        move  $v0, $zero            # i = 0
sl_loop:
        addu  $t0, $a0, $v0         # t0 = &s[i]
        lb    $t1, 0($t0)           # t1 = s[i]
        beq   $t1, $zero, sl_done
        addiu $v0, $v0, 1
        j     sl_loop
sl_done:
        jr    $ra

rev_range:
        sltu  $t0, $a0, $a1         # doan rong hoac 1 ky tu (dau >= cuoi): khong lam gi
        beq   $t0, $zero, rr_done
rr_loop:
        lb    $t1, 0($a0)
        lb    $t2, 0($a1)
        sb    $t2, 0($a0)           # hoan doi hai ky tu
        sb    $t1, 0($a1)
        addiu $a0, $a0, 1
        addiu $a1, $a1, -1
        sltu  $t0, $a0, $a1         # con khi dau < cuoi
        bne   $t0, $zero, rr_loop
rr_done:
        jr    $ra

reverse_words:
        addi  $sp, $sp, -16         # mo dau: cap khung 4 word
        sw    $ra, 12($sp)
        sw    $s0, 8($sp)
        sw    $s1, 4($sp)
        sw    $s2, 0($sp)
        move  $s0, $a0              # s0 = dau chuoi (can sau lenh jal)
        jal   strlen                # v0 = do dai
        beq   $v0, $zero, rw_done   # chuoi rong: khong lam gi, ra qua phan ket thuc
        addu  $t0, $s0, $v0
        addi  $a1, $t0, -1          # a1 = dia chi ky tu cuoi
        move  $a0, $s0              # a0 = dia chi ky tu dau
        jal   rev_range             # buoc 1: dao toan bo chuoi
        move  $s1, $s0              # s1 = con tro duyet
        move  $s2, $s0              # s2 = dau tu hien tai
rw_scan:
        lb    $t0, 0($s1)
        beq   $t0, $zero, rw_last   # het chuoi: con tu cuoi can dao
        li    $t1, 32               # dau cach ' '
        bne   $t0, $t1, rw_next
        move  $a0, $s2              # gap dau cach: dao tu [s2, s1-1]
        addi  $a1, $s1, -1
        jal   rev_range             # buoc 2: dao lai tung tu
        addi  $s2, $s1, 1           # tu tiep theo bat dau sau dau cach
rw_next:
        addi  $s1, $s1, 1
        j     rw_scan
rw_last:
        move  $a0, $s2              # dao tu cuoi cung [s2, s1-1]
        addi  $a1, $s1, -1
        jal   rev_range
rw_done:
        lw    $s2, 0($sp)           # ket thuc: nap lai dung offset
        lw    $s1, 4($sp)
        lw    $s0, 8($sp)
        lw    $ra, 12($sp)
        addi  $sp, $sp, 16          # thu hoi khung
        jr    $ra
