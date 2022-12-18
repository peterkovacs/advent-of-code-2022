import ArgumentParser
import Parsing
import Foundation
import Algorithms

fileprivate let parser = Many {
    OneOf {
        Parse { _ in 1 } with: { ">" }
        Parse { _ in -1 } with: { "<" }
    }
} terminator: {
    Whitespace(.vertical)
    End()
}

fileprivate enum Shape: CaseIterable {
    case line, plus, angle, bar, square
}

public enum D17Elem: CustomStringConvertible {
    case none, immovable, falling
    
    public var description: String {
        switch self {
        case .immovable: return "#"
        case .falling: return "@"
        case .none: return " "
        }
    }
}

extension InfiniteGrid where Element == D17Elem {
    fileprivate mutating func add(shape: Shape) -> ([Coordinate], [Coordinate]) {
        // find highest Y of a .immovable
        let y = indices().reversed().first { self[$0] == .immovable }!.y + 4

        let result: [Coordinate]
        switch shape {
        case .line:
            result = [
                .init(x: 2, y: y),
                .init(x: 3, y: y),
                .init(x: 4, y: y),
                .init(x: 5, y: y),
            ]
        case .plus:
            result = [
                .init(x: 3, y: y),
                .init(x: 2, y: y+1),
                .init(x: 3, y: y+1),
                .init(x: 4, y: y+1),
                .init(x: 3, y: y+2),
            ]
            
        case .angle:
            result = [
                .init(x: 2, y: y),
                .init(x: 3, y: y),
                .init(x: 4, y: y),
                .init(x: 4, y: y + 1),
                .init(x: 4, y: y + 2),
            ]

        case .bar:
            result = [
                .init(x: 2, y: y),
                .init(x: 2, y: y + 1),
                .init(x: 2, y: y + 2),
                .init(x: 2, y: y + 3),
            ]

        case .square:
            result = [
                .init(x: 2, y: y),
                .init(x: 3, y: y),
                .init(x: 2, y: y + 1),
                .init(x: 3, y: y + 1),
            ]
        }
        
        // find the nearest .immovable in each column starting from y
        let nearest = (minX..<maxX).map { x in
            Coordinate(x: x, y: (minY..<y).reversed().first { y in
                self[.init(x: x, y: y)] != .none
            }!)
        }
        
        result.forEach { self[$0] = .falling }
        return (result, nearest)
    }
    
    mutating func gust(in direction: Int, shape: [Coordinate]) -> [Coordinate] {
        let newShape = shape.map { $0 + .init(x: direction, y: 0) }
//        print("in gust invalid:\(newShape.filter { !$0.isValid(x: maxX, y: maxY)}) immovable:\(newShape.filter { self[$0] == .immovable })")
        let canMove = newShape.allSatisfy {
            return $0.isValid(x: maxX, y: maxY) && self[$0] != .immovable
        }
        
        if canMove {
            shape.forEach { self[$0] = .none }
            newShape.forEach { self[$0] = .falling }
            return newShape
        } else {
            return shape
        }
    }
    
    mutating func fall(shape: [Coordinate]) -> [Coordinate]? {
        let newShape = shape.map { $0 + .init(x: 0, y: -1) }
        let canMove = newShape.allSatisfy {
            return $0.isValid(x: maxX, y: maxY) && self[$0] != .immovable
        }
        
        if canMove {
            shape.forEach { self[$0] = .none }
            newShape.forEach { self[$0] = .falling }
            return newShape
        } else {
            shape.forEach { self[$0] = .immovable }
            return nil
        }
    }
}

extension Grid where Element == D17Elem {
    fileprivate mutating func add(shape: Shape, at y: Int) -> [Coordinate] {
        let result: [Coordinate]
        switch shape {
        case .line:
            result = [
                .init(x: 2, y: y),
                .init(x: 3, y: y),
                .init(x: 4, y: y),
                .init(x: 5, y: y),
            ]
        case .plus:
            result = [
                .init(x: 3, y: y),
                .init(x: 2, y: y+1),
                .init(x: 3, y: y+1),
                .init(x: 4, y: y+1),
                .init(x: 3, y: y+2),
            ]
            
        case .angle:
            result = [
                .init(x: 2, y: y),
                .init(x: 3, y: y),
                .init(x: 4, y: y),
                .init(x: 4, y: y + 1),
                .init(x: 4, y: y + 2),
            ]

        case .bar:
            result = [
                .init(x: 2, y: y),
                .init(x: 2, y: y + 1),
                .init(x: 2, y: y + 2),
                .init(x: 2, y: y + 3),
            ]

        case .square:
            result = [
                .init(x: 2, y: y),
                .init(x: 3, y: y),
                .init(x: 2, y: y + 1),
                .init(x: 3, y: y + 1),
            ]
        }

        result.forEach { self[$0] = .falling }
        return result
    }
    
    mutating func gust(in direction: Int, shape: [Coordinate]) -> [Coordinate] {
        let newShape = shape.map { $0 + .init(x: direction, y: 0) }
        let canMove = newShape.allSatisfy {
            return $0.isValid(x: maxX, y: maxY) && self[$0] != .immovable
        }
        
        if canMove {
            shape.forEach { self[$0] = .none }
            newShape.forEach { self[$0] = .falling }
            return newShape
        } else {
            return shape
        }
    }
    
    mutating func fall(shape: [Coordinate]) -> [Coordinate]? {
        let newShape = shape.map { $0 + .init(x: 0, y: -1) }
        let canMove = newShape.allSatisfy {
            return $0.isValid(x: maxX, y: maxY) && self[$0] != .immovable
        }
        
        if canMove {
            shape.forEach { self[$0] = .none }
            newShape.forEach { self[$0] = .falling }
            return newShape
        } else {
            shape.forEach { self[$0] = .immovable }
            return nil
        }
    }
}

// [1, 1, 1, -1, -1, 1, -1, 1, 1, -1, -1, -1, 1, 1, -1, 1, 1, 1, -1, -1, -1, 1, 1, 1, -1, -1, -1, 1, -1, -1, -1, 1, 1, -1, 1, 1, -1, -1, 1, 1]
//  >  >  >   <   <  >   <  >  >   <   <   <  >  >   <  >  >  >   <   <   <  >  >  >   <   <   <  >   <   <   <  >  >   <  >  >   <   <  >  >

fileprivate struct State: Hashable {
    let shape, direction: Int
    let coordinates: [Coordinate]
}

struct Day17: ParsableCommand {
    @Flag var p2 = false
    
    func run() throws {
        if p2 {
            try self.part2()
        } else {
            try self.part1()
        }
    }
  
    
    func part1() throws {
        let directions = try parser.parse(allInput)
        
        var grid = InfiniteGrid<D17Elem>([.immovable, .immovable, .immovable, .immovable, .immovable, .immovable, .immovable], maxX: 7, defaultValue: .none)
        var nextDirection = directions.cycled().makeIterator()
        
        for shape in Shape.allCases.cycled().prefix(2022) {
            var (coordinates, _) = grid.add(shape: shape)
            var isFalling = true
            
            repeat {
                let direction = nextDirection.next()!
                
                coordinates = grid.gust(in: direction, shape: coordinates)
                if let c = grid.fall(shape: coordinates) {
                    coordinates = c
                } else {
                    isFalling = false
                }
            } while isFalling
        }
        
        let part1 = grid.indices().lazy.filter { grid[$0] == .immovable }.map(\.y).max()!
        print("part 1", part1)
    }
    
    func part2() throws {
        let directions = try parser.parse(allInput)
        var grid = Grid(Array(repeating: D17Elem.none, count: 5000 * 7), maxX: 7, maxY: 5000 )!
        var nextDirection = directions.indexed().cycled().makeIterator()
        var nextShape = Shape.allCases.indexed().cycled().makeIterator()
        
        grid[x: 0, y: 0] = .immovable
        grid[x: 1, y: 0] = .immovable
        grid[x: 2, y: 0] = .immovable
        grid[x: 3, y: 0] = .immovable
        grid[x: 4, y: 0] = .immovable
        grid[x: 5, y: 0] = .immovable
        grid[x: 6, y: 0] = .immovable
        
        var dict = [State: (i: Int, floor: Int)]()
        var y = 4
        var floor = 0
        var i = 0
        var foundCycle = false
        
        repeat {
            i += 1
            let shape = nextShape.next()!
            var coordinates = grid.add(shape: shape.element, at: y)
            var isFalling = true
            
            repeat {
                let direction = nextDirection.next()!
                
                coordinates = grid.gust(in: direction.element, shape: coordinates)
                if let c = grid.fall(shape: coordinates) {
                    coordinates = c
                } else {
                    let (min, max) = coordinates.map(\.y).minAndMax()!
                    y = Swift.max(y, max + 4)

                    let newFloor = (min...y).first { y in
                        (0..<7).allSatisfy { grid[.init(x: $0, y: y)] == .immovable }
                    }
                    
                    if let newFloor {
                        var newGrid = Grid(Array(repeating: D17Elem.none, count: 5000  * 7), maxX: 7, maxY: 5000)!
                        newGrid.copy(grid: grid[x: 0..<7, y: newFloor..<y+1]!, origin: .zero)
                        grid = newGrid
                        floor += newFloor
                        y -= newFloor
                    }
                    
                    if shape.index == 2, direction.index ==  3271 {
                        let immovable = grid.indices.filter { grid[$0] != .none }
                        let key = State(shape: shape.index, direction: direction.index, coordinates: immovable)
                        if !foundCycle, let cycle = dict[ key ] {
                            print("CYCLE DETECTED: i:\(i) shape:\(shape.index) direction:\(direction.index) \(cycle), floor:\(floor)")
                            // CYCLE DETECTED AT (shape: 2, directions: 3271): 2283, (index: 558, floor: 835), 3465

                            let iterationsInCycle = (i - cycle.i)
                            // 1000000000000 = x * iterationsInCycle + cycle.index
                            let cycleMultiplier = (1000000000000 - i) / iterationsInCycle
                            let nextI = cycle.i + (cycleMultiplier * iterationsInCycle)
                            
                            // (451379-168831)*2+168831 => 733927
                            let nextFloor = (floor - cycle.floor) * cycleMultiplier + (cycle.floor)
                            print("iterations in cycle:\(iterationsInCycle) cycleMultipler:\(cycleMultiplier) nextI:\(nextI) nextFloor:\(nextFloor)")
                            
                            i = nextI
                            floor = nextFloor
                            foundCycle = true
                        }
                        
                        dict[ key ] = (i, floor)
                    }
                    
                    isFalling = false
                }
            } while isFalling
        } while i < 1000000000000
        
        print("part 2", floor + y - 4)
    }
}
