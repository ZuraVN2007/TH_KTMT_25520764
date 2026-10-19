# BANG PHAN CONG THANH GHI:
# $s0: Luu so kWh tieu thu (x) do nguoi dung nhap vao
# $s1: Luu tong tien dien tinh duoc cua ho gia dinh
# $s2: Chi so (index) dung de duyet qua cac bac dien
# $s3: Luu nguong tren (Den kWh) cua bac dien hien dang xet
# $s4: Luu don gia thuc te (da cong 20*a) cua bac dien hien dang xet
# $s5: Luu moc duoi (Tu kWh) cua bac truoc do de tinh dung tich bac
# $s6: Luu so kWh con lai can phai tiep tuc tinh tien

.data
    str_prompt:   .asciiz "Nhap so kWh (0..9999): "
    str_error:    .asciiz "Gia tri khong hop le, nhap lai.\n"
    str_result:   .asciiz "Tien dien: "
    str_unit:     .asciiz " dong\n"
    
    # Tham so a trong cong thuc don gia (co the chinh sua)
    a_val:        .word 4
    
    # Mang luu nguong tren cua cac bac (kWh)
    nguong_arr:   .word 50, 100, 200, 300, 400, 9999
    
    # Mang luu don gia co ban tuong ung cua cac bac (khi a = 0)
    dongia_arr:   .word 1600, 1660, 1950, 2500, 2850, 3000

.text
.globl main
main:

input_loop:
    # Loi nhac nhap
    li $v0, 4
    la $a0, str_prompt
    syscall
    
    # Doc so nguyen tu ban phim
    li $v0, 5
    syscall
    move $s0, $v0  # $s0 = x
 
    # Lenh so sanh
    li $t0, 9999
    bgtu $s0, $t0, invalid 
    j valid_input

invalid:
    # In thong bao loi va yeu cau nhap lai
    li $v0, 4
    la $a0, str_error
    syscall
    j input_loop

valid_input:
    li $s1, 0              # TongTien = 0
    move $s6, $s0    # SokWhConLai = x
    li $s2, 0              # index i = 0
    li $s5, 0              # MocDuoi = 0 (bac dau tinh tu 0)
    lw $t8, a_val          # $t8 = a
    li $t9, 20
    mul $t8, $t8, $t9      # $t8 = 20 * a

calc_loop:
    # Neu so kWh con lai <= 0 thi dung
    blez $s6, print_result
    
    # Lay nguong tren cua bac hien tai tu mang
    sll $t1, $s2, 2        # $t1 = i * 4
    la $t2, nguong_arr
    add $t2, $t2, $t1
    lw $s3, 0($t2)         # $s3 = NguongTren
    
    # Lay don gia co ban va cong them 20*a
    la $t2, dongia_arr
    add $t2, $t2, $t1
    lw $s4, 0($t2)         # $s4 = DonGia co ban
    add $s4, $s4, $t8      # $s4 = DonGia thuc te = DonGia_co_ban + 20*a
    
    # Tinh suc chua cua bac: NguongBac = NguongTren - MocDuoi
    sub $t3, $s3, $s5      # $t3 = NguongBac
    
    # Xac dinh so kWh thuoc bac nay: lay min(SokWhConLai, NguongBac)
    bgt $s6, $t3, use_nguong_bac
    move $t4, $s6          # kWh_ThuocBac = SokWhConLai (neu phan con lai nho hon suc chua bac)
    j calc_money
use_nguong_bac:
    move $t4, $t3          # kWh_ThuocBac = NguongBac (neu tieu thu vuot qua suc chua bac)

calc_money:
    # Cong tien dien bac nay vao tong tien: TongTien += kWh_ThuocBac * DonGia
    mul $t5, $t4, $s4
    add $s1, $s1, $t5
    
    # Tru lui so kWh con lai: SokWhConLai -= kWh_ThuocBac
    sub $s6, $s6, $t4
    
    # Cap nhat moc duoi cho bac ke tiep: MocDuoi = NguongTren
    move $s5, $s3
    
    # Tang chi so mang len 1 va lap tiep
    addi $s2, $s2, 1
    j calc_loop

print_result:
    # In chuoi "Tien dien: "
    li $v0, 4
    la $a0, str_result
    syscall
    
    # In gia tri so tien tong cong
    li $v0, 1
    move $a0, $s1
    syscall
    
    # In chuoi " dong\n"
    li $v0, 4
    la $a0, str_unit
    syscall
    
    # Thoat chuong trinh
    li $v0, 10
    syscall
