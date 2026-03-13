
from stoke.deserialize import JsonDeserializable, Opt, LoadExts
from stoke.parser import Parser, ParseOptions
from stoke import Stoke

from examples.mod import *

# Needed to force loading Exts
comptime Ext = LoadExts.FullConformance

@fieldwise_init
struct GetLanguages(JsonDeserializable, Defaultable, Writable):
    var first_name: Opt[String, help="First name"]
    var last_name: Opt[String, help="Last name"]
    var languages: Opt[List[String], is_arg=True, help="Languages spoken"]

    # TODO: contribute default implementation to Defaultable that works like Rust Default
    # We shouldn't have to fill this out by hand.
    fn __init__(out self):
        self.first_name = {""}
        self.last_name = {""}
        self.languages = {[]}

@fieldwise_init
struct GetSports(JsonDeserializable, Defaultable, Writable):
    var first_name: Opt[String, help="First name"]
    var last_name: Opt[String, help="Last name"]
    var sports: Opt[List[String], is_arg=True, help="Sports played"]

    # TODO: contribute default implementation to Defaultable that works like Rust Default
    # We shouldn't have to fill this out by hand.
    fn __init__(out self):
        self.first_name = {""}
        self.last_name = {""}
        self.sports = {[]}
    
@fieldwise_init
struct Main(JsonDeserializable, Defaultable, Writable):
    var example: Opt[String]
    var number: Opt[Int]

    fn __init__(out self):
        self.example = {""}
        self.number = {0}


def stoke_get_languages(var argv: List[String]) raises:
    """Runs when the get-languages subcommand is passed in."""
    var args = Parser.parse[GetLanguages](argv^)
    print(args)

def stoke_get_sports(var argv: List[String]) raises:
    """Runs when the get-sports subcommand is passed in."""
    var args = Parser.parse[GetSports](argv^)
    print(args)

def stoke_main(var argv: List[String]) raises:
    """Runs when no subcommand is passed in."""
    var args = Parser.parse[Main](argv^)
    print(args)

def main() raises:
    Stoke.register_commands[__functions_in_module()]().run()
