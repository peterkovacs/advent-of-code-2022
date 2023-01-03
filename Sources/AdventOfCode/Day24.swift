import ArgumentParser
import Collections

fileprivate struct Direction: OptionSet, Hashable, CustomStringConvertible {
    let rawValue: Int
    
    static let up = Direction(rawValue: 1 << 0)
    static let down = Direction(rawValue: 1 << 1)
    static let left = Direction(rawValue: 1 << 2)
    static let right = Direction(rawValue: 1 << 3)
    
    static let wall = Direction(rawValue: 1 << 4)
    
    var description: String {
        let description = [
            self.contains(.up) ? "^" : nil,
            self.contains(.down) ? "v" : nil,
            self.contains(.left) ? "<" : nil,
            self.contains(.right) ? ">" : nil,
            self.contains(.wall) ? "#" : nil
        ].compacted()
        
        if description.count > 1 {
            return "\(description.count)"
        } else if description.isEmpty {
            return "."
        } else { 
            return description.first!
        }
    }
}

fileprivate extension Grid where Element == Direction {
    var next: Self {
        let empty = Grid<Direction>(
            map { $0.intersection(.wall) }, 
            maxX: maxX, 
            maxY: maxY
        )!
        
        return indices.reduce(into: empty) { result, from in
            if self[from].contains(.up) {
                let to = from.up.isValid(x: maxX, y: maxY) && !self[from.up].contains(.wall) 
                    ? from.up 
                    : Coordinate(x: from.x, y: maxY - 2)
                result[to].insert(.up)
            }
            
            if self[from].contains(.down) {
                let to = from.down.isValid(x: maxX, y: maxY) && !self[from.down].contains(.wall) 
                    ? from.down 
                    : Coordinate(x: from.x, y: 1)
                result[to].insert(.down)
            }

            if self[from].contains(.left) {
                let to = from.left.isValid(x: maxX, y: maxY) && !self[from.left].contains(.wall) 
                    ? from.left 
                    : Coordinate(x: maxX - 2, y: from.y)
                result[to].insert(.left)
            }

            if self[from].contains(.right) {
                let to = from.right.isValid(x: maxX, y: maxY) && !self[from.right].contains(.wall) 
                    ? from.right 
                    : Coordinate(x: 1, y: from.y)
                result[to].insert(.right)
            }
        }
    }
}

fileprivate var END: Coordinate!

fileprivate struct State: Hashable, Comparable {
    let position: Coordinate
    let steps: Int
    let grid: Grid<Direction>
    
    static func <(lhs: Self, rhs: Self) -> Bool {
        if lhs.steps == rhs.steps {
            return lhs.position.distance(to: END) < rhs.position.distance(to: END)
        } else {
            return lhs.steps < rhs.steps
        }
    }
    
//    static func <(lhs: Self, rhs: Self) -> Bool {
//        let distL = lhs.position.distance(to: END)
//        let distR = rhs.position.distance(to: END)
//        
//        if distL == distR {
//            return lhs.steps < rhs.steps
//        } else {
//            return distL < distR
//        }
//    }

}

struct Day24: ParsableCommand {
    fileprivate func bfs(grid: Grid<Direction>, start: Coordinate, end: Coordinate) -> State {
        END = end
        
        let initial = [ State(position: start, steps: 0, grid: grid) ]
        var queue = Deque(initial)
        var visited = Set<State>(initial)
        
        while !queue.isEmpty {
            let state = queue.removeFirst()
            let nextGrid = state.grid.next
            let neighbors = (state.position.neighbors + [state.position])
                .filter { 
                    $0.isValid(x: nextGrid.maxX, y: nextGrid.maxY) && 
                    nextGrid[$0].isEmpty
                }
                .map { 
                    return State(
                        position: $0, 
                        steps: state.steps + 1, 
                        grid: nextGrid
                    ) 
                }
                .filter { !visited.contains($0) }
            
            let finished = neighbors.first { $0.position == end }
            if let finished {
                return finished
            }
            
            visited.formUnion(neighbors)
            queue.append(contentsOf: neighbors)
        }
        
        fatalError("unable to route. visited:\(visited.count)")
    }
    
    func run() {
         let input = Array(stdin)
//        let input = """
//        #.######
//        #>>.<^<#
//        #.<..<<#
//        #>v.><>#
//        #<^v^^>#
//        ######.#
//        """.components(separatedBy: "\n")
        
        let grid = Grid<Direction>(
            input.joined().map { 
                switch $0 {
                case "^": return .up
                case "v": return .down
                case "<": return .left
                case ">": return .right
                case ".": return []
                case "#": return .wall
                default: fatalError("unknown: \($0)")
                }
            },
            maxX: input[0].count,
            maxY: input.count
        )!
        
        let part1 = bfs(
            grid: grid,
            start: .init(x: 1, y: 0),
            end: .init(x: grid.maxX - 2, y: grid.maxY - 1)
        )
        
        print("part 1", part1.steps)
        
        let backToStart = bfs(
            grid: part1.grid.next,
            start: .init(x: grid.maxX - 2, y: grid.maxY - 1), 
            end: .init(x: 1, y: 0)
        )
        
        print("back to start", backToStart.steps)
        
        let backToEnd = bfs(
            grid: backToStart.grid.next,
            start: .init(x: 1, y: 0),
            end: .init(x: grid.maxX - 2, y: grid.maxY - 1) 
        )
        
        print("back to end", backToEnd.steps)
        
        print("part 2", part1.steps + 1 + backToStart.steps + 1 + backToEnd.steps)
    }
}
