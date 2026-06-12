//An even faster Fibonacci number computation tool
#include <stdio.h>

struct llpair { long long a; long long b; };
struct llpair fib_pair(int i) { //Gets F(i) and F(i+1)
	if (i < 0) {
		struct llpair p = fib_pair(-i-1);
		if (i%2)	{ long long tmp=p.b; p.b = -p.a; p.a=tmp; }
		else		{ long long tmp=p.a; p.a = -p.b; p.b=tmp; }
		return p;
	}
	if (i < 2) {
		struct llpair returnp = { //Yeah... I should have used a compound literal.
			.a = i, .b = 1 //Weird hack: For i=0, we get (0,1) and for i=1 we get (1,1)
		};
		return returnp;
	}
	if (i % 2) { //If i is odd
		struct llpair p = fib_pair((i+1)/2);
		struct llpair returnp = {
			.a = p.a*p.a + (p.b-p.a)*(p.b-p.a),
			.b = p.a * (2 * p.b - p.a)
		};
		return returnp;
	} else { //If i is even
		struct llpair p = fib_pair(i/2);
		struct llpair returnp = {
			.a = p.a * (2 * p.b - p.a),
			.b = p.a*p.a + p.b*p.b
		};
		return returnp;
	}
}

long long fib(int n) {
	struct llpair p = fib_pair(n-1);
	return p.b;
}

int main(int argc, char **argv) {
	int a;
	sscanf(argv[1], "%d", &a);
	printf("%lld\n", fib(a));
	return 0;
}
