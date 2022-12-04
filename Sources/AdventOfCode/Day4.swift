import ArgumentParser
import Parsing

struct Day4: ParsableCommand {
    static let parser = Parse {
        Parse(ClosedRange.init(uncheckedBounds:)) {
            Int.parser()
            "-"
            Int.parser()
        }
        ","
        Parse(ClosedRange.init(uncheckedBounds:)) {
            Int.parser()
            "-"
            Int.parser()
        }
    }
    
    func run() throws {
        let input = try stdin.map { try Self.parser.parse($0) }
        
        let part1 = input.filter {
            ($0.0.contains($0.1.lowerBound) && $0.0.contains($0.1.upperBound)) ||
            ($0.1.contains($0.0.lowerBound) && $0.1.contains($0.0.upperBound))
        }.count
        
        print("part1", part1)
        
        let part2 = input.filter {
            $0.0.contains($0.1.lowerBound) || $0.0.contains($0.1.upperBound) ||
            $0.1.contains($0.0.lowerBound) || $0.1.contains($0.0.upperBound)
        }.count
        
        print("part2", part2)
    }
}
