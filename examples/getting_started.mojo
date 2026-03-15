# from mojopt import reflection_default, MojOptDeserializable, Opt, LoadExts
from mojopt.deserialize import MojOptDeserializable, Opt, LoadExts
from mojopt.default import reflection_default
from mojopt.parser import Parser

# Needed to force the loading of extensions
comptime Exts = LoadExts().FullConformance

@fieldwise_init
struct Args(MojOptDeserializable, Defaultable, Writable):
    var first_name: Opt[String, help="The users first name", long="first-name", short="f"]
    var last_name: String
    var languages: Opt[List[String], help="The languages the user speaks", is_arg=True]

    fn __init__(out self):
        self = reflection_default[Self]()


# def mojopt_main(var argv: List[String]) raises:
#     var args = Parser.parse[Args](argv^)
#     print(args)

# def main() raises:
#   MojOpt.register_commands[__functions_in_module()]().run()

# Note, you could aso run this like:
def main() raises:
    print("Start")
    var args = Parser.parse[Args]()
    print(args)