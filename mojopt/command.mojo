from mojopt.deserialize import MojOptDeserializable
from std.reflection import get_base_type_name

# TODO: make this work nicely so when only one command is passed in it can be "main"
# TODO: Parser should take a slice
# TODO: convert from PascalCase to kebab-case for subcommands? 

struct MojOpt[*CommandTypes: Commandable](Movable):
    var argv: List[String]

    fn __init__(out self):
        # TODO: probably hang onto the binary name later
        self.argv = [String(arg) for arg in argv()[1:]]

    fn __init__(out self, var argv: List[String]):
        self.argv = argv^
    
    def run(self) raises:
        if len(self.argv) == 0:
            raise Error("No arguments passed in")
        
        # TODO: we could maybe support the default Main still... if --help is passed in and
        # we have a Main, but no other subcommmand passed, print help for whole program and Main?

        comptime for i in range(Variadic.size(Self.CommandTypes)):
            if Self.CommandTypes[i].name == self.argv[0]:
                var args = Parser.parse[Self.CommandTypes[i]](List(self.argv))
                args.run()
        else:
            # TODO: Generate help message for the program commands
            comptime for i in range(Variadic.size(Self.CommandTypes)):
                print(Self.CommandTypes[i].name)
                print(Self.CommandTypes[i].description())

            raise Error(t"No matching command for {self.argv[0]}")


trait Commandable(MojOptDeserializable):
    comptime name: String = get_base_type_name[Self]()

    def run(self) raises: ...