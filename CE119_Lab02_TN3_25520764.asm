.data
br_tests: .word sP, s1, s2, s3, s4, s5, s6, s7, s8, 0
str_arrow: .asciiz " -> ("
sP: .asciiz "([{([{()}])}])"        # chuoi ca nhan P: k = 7 cap long nhau
s1: .asciiz "(a+b)*[c-{d/e}]"
s2: .asciiz "f(x[i]{j}))"
s3: .asciiz "{[(])}"
s4: .asciiz "((a)"
s5: .asciiz ""
s6: .asciiz "no brackets here"
s7: .asciiz "]"
s8: .asciiz "([)]"

.text
main:
    # ---- Buoc 3.1: push / pop (xem $sp va Data Segment "current $sp") ----
    li   $t0, 11
    li   $t1, 22
    li   $t2, 33
    addi $sp, $sp, -4
    sw   $t0, 0($sp)        # push 11
    addi $sp, $sp, -4
    sw   $t1, 0($sp)        # push 22
    addi $sp, $sp, -4
    sw   $t2, 0($sp)        # push 33
    lw   $t3, 0($sp)        # pop
    addi $sp, $sp, 4
    lw   $t4, 0($sp)        # pop
    addi $sp, $sp, 4
    lw   $t5, 0($sp)        # pop
    addi $sp, $sp, 4

    # ---- Kiem tra ngoac: chuoi P chay dau tien -> breakpoint tai cb_close
    #      o lan dung dau tien la luc ngan xep sau nhat ----
    la   $s2, br_tests
br_loop:
    lw   $s3, 0($s2)
    beq  $s3, $zero, br_done
    li   $a0, 34
    li   $v0, 11
    syscall
    move $a0, $s3
    li   $v0, 4
    syscall
    li   $a0, 34
    li   $v0, 11
    syscall
    la   $a0, str_arrow
    li   $v0, 4
    syscall
    move $a0, $s3
    jal  check_brackets
    move $s4, $v0
    move $s5, $v1
    move $a0, $s4
    li   $v0, 1
    syscall
    li   $a0, 44
    li   $v0, 11
    syscall
    move $a0, $s5
    li   $v0, 1
    syscall
    li   $a0, 41
    li   $v0, 11
    syscall
    li   $a0, 10
    li   $v0, 11
    syscall
    addi $s2, $s2, 4
    j    br_loop
br_done:
    li   $v0, 10
    syscall

# check_brackets: kiem tra ngoac ( ) [ ] { } can bang bang ngan xep

check_brackets:
    move $t9, $sp               # $sp luc vao
    li   $t0, 0                 # vi tri hien tai (dem tu 1)
cb_loop:
    lbu  $t1, 0($a0)            # ky tu hien tai
    beq  $t1, $zero, cb_eos     # het chuoi
    addi $t0, $t0, 1
    li   $t2, 40                # '('
    beq  $t1, $t2, cb_push
    li   $t2, 91                # '['
    beq  $t1, $t2, cb_push
    li   $t2, 123               # '{'
    beq  $t1, $t2, cb_push
    li   $t3, 40                # cap voi ')'
    li   $t2, 41                # ')'
    beq  $t1, $t2, cb_close
    li   $t3, 91                # cap voi ']'
    li   $t2, 93                # ']'
    beq  $t1, $t2, cb_close
    li   $t3, 123               # cap voi '}'
    li   $t2, 125               # '}'
    beq  $t1, $t2, cb_close
    j    cb_next                # ky tu khac: bo qua
cb_push:
    addi $sp, $sp, -4           # push ngoac mo
    sw   $t1, 0($sp)
    j    cb_next
cb_close:
    beq  $sp, $t9, cb_err2      # stack rong -> loi 2
    lw   $t4, 0($sp)            # pop ngoac mo o dinh
    addi $sp, $sp, 4
    bne  $t4, $t3, cb_err1      # khac loai -> loi 1
cb_next:
    addi $a0, $a0, 1
    j    cb_loop
cb_eos:
    bne  $sp, $t9, cb_err3      # con ngoac mo chua dong -> loi 3
    li   $v0, 0
    li   $v1, 0
    j    cb_ret
cb_err1:
    move $v0, $t0
    li   $v1, 1
    j    cb_ret
cb_err2:
    move $v0, $t0
    li   $v1, 2
    j    cb_ret
cb_err3:
    addi $v0, $t0, 1            # do dai chuoi + 1
    li   $v1, 3
cb_ret:
    move $sp, $t9               # khoi phuc $sp: duong thoat duy nhat
    jr   $ra
