#include <iostream>

using namespace std;

int main(){
    int a = 2,b=10;
    int k = 1;

    if(a < 2){
    	k = 4;
    }
    else{
    	k = 8;
    }

    int i = 2;
    int j = 10;

    while(i < j){
    	i = i+2;
    	j = j-1;
    	cout<<i;
    	cout<<j;
    }



    int c = (b/a)*a;  // Code Folding (Expression Evaluated)
    // code progation as all values are replaced before evaluation

    //(2+a) is replaced (common subexpression elimination)
    int d = (2+a)*(2+a);

    int m = (2*a);

    a = 5;

    int n = (2*a);  // (not replaced)



    return 1;
	
	//dead code is eliminated
    int z = 8;
    z = a*b;
    int z1 = (a-b)*(a+b);
    if(z==8){
    	z = 4;
    	cout << "this is dead code";
    }
    else{
    	z = 10;
    	cout << "this is also dead code";
    }
    z1 = z;

}