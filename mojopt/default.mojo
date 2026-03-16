from std.builtin.constrained import _constrained_field_conforms_to
from std.builtin.rebind import downcast
from std.reflection import (
    struct_field_names,
    struct_field_types,
)

@always_inline
fn reflection_default[T: Defaultable](out this: T):
    """Get a default instance of type `T` if all members of `T` conform to `Defaultable`."""
    __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(this))
    comptime names = struct_field_names[T]()
    comptime types = struct_field_types[T]()

    comptime for i in range(names.size):
        comptime FieldType = types[i]
        _constrained_field_conforms_to[
            conforms_to(FieldType, Defaultable),
            Parent=T,
            FieldIndex=i,
            ParentConformsTo="Defaultable"
        ]()
        ref field = __struct_field_ref(i, this)
        field = rebind[type_of(field)](downcast[FieldType, Defaultable]())