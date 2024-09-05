#include <iostream>

extern "C" double Left_Rectangle(double x);
extern "C" double Calculate_Integral(int n);

int main()
{
	int n = 10000000000;

	std::cout << Calculate_Integral(n);
}