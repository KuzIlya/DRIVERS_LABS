#include <iostream>
using namespace std;


extern "C" double Calculate_Func(double a, double x);

int main()
{
	double a = 1.0;
	double x = 0.1;

	cout << Calculate_Func(a, x);

}