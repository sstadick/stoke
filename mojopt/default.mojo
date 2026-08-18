@always_inline
def reflection_default[T: Defaultable & Movable](out this: T):
    """Get a default instance of type `T` if all members conform to
    `Defaultable & Movable`.
    """
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(this))
    comptime r = reflect[T]
    comptime names = r.field_names()
    comptime types = r.field_types()
    comptime for i in range(names.length):
        comptime FieldType = types[i]
        comptime assert conforms_to(
            FieldType, Defaultable & Movable
        ), "All fields must conform to Defaultable & Movable"
        ref field = r.field_ref[i](this)
        comptime assert conforms_to(type_of(field), Defaultable & Movable)
        Pointer(to=field).unsafe_write(type_of(field)())
