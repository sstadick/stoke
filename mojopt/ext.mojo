from std.builtin.rebind import downcast

from mojopt.deserialize import Opt


__extension String:
    @implicit
    def __init__[
        default_value_length: Int,
        //,
        help: String,
        default_value: Optional[Array[String, default_value_length]],
        defaultable: Bool,
        long: Optional[String],
        short: Optional[String],
        is_arg: Bool,
    ](
        out self,
        opt: Opt[
            default_value_length=default_value_length,
            T=String,
            help=help,
            default_value=default_value,
            defaultable=defaultable,
            long=long,
            short=short,
            is_arg=is_arg,
        ],
    ):
        self = opt.value


__extension SIMD:
    @implicit
    def __init__[
        default_value_length: Int,
        //,
        help: String,
        default_value: Optional[Array[String, default_value_length]],
        defaultable: Bool,
        long: Optional[String],
        short: Optional[String],
        is_arg: Bool,
    ](
        out self,
        opt: Opt[
            default_value_length=default_value_length,
            T=Self,
            help=help,
            default_value=default_value,
            defaultable=defaultable,
            long=long,
            short=short,
            is_arg=is_arg,
        ],
    ):
        self = opt.value


__extension Bool:
    @implicit
    def __init__[
        default_value_length: Int,
        //,
        help: String,
        default_value: Optional[Array[String, default_value_length]],
        defaultable: Bool,
        long: Optional[String],
        short: Optional[String],
        is_arg: Bool,
    ](
        out self,
        opt: Opt[
            default_value_length=default_value_length,
            T=Bool,
            help=help,
            default_value=default_value,
            defaultable=defaultable,
            long=long,
            short=short,
            is_arg=is_arg,
        ],
    ):
        self = opt.value


__extension List:
    @implicit
    def __init__[
        default_value_length: Int,
        //,
        help: String,
        default_value: Optional[Array[String, default_value_length]],
        defaultable: Bool,
        long: Optional[String],
        short: Optional[String],
        is_arg: Bool,
    ](
        out self: List[Self.T],
        opt: Opt[
            default_value_length=default_value_length,
            T=List[downcast[Self.T, Copyable & Deinitable]],
            help=help,
            default_value=default_value,
            defaultable=defaultable,
            long=long,
            short=short,
            is_arg=is_arg,
        ],
    ):
        self = rebind_var[Self](opt.value.copy())
