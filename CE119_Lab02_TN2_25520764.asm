.data
# Mang diem ca nhan: S[i] = (A0[i] + 4) mod 11
scores:   .word 10, 7, 1, 2, 6, 9, 0, 6, 10, 2, 8, 7      # T1 (n = 12)
t2_arr:   .word 10                                         # T2 (n = 1)
t3_arr:   .word 4, 4, 4, 4, 4                              # T3 (n = 5)
cases:    .word t2_arr, 1, t3_arr, 5
hist:     .word 0, 0, 0, 0
# nhom 0: 0-3 | nhom 1: 4-6 | nhom 2: 7-8 | nhom 3: 9-10
grade_tab: .byte 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3
str_min:   .asciiz "min="
str_max:   .asciiz " max="
str_more:  .asciiz "\n== T2, T3 ==\n"

.text
main:
    # ---- T1: mang diem ca nhan ----
    la   $a0, scores
    li   $a1, 12
    jal  stats
    move $s0, $v0
    move $s1, $v1
    la   $a0, scores
    li   $a1, 12
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram
    move $a0, $s0
    move $a1, $s1
    la   $a2, hist
    jal  print_report

    # ---- T2, T3 ----
    la   $a0, str_more
    li   $v0, 4
    syscall
    la   $s2, cases
    li   $s3, 2
    li   $s4, 2
ex_loop:
    beq  $s3, $zero, ex_done
    li   $a0, 84
    li   $v0, 11
    syscall
    move $a0, $s4
    li   $v0, 1
    syscall
    li   $a0, 58
    li   $v0, 11
    syscall
    li   $a0, 10
    li   $v0, 11
    syscall
    lw   $s5, 0($s2)
    lw   $s6, 4($s2)
    move $a0, $s5
    move $a1, $s6
    jal  stats
    move $s0, $v0
    move $s1, $v1
    la   $a0, hist
    jal  clear_hist
    move $a0, $s5
    move $a1, $s6
    la   $a2, grade_tab
    la   $a3, hist
    jal  histogram
    move $a0, $s0
    move $a1, $s1
    la   $a2, hist
    jal  print_report
    addi $s2, $s2, 8
    addi $s3, $s3, -1
    addi $s4, $s4, 1
    j    ex_loop
ex_done:
    li   $v0, 10
    syscall

# stats: tim gia tri nho nhat va lon nhat cua mang word (mot luot duyet)

stats:
    lw   $v0, 0($a0)            # min = a[0]
    move $v1, $v0               # max = a[0]
    addi $a0, $a0, 4            # bo qua phan tu dau
    addi $a1, $a1, -1
st_loop:
    beq  $a1, $zero, st_done
    lw   $t0, 0($a0)
    slt  $t1, $t0, $v0          # t0 < min ?
    beq  $t1, $zero, st_max
    move $v0, $t0
st_max:
    slt  $t1, $v1, $t0          # max < t0 ?
    beq  $t1, $zero, st_next
    move $v1, $t0
st_next:
    addi $a0, $a0, 4
    addi $a1, $a1, -1
    j    st_loop
st_done:
    jr   $ra

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

# print_report: in "min=<a> max=<b>" va "g0=.. g1=.. g2=.. g3=.."

print_report:
    move $t0, $a0               # min
    move $t1, $a1               # max
    move $t2, $a2               # hist
    la   $a0, str_min
    li   $v0, 4
    syscall
    move $a0, $t0
    li   $v0, 1
    syscall
    la   $a0, str_max
    li   $v0, 4
    syscall
    move $a0, $t1
    li   $v0, 1
    syscall
    li   $a0, 10
    li   $v0, 11
    syscall
    li   $t3, 0                 # i
pr_loop:
    slti $t4, $t3, 4
    beq  $t4, $zero, pr_done
    li   $a0, 103               # 'g'
    li   $v0, 11
    syscall
    addi $a0, $t3, 48           # chu so i
    li   $v0, 11
    syscall
    li   $a0, 61                # '='
    li   $v0, 11
    syscall
    sll  $t5, $t3, 2
    add  $t5, $t2, $t5
    lw   $a0, 0($t5)            # hist[i]
    li   $v0, 1
    syscall
    addi $t4, $t3, -3
    li   $a0, 32                # ' ' giua cac nhom
    bne  $t4, $zero, pr_sep
    li   $a0, 10                # xuong dong sau nhom cuoi
pr_sep:
    li   $v0, 11
    syscall
    addi $t3, $t3, 1
    j    pr_loop
pr_done:
    jr   $ra

# clear_hist: gan 4 phan tu hist bang 0

clear_hist:
    sw   $zero, 0($a0)
    sw   $zero, 4($a0)
    sw   $zero, 8($a0)
    sw   $zero, 12($a0)
    jr   $ra
