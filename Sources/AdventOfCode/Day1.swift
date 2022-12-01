import ArgumentParser
import Algorithms

struct Day1: ParsableCommand {
    
    func run() {
        let calories = stdin
            .joined(separator: "\n")
            .split(separator: #/\n\n/#)
            .map {
                $0.split(separator: #/\n/#)
                    .compactMap { Int(String($0)) }
                    .reduce(0, +)
            }

        print("Part 1:", calories.max() as Any)

        print("Part 2:", calories.max(count: 3).reduce(0, +))
    }
}
