import ArgumentParser
import Foundation
import Parsing

fileprivate enum Signal: CustomStringConvertible, Comparable, Equatable {
    case integer(Int)
    indirect case list([Signal])

    static var parser: AnyParser<Substring, Signal> =
        OneOf {
            Int.parser().map(Signal.integer)
            Lazy { listParser }
        }
        .eraseToAnyParser()
    
    static var listParser = Parse(Signal.list) {
        "["
        Many {
            parser
        } separator: {
            ","
        }
        "]"
    }
    
    var description: String {
        switch self {
        case .integer(let int):
            return "\(int)"
        case .list(let array):
            return "[\(array.map(\.description).joined(separator: ","))]"
        }
    }
    
    static func compare(_ lhs: Signal, _ rhs: Signal) -> ComparisonResult {
        switch (lhs, rhs) {
        case let (.integer(a), .integer(b)):
            if a < b { return .orderedAscending }
            else if a > b { return .orderedDescending }
            else { return .orderedSame }
            
        case let (.list(a), .list(b)):
            // Compare the first value of each list, then the second value, and so on.
            // If the left list runs out of items first, the inputs are in the right order.
            // If the right list runs out of items first, the inputs are not in the right order.
            // If the lists are the same length and no comparison makes a decision about the order, continue checking the next part of the input
            for i in 0... {
                if !a.indices.contains(i) && !b.indices.contains(i) { return .orderedSame }
                else if !a.indices.contains(i) { return .orderedAscending }
                else if !b.indices.contains(i) { return .orderedDescending }
                else {
                    switch compare(a[i], b[i]) {
                    case .orderedAscending: return .orderedAscending
                    case .orderedDescending: return .orderedDescending
                    case .orderedSame: break
                    }
                }
            }
            
            fatalError()
        case let (.integer, b): return compare(Signal.list([lhs]), b)
        case let (a, .integer): return compare(a, .list([rhs]))
        }
    }
    
    static func <(lhs: Self, rhs: Self) -> Bool {
        return compare(lhs, rhs) == .orderedAscending
    }
}

fileprivate let parser = Many {
    Signal.parser
    Whitespace(1, .vertical)
    Signal.parser
    Whitespace(1, .vertical)
} separator: {
    Whitespace(1, .vertical)
} terminator: {
    End()
}

struct Day13: ParsableCommand {
    func run() throws {
        let input = try parser.parse(allInput)
    
        let part1 = zip(1..., input).filter { Signal.compare($0.1.0, $0.1.1) == .orderedAscending }.map(\.0).reduce(0, +)
        print("part 1", part1)
        
        let two = Signal.list([.integer(2)])
        let six = Signal.list([.integer(6)])
        let part2 = (input.flatMap { [$0.0, $0.1] } + [two, six]).sorted()
        
        print("part 2", (part2.firstIndex(of: two)! + 1) * (part2.firstIndex(of: six)! + 1))
    }
}
