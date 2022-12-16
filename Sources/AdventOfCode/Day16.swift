import ArgumentParser
import Parsing
import Collections
import Algorithms

// Valve TU has flow rate=0; tunnels lead to valves XG, ID

fileprivate let parser = Parse {
    "Valve "
    Prefix(2).map(String.init)
    " has flow rate="
    Parse {
        Int.parser()
        OneOf {
            "; tunnels lead to valves "
            "; tunnel leads to valve "
        }
        
        Many {
            Prefix(2).map(String.init)
        } separator: {
            ", "
        } terminator: {
            End()
        }
    }
}

fileprivate struct Node: Comparable {
    let coordinate: String
    let cost: Int
    static func <(lhs: Node, rhs: Node) -> Bool {
        lhs.cost < rhs.cost
    }
}

struct Day16: ParsableCommand {

    func dijkstra(graph: [String: (Int, [String])], start: String, end: String) -> Int {
        var q = Set<String>(graph.keys)
        var prev = [String: String]()
        var dist = [String: Int]()
        var heap = Heap<Node>([.init(coordinate: start, cost: 0)])
        dist[start] = 0
        
        while true {
            guard let u = heap.popMin() else { fatalError() }
            guard dist[u.coordinate] == u.cost else { continue }
            if u.coordinate == end { return dist[u.coordinate]! }
            q.remove(u.coordinate)
            
            let neighbors = graph[u.coordinate]!.1
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

        fatalError()
    }
    
    func find(costs: [String: Int], valves: [String: Int], location: String, pressure: Int, remaining: Int) -> Int {
        if remaining < 1 { return pressure }
        var result = pressure

        for (l, valve) in valves {
            let cost = costs[ [location, l].sorted().joined() ]!
            if remaining - cost < 1 { continue }
            
            var valves = valves
            valves.removeValue(forKey: l)
            let p = pressure + valve * (remaining - cost - 1)
            
            result = Swift.max( result, find(costs: costs, valves: valves, location: l, pressure: p, remaining: remaining - cost - 1) )
        }
        
        return result
    }
    
    func divide(costs: [String: Int], valves: [String: Int]) -> Int {
        var result = 0
        let set = valves.keys
        
        for s in set.combinations(ofCount: (valves.count / 2) ) {
            let set = Set(s)
            let v1 = valves.filter { set.contains($0.key) }
            let v2 = valves.filter { !set.contains($0.key) }

            result = Swift.max(
                result,
                find(costs: costs, valves: v1, location: "AA", pressure: 0, remaining: 26) +
                find(costs: costs, valves: v2, location: "AA", pressure: 0, remaining: 26)
            )
        }
        
        return result
    }
    
    func run() throws {
        let graph = try Dictionary(uniqueKeysWithValues: stdin.map { try parser.parse($0) })
        let valves = graph.filter { $0.value.0 > 0 }.mapValues(\.0)
        let costs = (["AA"] + valves.keys).permutations(ofCount: 2).reduce(into: [String:Int]()) { costs, locations in
            let key = locations.sorted().joined()
            guard costs[key] == nil else { return }
            costs[key] = dijkstra(graph: graph, start: locations[0], end: locations[1])
        }

        print("part 1", find(costs: costs, valves: valves, location: "AA", pressure: 0, remaining: 30))
        print("part 2", divide(costs: costs, valves: valves))
    }
}
