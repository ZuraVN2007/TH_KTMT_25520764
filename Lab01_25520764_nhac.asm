
# - Don vi nhip = 210 ms
# - Nhac cu = 40 
# - Am luong = 100
# - Dich giong: +4 vao cao do

.data
    num_notes:      .word 15
    unit_ms:        .word 210        # 150 + 10*6 = 210 ms
    instrument:     .word 40         # So hieu nhac cu
    volume:         .word 100        # Am luong
    shift_a:        .word 4          # Tham so a = 4
    
    # Mang cao do goc cua 15 not 
    pitch_arr:      .word 64, 64, 65, 67, 67, 65, 64, 62, 60, 60, 62, 64, 64, 62, 62
    
    # Mang do dai (don vi nhip) cua 15 not
    duration_arr:   .word 2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  2,  3,  1,  4
    
    str_space:      .asciiz " "
    str_newline:    .asciiz "\n"
    str_expected:   .asciiz "Tong du kien (ms): "
    str_measured:   .asciiz "Thoi gian do duoc (ms): "

.text
.globl main
main:
    # 1. Doc thoi gian bat dau truoc khi phat nhac 
    li $v0, 30
    syscall
    move $s6, $a0          # $s6 luu thoi gian bat dau (ms)
    
    # 2. Khoi tao cac bien duyet vong lap
    li $s0, 0              # index i = 0
    lw $s1, num_notes      # $s1 = 15 not
    li $s2, 0              # tong_du_kien = 0 (ms)
    
    lw $t8, unit_ms        # $t8 = 210
    lw $t9, instrument     # $t9 = 40
    lw $t7, volume         # $t7 = 100
    lw $t6, shift_a        # $t6 = 4

play_loop:
    bge $s0, $s1, finish_play  # Neu i >= 15 thi thoat vong lap
    
    # Lay cao do goc tai index i
    sll $t0, $s0, 2        # offset = i * 4
    la  $t1, pitch_arr
    add $t1, $t1, $t0
    lw  $t2, 0($t1)        # $t2 = cao do goc
    add $t2, $t2, $t6      # $t2 = cao do thuc te (cao do + a)
    
    # Lay do dai (don vi nhip) tai index i
    la  $t1, duration_arr
    add $t1, $t1, $t0
    lw  $t3, 0($t1)        # $t3 = do dai (nhip)
    
    # Tinh thoi luong thuc te (ms) = do dai * 210
    mul $t4, $t3, $t8      # $t4 = thoi luong (ms)
    
    # Cong don vao tong du kien
    add $s2, $s2, $t4
    
    # In ra man hinh: <cao do thuc> <ms>
    # In cao do
    li $v0, 1
    move $a0, $t2
    syscall
    
    # In khoang trang
    li $v0, 4
    la $a0, str_space
    syscall
    
    # In thoi luong (ms)
    li $v0, 1
    move $a0, $t4
    syscall
    
    # In xuong dong
    li $v0, 4
    la $a0, str_newline
    syscall
    
    # Goi syscall 33 de phat not MIDI
    # $v0 = 33, $a0 = pitch, $a1 = duration (ms), $a2 = instrument, $a3 = volume
    li $v0, 33
    move $a0, $t2          # pitch
    move $a1, $t4          # duration (ms)
    move $a2, $t9          # instrument (40)
    move $a3, $t7          # volume (100)
    syscall
    
    # Tang chi so i len 1 va lap lai
    addi $s0, $s0, 1
    j play_loop

finish_play:
    # 3. Doc thoi gian ket thuc sau khi phat xong (syscall 30)[cite: 3]
    li $v0, 30
    syscall
    move $s7, $a0          # $s7 luu thoi gian ket thuc (ms)
    
    # Tinh thoi gian thuc te do duoc = thoi gian ket thuc - thoi gian bat dau
    sub $t5, $s7, $s6      # $t5 = thoi gian do duoc (ms)
    
    # 4. In cac thong tin tong ket cuoi chuong trình
    # In chuoi "Tong du kien (ms): "
    li $v0, 4
    la $a0, str_expected
    syscall
    
    # In gia tri tong du kien ($s2)
    li $v0, 1
    move $a0, $s2
    syscall
    
    # In xuong dong
    li $v0, 4
    la $a0, str_newline
    syscall
    
    # In chuoi "Thoi gian do duoc (ms): "
    li $v0, 4
    la $a0, str_measured
    syscall
    
    # In gia tri thoi gian do duoc ($t5)
    li $v0, 1
    move $a0, $t5
    syscall
    
    # 5. Thoat chuong trinh (syscall 10)
    li $v0, 10
    syscall