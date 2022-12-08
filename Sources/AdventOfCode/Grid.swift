import Foundation
import CoreGraphics
import Algorithms

public struct Coordinate {
    public let x, y: Int
    public typealias Direction = KeyPath<Coordinate, Coordinate>

    public static let zero = Coordinate(x: 0, y: 0)

    public var right: Coordinate { return Coordinate( x: x + 1, y: y ) }
    public var left: Coordinate { return Coordinate( x: x - 1, y: y ) }
    public var up: Coordinate { return Coordinate( x: x, y: y - 1 ) }
    public var down: Coordinate { return Coordinate( x: x, y: y + 1 ) }

    public var east: Coordinate { return Coordinate( x: x + 1, y: y ) }
    public var west: Coordinate { return Coordinate( x: x - 1, y: y ) }
    public var south: Coordinate { return Coordinate( x: x, y: y - 1 ) }
    public var north: Coordinate { return Coordinate( x: x, y: y + 1 ) }

    public var neighbors: [Coordinate] { return [ up, left, right, down ] }
    public var neighbors8: [Coordinate] { return [ up, left, right, down, left.up, right.up, left.down, right.down ] }

    public func neighbors(limitedBy: Int) -> [Coordinate] {
        return neighbors(limitedBy: limitedBy, and: limitedBy )
    }

    public func neighbors(limitedBy xLimit: Int, and yLimit: Int) -> [Coordinate] {
        return [ left, right, up, down ].filter { $0.isValid( x: xLimit, y: yLimit ) }
    }

    public func isValid( minX: Int = 0, x: Int, minY: Int = 0, y: Int ) -> Bool {
        return self.x >= minX && self.x < x && self.y >= minY && self.y < y
    }

    public func go(in direction: Direction, while condition: (Self) -> Bool) -> Coordinate {
        var result = self[keyPath: direction]
        while condition(result) {
            result = result[keyPath: direction]
        }
        return result
    }

    public func go(in direction: Direction, _ amount: Int) -> Coordinate {
        self + Coordinate.zero[keyPath: direction] * amount
    }

    public func neighbors( limitedBy: Int, traveling: Direction ) -> [Coordinate] {
        switch traveling {
        case \Coordinate.down, \Coordinate.up:
            return [ left, right ].filter { $0.isValid( x: limitedBy, y: limitedBy ) }
        case \Coordinate.left, \Coordinate.right:
            return [ down, up ].filter { $0.isValid( x: limitedBy, y: limitedBy ) }
        default: fatalError()
        }
    }

    public func neighbors8( maxX: Int, maxY: Int ) -> [Coordinate] {
        return neighbors8.filter { $0.isValid(x: maxX, y: maxY) }
    }
    
    public func direction(to: Coordinate) -> Direction {
        if abs(self.x - to.x) > abs(self.y - to.y) {
            return self.x > to.x ? \Coordinate.left : \Coordinate.right
        } else {
            return self.y > to.y ? \Coordinate.up : \Coordinate.down
        }
    }

    public init( x: Int, y: Int ) {
        self.x = x
        self.y = y
    }

    public static func +(lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        return Coordinate(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func -(lhs: Coordinate, rhs: Coordinate) -> Coordinate {
        return Coordinate(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }


    public static func *(lhs: Coordinate, scale: Int) -> Coordinate {
        return Coordinate(x: lhs.x * scale, y: lhs.y * scale)
    }
}

extension KeyPath: CustomStringConvertible where Root == Coordinate, Value == Coordinate {
    public var description: String {
        switch self {
        case \Coordinate.down: return "Coordinate.down"
        case \Coordinate.left: return "Coordinate.left"
        case \Coordinate.right: return "Coordinate.right"
        case \Coordinate.up: return "Coordinate.up"
        case \Coordinate.north: return "Coordinate.north"
        case \Coordinate.south: return "Coordinate.south"
        case \Coordinate.east: return "Coordinate.east"
        case \Coordinate.west: return "Coordinate.west"
        default: return "KeyPath<Coordinate, Coordinate>"
        }
    }
}

public extension Coordinate {
    static func turn(left: Direction) -> Direction {
        switch left {
        case \Coordinate.down: return \Coordinate.right
        case \Coordinate.up: return \Coordinate.left
        case \Coordinate.right: return \Coordinate.up
        case \Coordinate.left: return \Coordinate.down

        case \Coordinate.north: return \Coordinate.west
        case \Coordinate.east: return \Coordinate.north
        case \Coordinate.south: return \Coordinate.east
        case \Coordinate.west: return \Coordinate.south
        default: return left
        }
    }
    static func turn(right: Direction) -> Direction {
        switch right {
        case \Coordinate.down: return \Coordinate.left
        case \Coordinate.up: return \Coordinate.right
        case \Coordinate.right: return \Coordinate.down
        case \Coordinate.left: return \Coordinate.up

        case \Coordinate.north: return \Coordinate.east
        case \Coordinate.east: return \Coordinate.south
        case \Coordinate.south: return \Coordinate.west
        case \Coordinate.west: return \Coordinate.north
        default: return right
        }
    }
    static func turn(around: Direction) -> Direction {
        switch around {
        case \Coordinate.down: return \Coordinate.up
        case \Coordinate.up: return \Coordinate.down
        case \Coordinate.right: return \Coordinate.left
        case \Coordinate.left: return \Coordinate.right

        case \Coordinate.north: return \Coordinate.south
        case \Coordinate.east: return \Coordinate.west
        case \Coordinate.south: return \Coordinate.north
        case \Coordinate.west: return \Coordinate.east
        default: return around
        }
    }
}

public struct Grid<T>: Sequence {

    public struct CoordinateIterator: Sequence, IteratorProtocol {
        let maxX, maxY: Int
        let transform: CGAffineTransform
        var coordinate: Coordinate

        public mutating func next() -> Coordinate? {
            if !coordinate.isValid( x: maxX, y: maxY ) {
                coordinate = Coordinate(x: 0, y: coordinate.y+1)
            }
            guard coordinate.isValid( x: maxX, y: maxY ) else { return nil }
            defer { coordinate = coordinate.right }

            let point = CGPoint(x: coordinate.x, y: coordinate.y).applying(transform)
            return Coordinate(x: Int(point.x.rounded()), y: Int(point.y.rounded()))
        }
    }

    public struct Iterator: IteratorProtocol {
        let grid: Grid
        var iterator: CoordinateIterator

        public mutating func next() -> T? {
            guard let coordinate = iterator.next() else { return nil }
            return grid[ coordinate ]
        }
    }

    public typealias Element = T
    var grid: [Element]
    public let maxX: Int
    public let maxY: Int
    let transform: CGAffineTransform

    public subscript( x x: Int, y y: Int ) -> Element {
        get {
            let (xp, yp) = transform(x: x, y: y)
            return grid[ yp * maxX + xp ]
        }
        set {
            let (xp, yp) = transform(x: x, y: y)
            grid[ yp * maxX + xp ] = newValue
        }
    }

    public subscript( _ c: Coordinate ) -> Element {
        get { self[ x: c.x, y: c.y ] }
        set { self[ x: c.x, y: c.y ] = newValue }
    }
    
    public func neighbors(_ c: Coordinate) -> [Coordinate] {
        c.neighbors(limitedBy: maxX, and: maxY)
    }

    public func neighbors8(_ c: Coordinate) -> [Coordinate] {
        c.neighbors8(maxX: maxX, maxY: maxY)
    }
    
    func transform(x: Int, y: Int) -> (x: Int, y: Int) {
        let point = CGPoint(x: x, y: y).applying(transform)
        return (x: Int(point.x.rounded()), y: Int(point.y.rounded()))
    }


    public subscript( x x: CountableRange<Int>, y y: CountableRange<Int>) -> Grid<Element>? {
        return Grid(
            product(y, x).map { (y, x) in self[x: x, y: y] },
            maxX: x.count,
            maxY: y.count,
            transform: .identity
        )
    }
    
    public static func square<S: Sequence>(_ input: S) -> Self? where S.Element == Element {
        let grid = Array(input)
        let size = Int(sqrt(Double(grid.count)))
        precondition(size * size == grid.count)
        
        return Self(grid, maxX: size, maxY: size)
    }

    public init?<S: Sequence>( _ input: S, maxX: Int, maxY: Int, transform: CGAffineTransform = .identity ) where S.Element == Element {
        self.grid = Array(input)
        self.maxX = maxX
        self.maxY = maxY
        self.transform = transform

        guard grid.count == maxX * maxY else { return nil }
    }

    public func applying(_ transform: CGAffineTransform) -> Self {
        Grid(grid, maxX: maxX, maxY: maxY, transform: self.transform.concatenating(transform) )!
    }

    public var rotated: Self {
        applying(
            CGAffineTransform.identity
                .translatedBy(x: CGFloat(maxX) / 2, y: CGFloat(maxY) / 2)
                .rotated(by: .pi/2)
                .translatedBy(x: -CGFloat(maxX) / 2, y: -CGFloat(maxY) / 2 + 1)
        )
    }

    public var mirrored: Self {
        applying(
            CGAffineTransform.identity
                .scaledBy(x: -1, y: 1)
                .translatedBy(x: -CGFloat(maxX) + 1, y: 0)
        )
    }
    
    public var flipped: Self {
        applying(
            CGAffineTransform.identity
                .scaledBy(x: 1, y: -1)
                .translatedBy(x: 0, y: -CGFloat(maxY) + 1)
        )
    }


    public func makeIterator() -> Iterator {
        return Iterator(grid: self, iterator: CoordinateIterator(maxX: maxX, maxY: maxY, transform: transform, coordinate: Coordinate(x: 0, y: 0)))
    }

    public var indices: CoordinateIterator {
        return CoordinateIterator(maxX: maxX, maxY: maxY, transform: transform, coordinate: Coordinate(x: 0, y: 0))
    }

    public mutating func copy( grid: Grid<T>, origin: Coordinate ) {
        for y in origin.y..<(origin.y+grid.maxY) {
            for x in origin.x..<(origin.x+grid.maxX) {
                self[x: x, y: y] = grid[x: x - origin.x, y: y - origin.y]
            }
        }
    }
    
    func map<U>(_ transform: (Element) throws -> U) rethrows -> Grid<U> {
        return try Grid<U>(grid.map(transform), maxX: maxX, maxY: maxY)!
    }
}

extension Grid where Grid.Element: Equatable {
    public static func ==(lhs: Grid, rhs: Grid) -> Bool {
        guard lhs.maxX == rhs.maxX, lhs.maxY == rhs.maxY else { return false }
        return lhs.elementsEqual( rhs )
    }
}

extension Grid: CustomStringConvertible where Element: CustomStringConvertible {
    public var description: String {
        var result = ""
        for y in 0..<maxY {
            for x in 0..<maxX {
                result.append( self[x: x, y: y].description )
            }
            result.append("\n")
        }
        return result
    }
}

extension Coordinate: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

extension Coordinate: CustomStringConvertible {
    public var description: String {
        return "(\(x), \(y))"
    }
}

extension Coordinate: Comparable {
    public static func <(lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.y == rhs.y ? lhs.x < rhs.x : lhs.y < rhs.y
    }
}

extension Coordinate: Equatable {
    public static func ==(lhs: Coordinate, rhs: Coordinate) -> Bool {
        return lhs.y == rhs.y && lhs.x == rhs.x
    }
}
