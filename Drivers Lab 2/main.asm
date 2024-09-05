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

    movsd qword ptr [x], XMM0       ; Сохранить входное значение в переменную x

    ; Проверяем, не равен ли x нулю
    pxor XMM1, XMM1                 ; XMM1 = 0.0
    ucomisd XMM0, XMM1              ; Сравниваем XMM0 и XMM1
    jne x_is_not_zero

    ; Если x == 0, добавляем tiny_num для предотвращения деления на ноль
    addsd XMM0, qword ptr [tiny_num]
    movsd qword ptr [x], XMM0

x_is_not_zero:

    ; Вычисляем выражение (sin(100 * x)) / x
    movsd XMM1, qword ptr [hundred] ; XMM1 = 100.0
    mulsd XMM1, XMM0                ; XMM1 = 100 * x
    movsd qword ptr [rect_res], XMM1 ; Сохранить XMM1 для использования FPU

    ; Преобразование через FPU для вычисления sin(100 * x)
    fld qword ptr [rect_res]        ; Загрузить значение в FPU стек
    fsin                            ; Вычисляем sin(100 * x)
    fstp qword ptr [rect_res]       ; Сохранить результат в rect_res

    ; Делим результат на x
    movsd XMM2, qword ptr [rect_res] ; Загружаем результат sin(100 * x) обратно в XMM2
    divsd XMM2, XMM0                ; XMM2 = sin(100 * x) / x

    ; Возвращаем результат в XMM0
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

    ; Инициализируем переменные
    mov n, ECX

    ; Вычисляем шаг h = (b - a) / n
    movsd XMM0, qword ptr [b]
    subsd XMM0, qword ptr [a]         ; XMM0 = b - a

    cvtsi2sd XMM1, n                  ; Преобразуем n в double и сохраняем в XMM1
    divsd XMM0, XMM1                  ; XMM0 = (b - a) / n
    movsd qword ptr [h], XMM0         ; Сохраняем h в памяти

    ; Инициализируем текущую позицию и результат
    pxor XMM0, XMM0                   ; XMM0 = 0.0 (инициализация нуля)
    movsd qword ptr [cur_x], XMM0     ; cur_x = 0.0

    pxor XMM0, XMM0                   ; XMM0 = 0.0 (инициализация нуля)
    movsd qword ptr [res], XMM0       ; res = 0.0

    ; Цикл интегрирования
    mov ECX, n
while_n:
    ; Вычисляем значение функции в текущей точке
    movsd XMM0, qword ptr [cur_x]
    call Left_Rectangle

    ; Накопление результата
    movsd XMM1, qword ptr [res]       ; Загрузить res в XMM1
    addsd XMM1, XMM0                  ; XMM1 = res + Left_Rectangle(cur_x)
    movsd qword ptr [res], XMM1       ; res = XMM1

    ; Переход к следующей точке
    movsd XMM1, qword ptr [cur_x]
    addsd XMM1, qword ptr [h]         ; cur_x = cur_x + h
    movsd qword ptr [cur_x], XMM1

    loop while_n

    ; Умножаем результат на шаг h для завершения метода прямоугольников
    movsd XMM0, qword ptr [res]
    mulsd XMM0, qword ptr [h]         ; res = res * h

    ; Возвращаем результат
    ret

Calculate_Integral endp

;------------------------------------------------------------------------

end