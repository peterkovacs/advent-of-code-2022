//
//  File.swift
//  
//
//  Created by Peter Kovacs on 12/20/21.
//

import Foundation
import Algorithms

public struct InfiniteGrid<T>: Sequence {
    public typealias Element = T
    public private(set) var grid: [Coordinate: Element]
    public private(set) var minX, minY, maxX, maxY: Int
    let defaultValue: Element
    
    public init<S>(
        _ s: S,
        minX: Int = 0,
        minY: Int = 0,
        maxX: Int,
        maxY: Int = 0,
        defaultValue: Element
    ) where S: Sequence, S.Element == Element
    {
        (self.minX, self.minY, self.maxX, self.maxY) = (minX, minY, maxX, maxY)
        self.defaultValue = defaultValue
        self.grid = .init(
            uniqueKeysWithValues: zip(
                CoordinateIterator(
                    minX: minX,
                    maxX: maxX,
                    minY: minY,
                    maxY: Int.max,
                    coordinate: .init(x: minX, y: minY)
                ),
                s
            )
        )
        if let max = grid.keys.max() {
            setBounds( max )
        }
    }
    
    public subscript( _ c: Coordinate ) -> Element {
        get {
            return grid[c, default: defaultValue]
        }
        set {
            setBounds(c)
            grid[c] = newValue
        }
    }
    
    mutating public func setBounds(_ c: Coordinate) {
        minX = Swift.min(minX, c.x)
        maxX = Swift.max(maxX, c.x + 1)
        minY = Swift.min(minY, c.y)
        maxY = Swift.max(maxY, c.y + 1)
    }
    
    mutating public func setBounds(minX: Int, maxX: Int, minY: Int, maxY: Int) {
        self.minX = minX
        self.maxX = maxX
        self.minY = minY
        self.maxY = maxY
    }
    
    public struct CoordinateIterator: IteratorProtocol, Sequence {
        let minX, maxX, minY, maxY: Int
        var coordinate: Coordinate
        
        public mutating func next() -> Coordinate? {
            if !coordinate.isValid(minX: minX, x: maxX, minY: minY, y: maxY) {
                coordinate = Coordinate(x: minX, y: coordinate.y + 1)
            }
            guard coordinate.isValid(minX: minX, x: maxX, minY: minY, y: maxY) else { return nil }
            defer { coordinate = coordinate.right }

            return coordinate
        }
    }
    
    public struct Iterator: IteratorProtocol {
        let grid: InfiniteGrid
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
            coordinate: .init(x: minX, y: minY)
        )
    }

}

extension InfiniteGrid: CustomStringConvertible where Element: CustomStringConvertible {
    public var description: String {
        var result = ""
        for (y, x) in product(minY..<maxY, minX..<maxX) {
            result.append( self[.init(x: x, y: y)].description )

            if x == maxX - 1 {
                result.append("\n")
            }
        }
        return result
    }
}
