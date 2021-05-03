#include <iostream>
#include <string>

//This is a comment
/*This is also a c

omment 
*/



using namespace std;

// int call(){
// 	int a,b;
// }

// int anothercall(int a=2,float b=2,char c){
// 	//inr a;
// 	return a;
// }


// int anothercall2(int a,float b){

// }

// void anothercall1();

int main() {

	cout << "hi";

	int a = 10,c, b = 20 ;			//multiple declaration
	int d = 30,e = 40,f;
	// int e = 50;
	f = 2;							// assignment after declaration

	// g = 4;							// assignment before declaration

	float g = 2.3;					//different datatypes					
	char h = 'k';
	string i = "hi";

	int m = a+(b*d)/e-f;					//expression evaluation
	cout << "Value of m:" << m << endl; 	// cout 
	cout << 2+3 << " " <<  g;	
	// cout << t;								// undeclared variable

	cin >> a >> b;			// cin 
	cin >> c;

	// a = 2     // no semicolon

	float n = a+10.3;					// type casting
	int o = a+10.3;

	int p = a > b ? a*b : (a/b);
	a = a < b ? (b-a): a+b;					// Ternary Operator assignment and declaration

	int arr0[5];						//Array declaration
	int arr1[3] = {3,4};
	int arr2[] = {1,2,3};				
	//int arr3[2] = {1,2,3,4};		//Error 

	arr0[0] = 357;				//Accesing Array elements
	arr1[1] = 397;
	int q = arr2[2];
	// int r = arr2[5]; 			//Error
	// arr2[5] = 5;

	int pos_inc = a++;				//increment operators
	int pos_dec = b--;
	int pre_inc = ++b;
	int pre_dec = --a;

	a+2;		// grammar accepted

	anothercall();		//Function calls
	anothercall2(2,3);


	while(a != f && a){   // while and if-else constructs
		a--;
		if(a==2){
			while(1);
		}
		else if (d != a && b > a)
		{
			cout << a;
		}
		// else{
		// 	while(a==1);
		// }
		// if(a==2){
		// 	while(1);
		// }
		// else if(d != a && b > a)
		// {
		// 	cout << a;
		// }
		// else{
		// 	while(a==1);
		// }
	}
	return 0;		//grammar accepted
}