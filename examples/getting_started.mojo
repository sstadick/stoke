# from mojopt import reflection_default, MojOptDeserializable, Opt, LoadExts
from mojopt.command import MojOpt, Commandable
from mojopt.default import reflection_default
from mojopt.deserialize import MojOptDeserializable, Opt, LoadExts
from mojopt.parser import Parser

# Needed to force the loading of extensions
comptime Exts = LoadExts().FullConformance

@fieldwise_init
struct Args(MojOptDeserializable, Defaultable, Writable, Commandable):
    var first_name: Opt[String, help="The users first name", long="first-name", short="f"]
    var last_name: String
    # var languages: Opt[List[String], help="The languages the user speaks", is_arg=True]
    var numbers: Opt[List[Int], help="The languages the user speaks", is_arg=True]

    fn __init__(out self):
        self = reflection_default[Self]()
    
    @staticmethod
    fn description() -> String:
        return """A small example program.
        
        This program demonstrates how to use the Opt type, as well as Commandable.
        """
    
    fn run(self) raises:
        print(self)
    

def main() raises:
    MojOpt[Args]().run()

# Note, you could aso run this like:
# def main() raises:
#     var args = Parser.parse[Args]()
#     print(args)

# TODO: raise a typed error when --help is hit, or when there are missing keys, etc / handle an print help and exit gracefully