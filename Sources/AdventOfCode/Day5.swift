import ArgumentParser
import Parsing

fileprivate let letter = Parse {
    "["
    Prefix(1)
    "]"
}.map(\.first)
fileprivate let noLetter = Parse { "   " }.map { nil as Character? }
fileprivate let stackLine = Many {
    OneOf {
        letter
        noLetter
    }
} separator: {
    " "
}

fileprivate let moveLine = Parse {
    "move "
    Int.parser()
    " from "
    Int.parser()
    " to "
    Int.parser()
}
fileprivate let stacks = Many {
    stackLine
} separator: {
    "\n"
}.map {
    $0.reversed().reduce(
        into: Array(
            repeating: Array<Character>(),
            count: $0[0].count
        )
    ) { result, line in
        for (i, c) in line.indexed() {
            if let c {
                result[i].append(c)
            }
        }
    }
}


fileprivate let parser = Parse {
    stacks

    " 1   2   3   4   5   6   7   8   9 \n"
    "\n"

    Many {
        moveLine
    } separator: {
        "\n"
    } terminator: {
        "\n"
    }
}

struct Day5: ParsableCommand {
    
    func part1(stacks: [[Character]], commands: [(Int, Int, Int)]) {
        var stacks = stacks

        for (count, from, to) in commands {
            let size = stacks[from - 1].count
            let moving = stacks[from - 1][ (size - count)... ].reversed()
            stacks[to - 1].append(contentsOf: moving)
            stacks[from - 1].removeLast(count)
        }

        print("part 1", stacks.compactMap(\.last).map(String.init).joined())
    }
    func part2(stacks: [[Character]], commands: [(Int, Int, Int)]) {
        var stacks = stacks

        for (count, from, to) in commands {
            let size = stacks[from - 1].count
            let moving = stacks[from - 1][ (size - count)... ]
            stacks[to - 1].append(contentsOf: moving)
            stacks[from - 1].removeLast(count)
        }

        print("part 2", stacks.compactMap(\.last).map(String.init).joined())
    }

    func run() throws {
        let (stacks, commands) = try parser.parse(allInput)
        part1(stacks: stacks, commands: commands)
        part2(stacks: stacks, commands: commands)

    }
}
