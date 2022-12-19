import ArgumentParser
import Parsing
import Collections

fileprivate extension Coordinate3D {
    static let parser = Parse(Coordinate3D.init) {
        Int.parser()
        ","
        Int.parser()
        ","
        Int.parser()
    }
}


fileprivate enum State {
    case unknown, rock, external
}


struct Day18: ParsableCommand {
    @Flag var p2 = false
    
    func run() throws {
        if p2 {
            try part2()
        } else {
            try part1()
        }
    }
    
    fileprivate func bfs(grid: InfiniteGrid3D<State>) -> InfiniteGrid3D<State> {
        var grid = grid
        let start = Coordinate3D(x: grid.minX, y: grid.minY, z: grid.minZ)
        var queue = Deque( [start] )
        var visited = Set<Coordinate3D>( queue )
        grid[start] = .external
        
        while !queue.isEmpty {
            let n = queue.popFirst()!

            let neighbors = n.neighbors
                .filter {
                    (grid.minX..<grid.maxX).contains($0.x) &&
                    (grid.minY..<grid.maxY).contains($0.y) &&
                    (grid.minZ..<grid.maxZ).contains($0.z)
                }
                .filter { !visited.contains($0) }
                .filter { grid[$0] == .unknown }
            
            visited.formUnion(neighbors)
            neighbors.forEach { grid[$0] = .external }
            
            queue.append(contentsOf: neighbors)
        }
        
        return grid
    }
        
    func part2() throws {
        var grid = try stdin.map { try Coordinate3D.parser.parse($0) }
            .reduce(into: InfiniteGrid3D([], maxX: 0, maxY: 0, defaultValue: State.unknown)) {
                $0[$1] = .rock
            }
        
        // add a little padding around all points that we know is external
        grid.setBounds(.init(x: grid.minX - 1, y: grid.minY - 1, z: grid.minZ - 1))
        grid.setBounds(.init(x: grid.maxX, y: grid.maxY, z: grid.maxZ))
        
        grid = bfs(grid: grid)

        let externalFaces = grid.indices().filter { grid[$0] == .rock }.flatMap { $0.neighbors }.filter { grid[$0] == .external }.count

        print("part 2", externalFaces)
    }
    
    func part1() throws {
        let grid = try stdin.map { try Coordinate3D.parser.parse($0) }
            .reduce(into: InfiniteGrid3D([], maxX: 1, maxY: 1, defaultValue: false)) {
                $0[$1] = true
            }
        

        let part1 = grid.indices().filter { grid[$0] }.flatMap { $0.neighbors }.filter { !grid[$0] }.count
        print("part 1", part1)
    }
}
