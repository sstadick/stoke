
from mojopt.deserialize import MojOptDeserializable, Opt, LoadExts
from mojopt.parser import Parser, ParseOptions
from mojopt.subcommand import Commandable
from mojopt import MojOpt

from examples.mod import *

# Needed to force loading Exts
comptime Ext = LoadExts.FullConformance

@fieldwise_init
struct GetLanguages(MojOptDeserializable, Defaultable, Writable, Commandable):
    var first_name: Opt[String, help="First name"]
    var last_name: Opt[String, help="Last name"]
    var languages: Opt[List[String], is_arg=True, help="Languages spoken"]

    # TODO: contribute default implementation to Defaultable that works like Rust Default
    # We shouldn't have to fill this out by hand.
    fn __init__(out self):
        self.first_name = {""}
        self.last_name = {""}
        self.languages = {[]}

    @staticmethod
    fn description() -> String:
        return "List the languages spoken."

    def run(self) raises:
        print(self)

@fieldwise_init
struct GetSports(MojOptDeserializable, Defaultable, Writable, Commandable):
    var first_name: Opt[String, help="First name"]
    var last_name: Opt[String, help="Last name"]
    var sports: Opt[List[String], is_arg=True, help="Sports played"]

    fn __init__(out self):
        self.first_name = {""}
        self.last_name = {""}
        self.sports = {[]}
    
    @staticmethod
    fn description() -> String:
        return "List the sports played."
    
    def run(self) raises:
        print(self)
    
@fieldwise_init
struct Main(MojOptDeserializable, Defaultable, Writable, Commandable):
    var example: Opt[String]
    var number: Opt[Int]

    fn __init__(out self):
        self.example = {""}
        self.number = {0}

    @staticmethod
    fn description() -> String:
        return "Classic Main."

    def run(self) raises:
        print(self)

def main() raises:
    MojOpt[GetLanguages, GetSports, Main]().run()
