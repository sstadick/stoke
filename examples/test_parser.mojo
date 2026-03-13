
from std.testing import assert_equal, assert_raises, assert_true, assert_false, TestSuite

from stoke.deserialize import JsonDeserializable, Opt 
from stoke.parser import Parser, ParseOptions
from stoke.help import get_help

from stoke.ext import *

def test_limited() raises:
    comptime x: List[Int] = [1, 2, 3]
    comptime if conforms_to(type_of(x), JsonDeserializable):
        print("CONFORMS")


# Tests:
# - Missing values (and defaults)
# - Help messages
# - Long and short opts
# - Subcommands

# TODO: help message
# TODO: baked in support for set type opts and args
# TODO: Feature that allows for an argument list to be passed in via a file
# TODO: check if importing a fn makes it in scope for __functions_in_module

@fieldwise_init
struct Args(JsonDeserializable, Defaultable):
    var my_flag: Opt[Bool, help="It's mine", default="False", short="f"]
    var my_string: Opt[String, help="Also mine", default="FooBar", short="s"]
    var my_custom: Opt[CustomType, help="Very custom"]
    var opt_list: Opt[List[Int], help="Repeatable option", default="10,11,12", short="l"]
    var arg_one: Opt[Int, help="First positional arg", is_arg=True, default="99"]
    var remaining_args: Opt[List[Int], help="Remaining args", is_arg=True, default="42,43"]

    fn __init__(out self):
        self.my_flag = {False}
        self.my_string = {"bar"}
        self.my_custom = {CustomType()}
        self.opt_list = {[]}
        self.arg_one = {1}
        self.remaining_args = {[]}
    

@fieldwise_init
struct CustomType(JsonDeserializable, Defaultable, Equatable, Writable, Copyable):
    var first_name: String
    var last_name: String

    fn __init__(out self):
        self.first_name = "Darth"
        self.last_name = "Vadar"
    
    @implicit
    fn __init__[
        help: String,
        default: Optional[String],
        long: Optional[String],
        short: Optional[String],
        is_arg: Bool
    ](out self, opt: Opt[Self, help, default, long, short, is_arg]):
        self = opt.value.copy()

    @staticmethod
    fn from_json[
        options: ParseOptions, //
    ](mut p: Parser[options], out s: Self) raises:
        # __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(s))
        s = Self()
        s.first_name = p.read_string()
        s.last_name = p.read_string()


fn s(string_literal: StringLiteral) -> StaticString:
    return StaticString(string_literal)

@fieldwise_init
struct ArgsBare(JsonDeserializable, Defaultable):
    var my_int: Int
    var complex: Opt[List[String], help="This is a complex one", long="complex", short="c", default="cat,mouse,dog"]

    fn __init__(out self):
        self.my_int = Int()
        self.complex = {[]}

    @staticmethod
    fn description() -> String:
        return """Just a simple example program.

        What could possibly go wrong?
        """
    
def test_bare_args() raises:
    var parser = Parser(["--my-int", "4", "--complex", "snake", "-c", "snail", "--complex", "cow"])
    var args = ArgsBare.from_json(parser)
    assert_equal(args.my_int, 4)
    assert_equal(args.complex.value, ["snake", "snail", "cow"])

def main() raises:
    # TestSuite.discover_tests[__functions_in_module()]().run()
    test_bare_args()
