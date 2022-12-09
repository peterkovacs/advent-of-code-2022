import ArgumentParser
import Parsing

fileprivate var parser = Many {
    OneOf {
        Parse { "D "; Int.parser() }.map { (\Coordinate.down, $0) }
        Parse { "U "; Int.parser() }.map { (\Coordinate.up, $0) }
        Parse { "L "; Int.parser() }.map { (\Coordinate.left, $0) }
        Parse { "R "; Int.parser() }.map { (\Coordinate.right, $0) }
    }
} separator: {
    Whitespace(.vertical)
} terminator: {
    Whitespace(.vertical)
    End()
}

fileprivate let translations = [
    Coordinate(x: -2, y:  0): Coordinate(x: -1, y:  0),
    Coordinate(x: -2, y: -1): Coordinate(x: -1, y: -1),
    Coordinate(x: -2, y: -2): Coordinate(x: -1, y: -1),
    Coordinate(x: -1, y: -2): Coordinate(x: -1, y: -1),
    Coordinate(x:  0, y: -2): Coordinate(x:  0, y: -1),
    Coordinate(x:  1, y: -2): Coordinate(x:  1, y: -1),
    Coordinate(x:  2, y: -2): Coordinate(x:  1, y: -1),
    Coordinate(x:  2, y: -1): Coordinate(x:  1, y: -1),
    Coordinate(x:  2, y:  0): Coordinate(x:  1, y:  0),
    Coordinate(x:  2, y:  1): Coordinate(x:  1, y:  1),
    Coordinate(x:  2, y:  2): Coordinate(x:  1, y:  1),
    Coordinate(x:  1, y:  2): Coordinate(x:  1, y:  1),
    Coordinate(x:  0, y:  2): Coordinate(x:  0, y:  1),
    Coordinate(x: -1, y:  2): Coordinate(x: -1, y:  1),
    Coordinate(x: -2, y:  2): Coordinate(x: -1, y:  1),
    Coordinate(x: -2, y:  1): Coordinate(x: -1, y:  1),
]

struct Day9: ParsableCommand {
    func part1(input: [(KeyPath<Coordinate, Coordinate>, Int)]) {
        var grid = InfiniteGrid([true], minX: 0, minY: 0, maxX: 1, maxY: 1, defaultValue: false)
        var head = Coordinate.zero
        var tail = Coordinate.zero

        for (direction, count) in input {
            for _ in 0..<count {
                defer { grid[tail] = true }
                head = head[keyPath: direction]
                if let translation = translations[head - tail] {
                    tail = tail + translation
                }
            }
        }
        
        print("part 1", grid.filter { $0 }.count)
    }
    
    func part2(input: [(KeyPath<Coordinate, Coordinate>, Int)]) {
        var grid = InfiniteGrid([false], minX: 0, minY: 0, maxX: 1, maxY: 1, defaultValue: false)
        var knots = Array(repeating: Coordinate.zero, count: 10)
        for (direction, count) in input {
            for _ in 0..<count {
                defer { grid[knots.last!] = true }
                knots[0] = knots[0][keyPath: direction]
                
                for (head, tail) in zip(knots.indices, knots.indices.dropFirst()) {
                    let (h, t) = (knots[head], knots[tail])
                    if let translation = translations[ h - t ] {
                        knots[tail] = t + translation
                    } else { break }
                }
            }
        }
        
        print("part 2", grid.filter { $0 }.count)
    }
    
    func run() throws {
        let input = try parser.parse(allInput)
        part1(input: input)
        part2(input: input)
    }
}
