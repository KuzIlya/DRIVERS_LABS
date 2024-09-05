from ctypes import cdll, c_double, c_int

import matplotlib.pyplot as plt


mydll = cdll.LoadLibrary(r"C:\Users\user\Desktop\C++\Drivers Lab 2\main.dll")

my_func = mydll.Calculate_Integral
my_func.restype = c_double
my_func.argtypes = [c_int]

true_ans = 1.57

n_values = [10, 100, 1_000, 10_000, 100_000, 1_000_000]

errors = []

for n in n_values:
    result = my_func(n)
    error = abs(result - true_ans)
    errors.append(error)
    print(f"n = {n}, result = {result}, error = {error}")


plt.figure(figsize=(10, 6))
plt.plot(n_values, errors, marker='o')
plt.xscale('log')
plt.yscale('log')
plt.xlabel('n (количество разбиений)')
plt.ylabel('Абсолютная ошибка')
plt.title('Сходимость результата к истинному значению интеграла')
plt.grid(True)
plt.show()
