import stoke.deserialize
from stoke.deserialize import JsonDeserializable, Opt, LoadExts
from stoke.parser import Parser, ParseOptions
from stoke import Stoke

# Needed to force the loading of extensions
comptime Exts = LoadExts().FullConformance

@fieldwise_init
struct Args(JsonDeserializable, Defaultable, Writable):
    var first_name: Opt[String, help="The users first name", long="first-name", short="f"]
    var last_name: String
    var languages: Opt[List[String], help="The languages the user speaks", is_arg=True]

    # TODO: contribute default implementation to Defaultable that works like Rust Default
    # We shouldn't have to fill this out by hand.
    fn __init__(out self):
        self.first_name = {""}
        self.last_name = {""}
        self.languages = {[]}


def stoke_main(var argv: List[String]) raises:
    var args = Parser.parse[Args](argv^)
    print(args)

def main() raises:
    Stoke.register_commands[__functions_in_module()]().run()

# Note, you could aso run this like:
# def main() raises:
#     var args = Parser.parse[Args]()
#     print(args)