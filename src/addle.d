/++
Argument-dependent lookup for extension methods.

`addle` lets you extend types with UFCS methods, and share those methods
seamlessly with code in other modules.

License: MIT
Authors: Paul Backus
+/
module addle;

version(none)
/// $(H3 Adding range primitives to a type)
unittest {
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
}

import std.traits: moduleName;

// Inline import
private template from(string module_)
{
	mixin("import from = ", module_, ";");
}

/**
 * Extends a method to include UFCS functions in the calling context.
 *
 * When calling an extended method of an object, the following locations are
 * searched, in order, for a method or UFCS function with the given name:
 *
 * $(NUMBERED_LIST
 *   * The object itself.
 *   * The module where the object's type is defined.
 *   * The `context` module (by default, the module that contains the
 *     extended method call).
 * )
 *
 * If no method or function is found, a compile-time error is generated.
 *
 * Params:
 *   method = the name of the method to call
 *   context = the name of the module to search for extended methods
 */
template extendedMethod(string method, string context = __MODULE__)
{
	/**
	 * Calls the extended method.
	 *
	 * Params:
	 *   obj = the object whose extended method is being called
	 *   args = arguments to the extended method
	 *
	 * Returns: the return value of the extended method.
	 */
	auto ref extendedMethod(T, Args...)(auto ref T obj, auto ref Args args)
	{
		import core.lifetime: forward;

		static if (__traits(compiles, mixin("obj.", method, "(forward!args)"))) {
			// Normal method
			return mixin("obj.", method, "(forward!args)");
		} else static if (__traits(compiles,
			__traits(getMember, from!(moduleName!T), method)(forward!(obj, args))
		)) {
			// UFCS method from defining module
			return __traits(getMember, from!(moduleName!T), method)(forward!(obj, args));
		} else static if (__traits(compiles,
			__traits(getMember, from!context, method)(forward!(obj, args)),
		)) {
			// UFCS method from extending module
			return __traits(getMember, from!context, method)(forward!(obj, args));
		} else {
			import std.traits: fullyQualifiedName;

			static assert(false,
				"no extended method `" ~ method ~ "` found for type `"
				~ fullyQualifiedName!T ~ "` in module `" ~ context ~ "`"
			);
		}
	}
}

/**
 * A wrapper that allows [extendedMethod|extended methods] to be called as
 * though they were regular methods.
 *
 * Params:
 *   T = the type of the wrapped object.
 *   context = the `context` module to be used for extended method lookup.
 */
struct Extended(T, string context = __MODULE__)
{
	import std.meta: staticIndexOf;

	/// The wrapped object.
	T obj;

	/// Implicitly converts to the wrapped object.
	alias obj this;

	/**
	 * Forwards all method calls to [extendedMethod].
	 *
	 * Params:
	 *   args = arguments to pass to the extended method.
	 *
	 * Returns: the return value of the extended method
	 */
	auto ref opDispatch(string method, Args...)(auto ref Args args)
	{
		import core.lifetime: forward;

		return obj.extendedMethod!(method, context)(forward!args);
	}
}

/**
 * Creates an [Extended] wrapper around an object.
 */
template extended(string context = __MODULE__)
{
	///
	inout(Extended!(T, context)) extended(T)(auto ref inout(T) obj)
	{
		import core.lifetime: forward;

		return inout(Extended!(T, context))(obj);
	}
}
