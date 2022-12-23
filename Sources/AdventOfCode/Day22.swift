import ArgumentParser
import Parsing
import Algorithms

fileprivate let parser = Many {
    Int.parser()
    Optionally {
        OneOf {
            Parse { "R" }.map { _ in Coordinate.turn(right:) }
            Parse { "L" }.map { _ in Coordinate.turn(left:) }
        }
    }
} terminator: {
    End()
}

extension Grid where Element == Character {
    func neighbor(_ coordinate: Coordinate, in direction: Coordinate.Direction) -> Coordinate {
        var next = coordinate
        repeat {
            next = next[keyPath: direction]
            if next.x >= maxX {
                next = Coordinate(x: 0,        y: next.y)
            } else if next.x < 0 {
                next = Coordinate(x: maxX - 1, y: next.y)
            }
            
            if next.y >= maxY {
                next = Coordinate(x: next.x, y: 0)
            } else if next.y < 0 {
                next = Coordinate(x: next.x, y: maxY - 1)
            }
        } while self[next] == " "
        
        return next
    }
    
    func go(_ coordinate: Coordinate, in direction: Coordinate.Direction, for amount: Int, while condition: (Coordinate) -> Bool) -> Coordinate {
        var result = coordinate 
        var amount = amount

        repeat {
            let newCoordinate = self.neighbor(result, in: direction)
            if !condition(newCoordinate) { return result }

            amount -= 1
            result = newCoordinate
        } while amount > 0

        return result
    }
}

private let facings = [ \Coordinate.right, \Coordinate.down, \Coordinate.left, \Coordinate.up ]

struct Day22: ParsableCommand {
    func run() throws {
        let input = Array(stdin)
        let grid = Grid(input.dropLast(2).joined(), maxX: input[0].count, maxY: input.dropLast(2).count)!
        let directions = try parser.parse(input.last!)

        let part1 = directions.reduce(into: (coordinate: grid.neighbor(.zero, in: \.right), facing: \Coordinate.right)) {
            $0.coordinate = grid.go($0.coordinate, in: $0.facing, for: $1.0) { grid[$0] == "." }
            $0.facing = $1.1 != nil ? $1.1!($0.facing) : $0.facing
        }
        
        print("part 1", 1000 * (part1.coordinate.y + 1) + 4 * (part1.coordinate.x + 1) + facings.firstIndex(of: part1.facing)!)
        
        part2(grid: grid, directions: directions)
    }
    
    func part2(grid: Grid<Character>, directions: [(Int, ((Coordinate.Direction) -> Coordinate.Direction)?)]) {
        let indexedGrid = Grid(zip(grid.indices, grid), maxX: grid.maxX, maxY: grid.maxY)!
        let indices = product(0..<4, 0..<3).map { y, x in (x: x, y: y) }
        let (maxX, maxY) = (50, 50)
        
        let allRanges = indices.map { 
            let x: Range<Int> = ($0.x*maxX)..<(($0.x + 1)*maxY)
            let y: Range<Int> = ($0.y*maxX)..<(($0.y + 1)*maxY)
            return (x, y)
        }

        let allFaces = allRanges.map { x, y in
            return indexedGrid[x: x, y: y]!
        }
        let faces = allFaces.filter { $0[.zero].1 != " " }
        
        // TODO: Don't hardcode based on my particular input layout, but generalize for any unwrapped cube...
        func transition(
            from face: Int, 
            in direction: Coordinate.Direction, 
            at coordinate: Coordinate
        ) -> (face: Int, direction: Coordinate.Direction, coordinate: Coordinate) {
            switch (face, direction) {
            case (0, \.right): return (face: 1, direction: \.right, .init(x: 0, y: coordinate.y))
            case (0, \.down):  return (face: 2, direction: \.down,  .init(x: coordinate.x, y: 0))
            case (0, \.left):  return (face: 3, direction: \.right, .init(x: 0, y: maxY - coordinate.y - 1))
            case (0, \.up):    return (face: 5, direction: \.right, .init(x: 0, y: coordinate.x))

            case (1, \.right): return (face: 4, direction: \.left,  .init(x: maxX - 1, y: maxY - coordinate.y - 1))
            case (1, \.down):  return (face: 2, direction: \.left,  .init(x: maxX - 1, y: coordinate.x))
            case (1, \.left):  return (face: 0, direction: \.left,  .init(x: maxX - 1, y: coordinate.y))
            case (1, \.up):    return (face: 5, direction: \.up,    .init(x: coordinate.x, y: maxY - 1))

            case (2, \.right): return (face: 1, direction: \.up,    .init(x: coordinate.y, y: maxY - 1))
            case (2, \.down):  return (face: 4, direction: \.down,  .init(x: coordinate.x, y: 0))
            case (2, \.left):  return (face: 3, direction: \.down,  .init(x: coordinate.y, y: 0))
            case (2, \.up):    return (face: 0, direction: \.up,    .init(x: coordinate.x, y: maxY - 1))

            case (3, \.right): return (face: 4, direction: \.right, .init(x: 0, y: coordinate.y))
            case (3, \.down):  return (face: 5, direction: \.down,  .init(x: coordinate.x, y: 0))
            case (3, \.left):  return (face: 0, direction: \.right, .init(x: 0, y: maxY - coordinate.y - 1))
            case (3, \.up):    return (face: 2, direction: \.right, .init(x: 0, y: coordinate.x))

            case (4, \.right): return (face: 1, direction: \.left,  .init(x: maxX - 1, y: maxY - coordinate.y - 1))
            case (4, \.down):  return (face: 5, direction: \.left,  .init(x: maxX - 1, y: coordinate.x))
            case (4, \.left):  return (face: 3, direction: \.left,  .init(x: maxX - 1, y: coordinate.y))
            case (4, \.up):    return (face: 2, direction: \.up,    .init(x: coordinate.x, y: maxY - 1))

            case (5, \.right): return (face: 4, direction: \.up,    .init(x: coordinate.y, y: maxY - 1))
            case (5, \.down):  return (face: 1, direction: \.down,  .init(x: coordinate.x, y: 0))
            case (5, \.left):  return (face: 0, direction: \.down,  .init(x: coordinate.y, y: 0))
            case (5, \.up):    return (face: 3, direction: \.up,    .init(x: coordinate.x, y: maxY - 1))

            default: fatalError()
            }
        }
        
        func go(
            face: Int, 
            coordinate: Coordinate, 
            in direction: Coordinate.Direction, 
            for amount: Int, 
            while condition: (Int, Coordinate) -> Bool
        ) -> (face: Int, direction: Coordinate.Direction, coordinate: Coordinate) {
            var result = (face: face, direction: direction, coordinate: coordinate)
            var amount = amount

            repeat {
                var (newFace, newDirection, newCoordinate) = (result.face, result.direction, result.coordinate[keyPath: result.direction])
                
                if !newCoordinate.isValid(x: maxX, y: maxY) {
                    (newFace, newDirection, newCoordinate) = transition(
                        from: newFace, 
                        in: newDirection, 
                        at: newCoordinate
                    )
                }
                if !condition(newFace, newCoordinate) { return result }

                amount -= 1
                result = (newFace, newDirection, newCoordinate)
            } while amount > 0

            return result
        }

        let part2 = directions.reduce(
            into: (face: 0, coordinate: Coordinate.zero, facing: \Coordinate.right)
        ) { result, direction in 
            (result.face, result.facing, result.coordinate) = go(
                face: result.face, 
                coordinate: result.coordinate, 
                in: result.facing, 
                for: direction.0
            ) { 
                switch faces[$0][$1].1 {
                case ".": return true
                case "#": return false
                default: fatalError("unexpected: \($0) \($1) \(faces[$0][$1])")
                }
            }
            
            result.facing = direction.1 != nil ? direction.1!(result.facing) : result.facing
        }

        let coordinate = faces[part2.face][part2.coordinate].0
        print("part 2", (1000 * (coordinate.y + 1)) + (4 * (coordinate.x + 1)) + facings.firstIndex(of: part2.facing)!)
    }
}
