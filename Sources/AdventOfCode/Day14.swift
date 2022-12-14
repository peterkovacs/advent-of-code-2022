import ArgumentParser
import Parsing

fileprivate let parser =
    Many {
        Parse(Coordinate.init) {
            Int.parser()
            ","
            Int.parser()
        }
    } separator: {
        " -> "
    } terminator: {
        End()
    }

extension InfiniteGrid where Element == Character? {
    mutating func populate(with lines: [[Coordinate]]) {
        for rocks in lines {
            for (from, to) in zip(rocks, rocks.dropFirst()) {
                let direction = from.direction(to: to)
                var from = from
                self[from] = "#"
                repeat {
                    from = from[keyPath: direction]
                    self[from] = "#"
                } while from != to
            }
        }
    }
    
    mutating func addSand(at coord: Coordinate) -> Bool {
        guard coord.isValid(minX: minX, x: maxX, minY: minY, y: maxY) else { return false }
        
        if (self[coord.down] == nil) {
            return addSand(at: coord.down)
        } else if (self[coord.down.left] == nil) {
            return addSand(at: coord.down.left)
        } else if (self[coord.down.right] == nil) {
            return addSand(at: coord.down.right)
        } else {
            self[coord] = "o"
            return true
        }
    }
}

struct Day14: ParsableCommand {
    func part1(rocks: [[Coordinate]]) {
        var grid = InfiniteGrid<Character?>([], minX: 500, minY: 0, maxX: 501, maxY: 1, defaultValue: nil)
        grid.populate(with: rocks)
        grid[.init(x: 500, y: 0)] = "+"
        
        for i in 0... {
            guard grid.addSand(at: .init(x: 500, y: 0)) else {
                print("part 1", i)
                break
            }
        }
    }
    
    func part2(rocks: [[Coordinate]]) {
        var grid = InfiniteGrid<Character?>([], minX: 500, minY: 0, maxX: 501, maxY: 1, defaultValue: nil)
        grid.populate(with: rocks)
        grid.populate(with: [[Coordinate(x: -10000, y: grid.maxY + 1), Coordinate(x: 10000, y: grid.maxY + 1)]])
            
        let source = Coordinate(x: 500, y: 0)
        for i in 0... {
            guard grid[source] == nil else {
                print("part 2", i)
                break
            }
            
            _ = grid.addSand(at: .init(x: 500, y: 0))
        }
    }
    
    func run() throws {
        let rocks = try stdin.map { try parser.parse($0) }
        part1(rocks: rocks)
        part2(rocks: rocks)
    }
}
