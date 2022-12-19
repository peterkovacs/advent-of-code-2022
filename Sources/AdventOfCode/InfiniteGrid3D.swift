//
//  File.swift
//
//
//  Created by Peter Kovacs on 12/20/21.
//

import Foundation
import Algorithms

public struct Coordinate3D: Equatable, Hashable, Comparable {
    public var x, y, z: Int
       
    static func +(lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        .init(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    static func *(lhs: Self, rhs: Int) -> Self {
        .init(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    public static func <(lhs: Self, rhs: Self) -> Bool {
        return lhs.z == rhs.z ? (lhs.y == rhs.y ? lhs.x < rhs.x : lhs.y < rhs.y) : lhs.z < rhs.z
    }
    
    var neighbors: [Coordinate3D] {
        Self.faces.map { self + $0 }
    }
    
    static var faces: [Coordinate3D] = [
        .init(x:  1, y:  0, z:  0),
        .init(x: -1, y:  0, z:  0),
        .init(x:  0, y:  1, z:  0),
        .init(x:  0, y: -1, z:  0),
        .init(x:  0, y:  0, z:  1),
        .init(x:  0, y:  0, z: -1),
    ]
}

public struct InfiniteGrid3D<T>: Sequence {
    public typealias Element = T
    public private(set) var grid: [Coordinate3D: Element]
    public private(set) var minX, minY, minZ, maxX, maxY, maxZ: Int
    let defaultValue: Element
    
    public init<S>(
        _ s: S,
        minX: Int = 0,
        minY: Int = 0,
        minZ: Int = 0,
        maxX: Int,
        maxY: Int,
        maxZ: Int = 0,
        defaultValue: Element
    ) where S: Sequence, S.Element == Element
    {
        (self.minX, self.minY, self.minZ, self.maxX, self.maxY, self.maxZ) = (minX, minY, minZ, maxX, maxY, maxZ)
        self.defaultValue = defaultValue
        self.grid = .init(
            uniqueKeysWithValues: zip(
                CoordinateIterator(
                    minX: minX,
                    maxX: maxX,
                    minY: minY,
                    maxY: maxY,
                    minZ: minZ,
                    maxZ: Int.max,
                    coordinate: .init(x: minX, y: minY, z: minZ)
                ),
                s
            )
        )
        if let max = grid.keys.max() {
            setBounds( max )
        }
    }
    
    public subscript( _ c: Coordinate3D ) -> Element {
        get {
            return grid[c, default: defaultValue]
        }
        set {
            setBounds(c)
            grid[c] = newValue
        }
    }

    public subscript( x x: CountableRange<Int>, y y: CountableRange<Int>, z z: CountableRange<Int> ) -> InfiniteGrid3D<Element> {
        get {
            InfiniteGrid3D(
                product(z, product(y, x)).map { self[Coordinate3D(x: $1.1, y: $1.0, z: $0)] },
                maxX: x.count,
                maxY: y.count,
                maxZ: z.count,
                defaultValue: defaultValue
            )
        }
    }
    
    mutating public func setBounds(_ c: Coordinate3D) {
        minX = Swift.min(minX, c.x)
        maxX = Swift.max(maxX, c.x + 1)
        minY = Swift.min(minY, c.y)
        maxY = Swift.max(maxY, c.y + 1)
        minZ = Swift.min(minZ, c.z)
        maxZ = Swift.max(maxZ, c.z + 1)

    }
    
    public struct CoordinateIterator: IteratorProtocol, Sequence {
        let minX, maxX, minY, maxY, minZ, maxZ: Int
        var coordinate: Coordinate3D
        
        public mutating func next() -> Coordinate3D? {
            guard minX < maxX, minY < maxY, minZ < maxZ else { return nil }
            
            if coordinate.x >= maxX {
                coordinate.x = minX
                coordinate.y += 1
            }
            
            if coordinate.y >= maxY {
                coordinate.y = minY
                coordinate.z += 1
            }
            
            if coordinate.z >= maxZ { return nil }

            defer { coordinate.x += 1 }

            return coordinate
        }
    }
    
    public struct Iterator: IteratorProtocol {
        let grid: InfiniteGrid3D
        var iterator: CoordinateIterator
        
        public mutating func next() -> Element? {
            guard let coordinate = iterator.next() else { return nil }
            return grid[ coordinate ]
        }
    }
    
    public func makeIterator() -> Iterator {
        return Iterator(
            grid: self,
            iterator: indices()
        )
    }
    
    public func indices() -> CoordinateIterator {
        return CoordinateIterator(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            minZ: minZ,
            maxZ: maxZ,
            coordinate: .init(x: minX, y: minY, z: minZ)
        )
    }
}

extension Coordinate3D: CustomStringConvertible {
    public var description: String {
        "\(x),\(y),\(z)"
    }
}

//extension InfiniteGrid3D: CustomStringConvertible where Element: CustomStringConvertible {
//    public var description: String {
//        var result = ""
//        for (y, x) in product(minY..<maxY, minX..<maxX) {
//            result.append( self[.init(x: x, y: y)].description )
//
//            if x == maxX - 1 {
//                result.append("\n")
//            }
//        }
//        return result
//    }
//}
