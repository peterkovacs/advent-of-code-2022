import ArgumentParser
import Algorithms

fileprivate typealias Rule = (Coordinate, InfiniteGrid<Character>) -> Coordinate?


fileprivate extension InfiniteGrid where Element == Character {
    var rules: CycledSequence<[Rule]> {
        [
            { 
                if $1[$0.up] == "." && $1[$0.up.right] == "." && $1[$0.up.left] == "." {
                    return $0.up
                } else { return nil }
            } as Rule,
            
            { 
                if $1[$0.down] == "." && $1[$0.down.right] == "." && $1[$0.down.left] == "." {
                    return $0.down
                } else { return nil }
            },
            
            { 
                if $1[$0.left] == "." && $1[$0.left.up] == "." && $1[$0.left.down] == "." {
                    return $0.left
                } else { return nil }
            },
            
            { 
                if $1[$0.right] == "." && $1[$0.right.up] == "." && $1[$0.right.down] == "." {
                    return $0.right
                } else { return nil }
            }
        ].cycled()
    }

    func next(index: Int) -> Self? {
        // If there is no Elf in the N, NE, or NW adjacent positions, the Elf proposes moving north one step.
        // If there is no Elf in the S, SE, or SW adjacent positions, the Elf proposes moving south one step.
        // If there is no Elf in the W, NW, or SW adjacent positions, the Elf proposes moving west one step.
        // If there is no Elf in the E, NE, or SE adjacent positions, the Elf proposes moving east one step.
        let rules = self.rules.dropFirst(index).prefix(4)
        let proposed = indices()
            .filter { self[$0] == "#" }
            .reduce(into: [:] as [Coordinate: [Coordinate]]) { result, from in
                guard from.neighbors8.map({ self[$0] }).contains("#") else { return }
                
                if let to = rules.compactMap({ $0(from, self) }).first {
                    result[to, default: .init()].append(from)
                }
            }
            .filter { $0.value.count == 1 }
        
        if proposed.isEmpty { return nil }
        
        var result = self
        for (to, from) in proposed {
            result[from[0]] = "."
            result[to] = "#"
        }
        return result
    }
    
    func shrink() -> Self {
        let elfs = self.indices().filter { self[$0] == "#" }
        let (minX, maxX) = elfs.map(\.x).minAndMax()!
        let (minY, maxY) = elfs.map(\.y).minAndMax()!

        var result = self
        result.setBounds(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
        return result
    }
}

struct Day23: ParsableCommand {
    func run() {
        let input = Array(stdin)
        let grid = InfiniteGrid(input.joined(), maxX: input[0].count, defaultValue: "." as Character)
        
        let part1 = (0..<10)
            .reduce(into: grid) { grid, i in 
                grid = grid.next(index: i) ?? grid
            }
            .shrink()
            .lazy
            .filter { $0 == "." }
            .count
        
        print("part 1", part1)
        
        var part2 = grid
        for i in 0... {
            if let result = part2.next(index: i) {
                part2 = result
            } else {
                print("part 2", i + 1)
                break
            }
        }
    }
}
