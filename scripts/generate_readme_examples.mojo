from std.subprocess import run

from mojopt.command import MojOpt, Commandable
from mojopt.default import reflection_default
from mojopt.deserialize import Opt


@fieldwise_init
struct ShowProgramAndHelp(Commandable, Defaultable, Movable, Writable):
    var program: Opt[String, help="The mojo program to compile and print help for"]
    var section_header: Opt[String, help="The secion header (markdown) for this example"]

    def __init__(out self):
        self = reflection_default[Self]()

    @staticmethod
    def description() -> String:
        return """Print the program code, followed by it's help."""

    def run(self) raises:
        var file_contents = open(self.program.value, "r").read()
        print(self.section_header.value)
        print()
        print(t"```mojo\n{file_contents}```")
        var help = run(String(t"pixi run mojo run -I . {self.program.value} --help"))
        print(t"```bash\n{help}```\n")


def main() raises:
    MojOpt[ShowProgramAndHelp]().run()
