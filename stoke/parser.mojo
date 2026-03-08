from std.sys import argv

from stoke.deserialize import JsonDeserializable, _Base


struct ParseOptions(Equatable, TrivialRegisterPassable):
    comptime ParsingOptions: Int = 1
    """Indicates that we are parsing key-value paired options."""
    comptime ParsingArguments: Int = 2
    """Indicates that we are parsing non-key-value paired arguments."""
    comptime ParsingDefaults: Int = 3
    """Indicates that we are parsing user defined default values."""

    var parsing_mode: Int


    fn __init__(out self, *, parsing_mode: Int = Self.ParsingOptions):
        self.parsing_mode = parsing_mode


struct Parser[options: ParseOptions = ParseOptions()]:
    var cursor: Int
    var data: List[String]

    def __init__(out self):
        self.cursor = 0
        # Skip the first arg as it's the program name.
        self.data = [String(s) for s in argv()[1:]]

    def __init__(out self, var args: List[String]):
        self.cursor = 0
        self.data = args^
    
    @staticmethod
    def parse[T: JsonDeserializable & _Base]() raises -> T:
        var parser = Parser()
        return T.from_json(parser)

    @staticmethod
    def parse[T: JsonDeserializable & _Base](var args: List[String]) raises -> T:
        var parser = Parser(args^)
        return T.from_json(parser)


    def is_done(read self) -> Bool:
        return self.cursor == len(self.data)

    def _get_next(mut self) -> String:
        debug_assert(
            self.cursor < len(self.data),
            "Parser cursor has gone past end of data.",
        )
        var value = self.data[self.cursor]
        self.cursor += 1
        return value

    def read_string(mut self) -> String:
        # TODO: return ref
        return self._get_next()

    def read_bool(mut self) raises -> Bool:
        var value = self._get_next().lower()
        if value == "true" or value == "t":
            return True
        elif value == "false" or value == "f":
            return False
        else:
            raise Error("Expected bool, got: " + value)

    def read_int(mut self) raises -> Int:
        var value = self._get_next()
        return atol(value)

    @always_inline
    @classmethod
    def mark_initialized(s: Self):
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(s))
