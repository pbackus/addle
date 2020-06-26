addle
=====

Argument-dependent lookup for extension methods.

`addle` lets you extend types with UFCS methods, and share those methods
seamlessly with code in other modules.

Documentation
-------------

[View online on `dpldocs.info`.][docs]

`addle` uses [adrdox][] to generate its documentation. To build your own copy,
run the following command from the root of the `addle` repository:

    path/to/adrdox/doc2 --genSearchIndex --genSource -o generated-docs src

[docs]: https://addle.dpldocs.info/addle.html
[adrdox]: https://github.com/adamdruppe/adrdox

Example
-------

    import addle;
    import std.range;

    // Import a type from another module
    import mylib: MyStruct;

    // Define range primitives for MyStruct
    bool empty(MyStruct a) { return false; }
    string front(MyStruct a) { return "ok"; }
    void popFront(MyStruct a) {}

    // MyStruct isn't considered an input range, because
    // std.range can't see our UFCS methods.
    static assert(isInputRange!MyStruct == false);

    // ...but extending it makes those methods visible.
    static assert(isInputRange!(Extended!MyStruct));

    void main()
    {
        import std.range: take, only;
        import std.algorithm: equal;

        MyStruct myStruct;

        // Now we can use all of the standard range algorithms
        assert(
            myStruct.extended
            .take(3)
            .equal(only("ok", "ok", "ok"))
        );
    }

Installation
------------

If you're using dub, add the [addle](https://code.dlang.org/packages/addle)
package to your project as a dependency.

Alternatively, since it's a single, self-contained module, you can simply copy
`addle.d` to your source directory and compile as usual.
