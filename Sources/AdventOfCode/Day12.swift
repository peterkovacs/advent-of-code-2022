import ArgumentParser
import Algorithms
import DequeModule
import Collections

fileprivate enum Element: Equatable, CustomStringConvertible {
    case normal(Int)
    case start
    case end
    
    init(rawValue: Character) {
        switch rawValue {
        case "S": self = .start
        case "E": self = .end
        default:  self = .normal(Int(rawValue.asciiValue! - ("a" as Character).asciiValue!))
        }
    }
    
    var description: String {
        switch self {
        case .start: return "S"
        case .end: return "E"
        case .normal(let v): return String(Character(UnicodeScalar(Int(("a" as UnicodeScalar).value) + v)!))
        }
    }
}

fileprivate struct Node: Comparable {
    let coordinate: Coordinate
    let cost: Int
    static func <(lhs: Node, rhs: Node) -> Bool {
        lhs.cost < rhs.cost
    }
}

struct Day12: ParsableCommand {
    
    func dijkstra(grid: Grid<Int>, start: Coordinate, end: Coordinate) -> [Coordinate]? {
        var q = Set<Coordinate>(grid.indices)
        var prev = [Coordinate: Coordinate]()
        var dist = [Coordinate: Int]()
        var heap = Heap<Node>([.init(coordinate: start, cost: 0)])
        dist[start] = 0
        
        while true {
            guard let u = heap.popMin() else { return nil }
            guard dist[u.coordinate] == u.cost else { continue }
            if u.coordinate == end { break }
            q.remove(u.coordinate)
            
            let neighbors = u.coordinate.neighbors(limitedBy: grid.maxX, and: grid.maxY)
                .filter { grid[u.coordinate] + 1 >= grid[$0] }
                .filter { q.contains($0) }
            
            for v in neighbors {
                let alt = dist[u.coordinate].map { $0 + 1 } ?? Int.max
                if alt < dist[v] ?? Int.max {
                    heap.insert(.init(coordinate: v, cost: alt))
                    dist[v] = alt
                    prev[v] = u.coordinate
                }
            }
        }

        var result = [Coordinate]()
        var u = end as Coordinate?
        while u != nil {
            result.append(u!)
            u = prev[u!]
        }
        
        return result.dropLast()
    }
    
    func run() {
        let input = Array(stdin)
        let grid = Grid(input.joined().map(Element.init), maxX: input[0].count, maxY: input.count)!
        let start = grid.indices.first(where: { grid[$0] == .start })!
        let end = grid.indices.first(where: { grid[$0] == .end })!

        let part1 = dijkstra(
            grid: grid.map {
                switch $0 {
                case .start: return 0
                case .end: return 25
                case .normal(let v): return v
                }
            },
            start: start,
            end: end
        )!
        
        var g = grid.map(\.description)
        zip(part1, part1.dropFirst()).forEach {
            switch ($0.1).direction(to: $0.0) {
            case \.up: g[$0.0] = "^"
            case \.down: g[$0.0] = "v"
            case \.left: g[$0.0] = "<"
            case \.right: g[$0.0] = ">"
            default: fatalError()
            }
        }
        print(g)
            
        print("part 1", part1.count)
        
        let part2 = grid.indices.filter { grid[$0] == .normal(0) }.compactMap {
            dijkstra(
                grid: grid.map {
                    switch $0 {
                    case .start: return 0
                    case .end: return 25
                    case .normal(let v): return v
                    }
                },
                start: $0,
                end: end
            )?.count
        }.min()!
        
        print("part 2", part2)
    }
}
