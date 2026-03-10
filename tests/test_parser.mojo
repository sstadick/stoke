
from std.testing import assert_equal, assert_raises, assert_true, assert_false, TestSuite

from stoke.deserialize import JsonDeserializable, Opt 
from stoke.parser import Parser, ParseOptions


def test_limited() raises:
    comptime x: List[Int] = [1, 2, 3]
    comptime if conforms_to(type_of(x), JsonDeserializable):
        print("CONFORMS")


# Tests:
# - Missing values (and defaults)
# - Help messages
# - Long and short opts
# - Subcommands

# TODO: add comptime validation of opt_metadata to check for:
# - collisions of names, especially short opts,
# - verify defaults correctly deserialize,
# - validate keys to make sure they match struct fields
# - make sure there aren't more than one list of positional arguments
# TODO: add comptime check for opt_metadata raises and non-raises

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
struct CustomType(JsonDeserializable, Defaultable, Equatable, Writable):
    var first_name: String
    var last_name: String

    fn __init__(out self):
        self.first_name = "Darth"
        self.last_name = "Vadar"

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

def test_stoke_basic() raises :
    var parser = Parser([
        s("--my-flag"),
        s("--my-string"),
        s("blah"),
        s("--my-custom"),
        s("John"),
        s("Doe")
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))

def test_stoke_basic_short_opts() raises:
    var parser = Parser([
        s("-f"),
        s("-s"),
        s("blah"),
        s("--my-custom"),
        s("John"),
        s("Doe")
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))

def test_stoke_flag_default() raises :
    var parser = Parser([
        s("--my-string"),
        s("blah"),
        s("--my-custom"),
        s("John"),
        s("Doe")
    ])
    
    var args = Args.from_json(parser)

    assert_false(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))

def test_stoke_mixed_order() raises:
    var parser = Parser([
        s("--my-custom"),
        s("John"),
        s("Doe"),
        s("--my-string"),
        s("blah"),
        s("--my-flag"),
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))

def test_stoke_opt_helper_default() raises:
    var parser = Parser([
        s("--my-custom"),
        s("John"),
        s("Doe"),
        s("--my-flag"),
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "FooBar")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))

def test_stoke_defaultable_default() raises:
    var parser = Parser([
        s("--my-string"),
        s("blah"),
        s("--my-flag"),
    ])
    
    # Confirm it DOES NOT fall back to using defaultable
    with assert_raises(contains="Missing key"):
        var args = Args.from_json(parser)

def test_stoke_unexpected_value_after_flag() raises:
    var parser = Parser([
        s("--my-flag"),
        s("balls"),
        s("--my-string"),
        s("blah"),
        s("--my-custom"),
        s("John"),
        s("Doe")
    ])
    

    with assert_raises(contains="Can't parse positional argument"):
        var args = Args.from_json(parser)

def test_stoke_unexpected_value_after_opt() raises:
    var parser = Parser([
        s("--my-flag"),
        s("--my-string"),
        s("blah"),
        s("balls"),
        s("--my-custom"),
        s("John"),
        s("Doe")
    ])
    

    with assert_raises(contains="Can't parse positional argument"):
        var args = Args.from_json(parser)

def test_stoke_basic_positional_args() raises:
    var parser = Parser([
        s("--my-flag"),
        s("--my-string"),
        s("blah"),
        s("--my-custom"),
        s("John"),
        s("Doe"),
        s("42")
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))
    assert_equal(args.arg_one.value, 42)
    assert_equal(args.remaining_args.value, [42, 43])

def test_stoke_basic_positional_args_list() raises:
    var parser = Parser([
        s("--my-flag"),
        s("--my-string"),
        s("blah"),
        s("--my-custom"),
        s("John"),
        s("Doe"),
        s("42"),
        s("1"),
        s("2"),
        s("3"),
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))
    assert_equal(args.arg_one.value, 42)
    assert_equal(args.remaining_args.value, [1, 2, 3])

def test_stoke_jumbled_positional_args_list() raises:
    var parser = Parser([
        s("--my-flag"),
        s("42"),
        s("--my-string"),
        s("blah"),
        s("1"),
        s("2"),
        s("--my-custom"),
        s("John"),
        s("Doe"),
        s("3"),
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))
    assert_equal(args.arg_one.value, 42)
    assert_equal(args.remaining_args.value, [1, 2, 3])

def test_stoke_basic_repeated_opt_list() raises:
    var parser = Parser([
        s("--my-flag"),
        s("--my-string"),
        s("blah"),
        s("--my-custom"),
        s("John"),
        s("Doe"),
        s("-l"),
        s("5"),
        s("-l"),
        s("6"),
        s("-l"),
        s("7"),
        s("-l"),
        s("8"),
        s("42"),
        s("1"),
        s("2"),
        s("3"),
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))
    assert_equal(args.arg_one.value, 42)
    assert_equal(args.remaining_args.value, [1, 2, 3])
    assert_equal(args.opt_list.value, [5, 6, 7, 8])

def test_stoke_jumbled_repeated_opt_list() raises:
    var parser = Parser([
        s("--my-flag"),
        s("-l"),
        s("5"),
        s("--my-string"),
        s("blah"),
        s("-l"),
        s("6"),
        s("--my-custom"),
        s("John"),
        s("Doe"),
        s("-l"),
        s("7"),
        s("42"),
        s("1"),
        s("2"),
        s("3"),
        s("-l"),
        s("8"),
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))
    assert_equal(args.arg_one.value, 42)
    assert_equal(args.remaining_args.value, [1, 2, 3])
    assert_equal(args.opt_list.value, [5, 6, 7, 8])

def test_stoke_default_repeated_opt_list() raises:
    var parser = Parser([
        s("--my-flag"),
        s("--my-string"),
        s("blah"),
        s("--my-custom"),
        s("John"),
        s("Doe"),
        s("42"),
        s("1"),
        s("2"),
        s("3"),
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))
    assert_equal(args.arg_one.value, 42)
    assert_equal(args.remaining_args.value, [1, 2, 3])
    assert_equal(args.opt_list.value, [10,11,12])

def test_stoke_default_args_list() raises:
    var parser = Parser([
        s("--my-flag"),
        s("--my-string"),
        s("blah"),
        s("--my-custom"),
        s("John"),
        s("Doe"),
        s("42"),
    ])
    
    var args = Args.from_json(parser)

    assert_true(args.my_flag.value)
    assert_equal(args.my_string.value, "blah")
    assert_equal(args.my_custom.value, CustomType("John", "Doe"))
    assert_equal(args.arg_one.value, 42)
    assert_equal(args.remaining_args.value, [42, 43])
    assert_equal(args.opt_list.value, [10,11,12])

@fieldwise_init
struct ArgsBare(JsonDeserializable, Defaultable):
    var my_int: Int
    var complex: Opt[List[String], long="complex", short="c", default="cat,mouse,dog"]

    fn __init__(out self):
        self.my_int = Int()
        self.complex = {[]}
    
def test_bare_args() raises:
    var parser = Parser(["--my-int", "4", "--complex", "snake", "-c", "snail", "--complex", "cow"])
    var args = ArgsBare.from_json(parser)
    assert_equal(args.my_int, 4)
    assert_equal(args.complex.value, ["snake", "snail", "cow"])

def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
