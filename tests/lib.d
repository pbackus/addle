module lib;

struct A {}
struct B {}

bool empty(B b) { return false; }
char front(B b) { return 'b'; }
void popFront(B b) {}

struct C
{
	bool empty() { return false; }
	int front() { return 'c'; }
	void popFront() {}
}
