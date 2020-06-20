addle
=====

Argument-dependent lookup for extension methods.

`addle` lets you extend types with UFCS methods, and share those methods
seamlessly with code in other modules.

Example
-------

    module lib;

    // No methods
    struct A {}

    // UFCS methods
    struct B {}
    bool empty(B b) { return false; }
    char front(B b) { return 'b'; }
    void popFront(B b) {}

    // Normal methods
    struct C
    {
        bool empty() { return false; }
        int front() { return 'c'; }
        void popFront() {}
    }

    ---

    module example;

    import addle;
    import lib: A, B, C;

    // Can extend types from other modules
    bool empty(A a) { return false; }
    char front(A a) { return 'a'; }
    void popFront(A a) {}

    // ...but can't hijack existing methods
    char front(C c) { return 'x'; }

    unittest {
        import std.range: take, only;
        import std.algorithm: equal;

        A a;
        assert(a.extended.take(3).equal(only('a', 'a', 'a')));

        B b;
        assert(b.extended.take(3).equal(only('b', 'b', 'b')));

        C c;
        assert(c.extended.take(3).equal(only('c', 'c', 'c')));
    }
