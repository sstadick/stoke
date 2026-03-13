from stoke.deserialize import JsonDeserializable, Optable

from std.reflection import (
    struct_field_count,
    struct_field_types,
    struct_field_names,
    is_struct_type,
    get_base_type_name,
)
from std.builtin.rebind import downcast


fn get_help[T: JsonDeserializable]() -> String:
    comptime field_names = struct_field_names[T]()
    comptime field_types = struct_field_types[T]()

    var options: List[String] = []
    var arguments: List[String] = []
    var description = "\n".join([line.lstrip() for line in T.description().splitlines()])

    comptime for i in range(0, len(field_names)):
        comptime field_type = field_types[i]
        comptime field_name = field_names[i]
        comptime type_name = get_base_type_name[field_type]()

        comptime if conforms_to(field_types[i], Optable):
            comptime optlike = downcast[field_types[i], Optable]
            comptime short_name = t"-{optlike.opt_short.value()}, " if optlike.opt_short else ""
            comptime long_name = t"{optlike.opt_long.value()}" if optlike.opt_long else String(t"{field_name}")
            comptime default = t" [default: {optlike.opt_default.value()}]" if optlike.opt_default else ""
            comptime appendable = "..." if optlike.opt_is_appendable else ""
            comptime fixed_help = optlike.opt_help.replace("\n", "          \n")
            comptime desc_line = t"          {fixed_help}"

            comptime if optlike.opt_is_arg:
                comptime details_line = t"  [{long_name.upper()}]{appendable}{default}\n"
                arguments.append(materialize[String(details_line) + String(desc_line)]())
            else:
                comptime details_line = t"  {short_name}--{long_name} <{long_name.upper()}>{appendable}{default}\n"
                options.append(materialize[String(details_line) + String(desc_line)]())
        else:
            comptime long_name = t"  --{field_name} <{field_name.upper()}>"
            options.append(materialize[long_name]())

    var final_list = [description]
    if len(arguments) > 0:
        final_list.append("Arguments:")
        final_list.append("\n".join(arguments))

    if len(options) > 0:
        final_list.append("Options:")
        final_list.append("\n".join(options))

    var final = "\n".join(final_list)
    return final