.data
scores:   .word 10, 7, 1, 2, 6, 9, 0, 6, 10, 2, 8, 7
hist:     .word 0, 0, 0, 0
grade_tab: .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3

.text
main:
    la   $a0, scores
    li   $a1, 12
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram          # tinh hist cho mang ca nhan (T1)
    la   $a0, hist
    li   $a1, 4
    jal  draw_hist          # ve pho diem
    li   $v0, 10
    syscall

# histogram: dem so sinh vien theo nhom bang bang tra grade_tab

histogram:
hg_loop:
    beq  $a1, $zero, hg_done
    lw   $t0, 0($a0)            # s = diem
    add  $t1, $a2, $t0          # &grade_tab[s]  (mang byte: chi so = offset)
    lbu  $t2, 0($t1)            # g = nhom cua s
    sll  $t2, $t2, 2            # g * 4: chi so word -> offset byte
    add  $t3, $a3, $t2          # &hist[g]
    lw   $t4, 0($t3)
    addi $t4, $t4, 1
    sw   $t4, 0($t3)            # hist[g]++
    addi $a0, $a0, 4            # phan tu ke tiep (mang word)
    addi $a1, $a1, -1
    j    hg_loop
hg_done:
    jr   $ra

# draw_hist: ve pho diem bang ky tu | (moi nhom mot dong "gi: |||")

draw_hist:
    move $t0, $a0               # con tro hist (syscall se pha $a0)
    move $t1, $a1               # so nhom
    li   $t2, 0                 # i
dh_row:
    beq  $t2, $t1, dh_done
    li   $a0, 103               # 'g'
    li   $v0, 11
    syscall
    addi $a0, $t2, 48           # chu so i
    li   $v0, 11
    syscall
    li   $a0, 58                # ':'
    li   $v0, 11
    syscall
    li   $a0, 32                # ' '
    li   $v0, 11
    syscall
    lw   $t3, 0($t0)            # so sinh vien cua nhom
dh_bar:
    beq  $t3, $zero, dh_eol
    li   $a0, 124               # '|'
    li   $v0, 11
    syscall
    addi $t3, $t3, -1
    j    dh_bar
dh_eol:
    li   $a0, 10
    li   $v0, 11
    syscall
    addi $t0, $t0, 4
    addi $t2, $t2, 1
    j    dh_row
dh_done:
    jr   $ra
