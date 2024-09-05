.data

;------------------------------------------------------------------------

    ; Left_Rectangle:

    hundred real8 100.0
    x real8 ?
    rect_res real8 ?

    ; Calculate_Integral:

    tiny_num real8 0.0001

    b real8 6.0
    a real8 0.0

    n dword ?

    h real8 ?

    cur_x real8 0.0

    res real8 0.0

;------------------------------------------------------------------------

.code
public Left_Rectangle

;------------------------------------------------------------------------

Left_Rectangle proc
    ; extern "C" double Left_Rectangle(double x);
    ; Input: 
    ;   x -> XMM0
    ; Output:
    ;   Result -> XMM0

    movsd qword ptr [x], XMM0       ; ��������� ������� �������� � ���������� x

    ; ���������, �� ����� �� x ����
    pxor XMM1, XMM1                 ; XMM1 = 0.0
    ucomisd XMM0, XMM1              ; ���������� XMM0 � XMM1
    jne x_is_not_zero

    ; ���� x == 0, ��������� tiny_num ��� �������������� ������� �� ����
    addsd XMM0, qword ptr [tiny_num]
    movsd qword ptr [x], XMM0

x_is_not_zero:

    ; ��������� ��������� (sin(100 * x)) / x
    movsd XMM1, qword ptr [hundred] ; XMM1 = 100.0
    mulsd XMM1, XMM0                ; XMM1 = 100 * x
    movsd qword ptr [rect_res], XMM1 ; ��������� XMM1 ��� ������������� FPU

    ; �������������� ����� FPU ��� ���������� sin(100 * x)
    fld qword ptr [rect_res]        ; ��������� �������� � FPU ����
    fsin                            ; ��������� sin(100 * x)
    fstp qword ptr [rect_res]       ; ��������� ��������� � rect_res

    ; ����� ��������� �� x
    movsd XMM2, qword ptr [rect_res] ; ��������� ��������� sin(100 * x) ������� � XMM2
    divsd XMM2, XMM0                ; XMM2 = sin(100 * x) / x

    ; ���������� ��������� � XMM0
    movsd XMM0, XMM2
    ret

Left_Rectangle endp

;------------------------------------------------------------------------

Calculate_Integral proc
    ; extern "C" double Calculate_Integral(double n);
    ; Input:
    ;   n -> ECX
    ; Output:
    ;   Result -> XMM0

    ; �������������� ����������
    mov n, ECX

    ; ��������� ��� h = (b - a) / n
    movsd XMM0, qword ptr [b]
    subsd XMM0, qword ptr [a]         ; XMM0 = b - a

    cvtsi2sd XMM1, n                  ; ����������� n � double � ��������� � XMM1
    divsd XMM0, XMM1                  ; XMM0 = (b - a) / n
    movsd qword ptr [h], XMM0         ; ��������� h � ������

    ; �������������� ������� ������� � ���������
    pxor XMM0, XMM0                   ; XMM0 = 0.0 (������������� ����)
    movsd qword ptr [cur_x], XMM0     ; cur_x = 0.0

    pxor XMM0, XMM0                   ; XMM0 = 0.0 (������������� ����)
    movsd qword ptr [res], XMM0       ; res = 0.0

    ; ���� ��������������
    mov ECX, n
while_n:
    ; ��������� �������� ������� � ������� �����
    movsd XMM0, qword ptr [cur_x]
    call Left_Rectangle

    ; ���������� ����������
    movsd XMM1, qword ptr [res]       ; ��������� res � XMM1
    addsd XMM1, XMM0                  ; XMM1 = res + Left_Rectangle(cur_x)
    movsd qword ptr [res], XMM1       ; res = XMM1

    ; ������� � ��������� �����
    movsd XMM1, qword ptr [cur_x]
    addsd XMM1, qword ptr [h]         ; cur_x = cur_x + h
    movsd qword ptr [cur_x], XMM1

    loop while_n

    ; �������� ��������� �� ��� h ��� ���������� ������ ���������������
    movsd XMM0, qword ptr [res]
    mulsd XMM0, qword ptr [h]         ; res = res * h

    ; ���������� ���������
    ret

Calculate_Integral endp

;------------------------------------------------------------------------

end