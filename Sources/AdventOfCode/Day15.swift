import ArgumentParser
import Parsing
import Algorithms

// Sensor at x=2899860, y=3122031: closest beacon is at x=2701269, y=3542780

fileprivate let parser = Parse {
    Parse(Coordinate.init) {
        "Sensor at x="
        Int.parser()
        ", y="
        Int.parser()
    }
    
    Parse(Coordinate.init) {
        ": closest beacon is at x="
        Int.parser()
        ", y="
        Int.parser()
    }
}

fileprivate extension Range where Bound: Comparable {
    func intersection(with other: Self) -> Self {
        .init(
            uncheckedBounds: (
                lower: Swift.max(lowerBound, other.lowerBound),
                upper: Swift.min(upperBound, other.upperBound)
            )
        )
    }
}

fileprivate extension ArraySlice where Element == Range<Int> {
    func alreadyIncluded(_ other: Range<Int>) -> Int {
        guard let last = last else { return 0 }
        let intersection = other.intersection(with: last)
        
        if !intersection.isEmpty {
            return (
                // If we're intersecting with a range, include it.
                intersection.count -
                // But don't include the range that is already included earlier.
                dropLast().alreadyIncluded(intersection) +
                // Recurse -- include the range that intersects with earlier commands.
                dropLast().alreadyIncluded(other)
            )
        }
        
        return dropLast().alreadyIncluded(other)
    }
}


struct Day15: ParsableCommand {
    @Option var Y: Int = 2000000
    @Option var range: Int = 4000000
    
    func notClear(coordinates: [(Coordinate, Coordinate)], y: Int) -> Int {
        // abs(x - sensor.x) + abs(y - sensor.y) <= sensor.distance, y = 2000000
        // abs(x - sensor.x) <= sensor.distance - abs(y - sensor.y)
        // eliminate anything with: sensor.distance - abs(y - sensor.y) < 0
        // -(sensor.distance - abs(y - sensor.y)) + sensor.x <= x <= (sensor.distance - abs(y - sensor.y)) + sensor.x
        
        let beacons = Set(coordinates.map(\.1).filter { $0.y == y })
        
        return coordinates
            .map { (sensor: $0.0, distance: $0.0.distance(to: $0.1)) }
            .filter { $0.distance - abs(y - $0.sensor.y) >= 0 }
            .map {
                Range(
                    uncheckedBounds:
                        (
                            lower: -($0.distance - abs(y - $0.sensor.y)) + $0.sensor.x,
                            upper: ($0.distance - abs(y - $0.sensor.y)) + $0.sensor.x + 1
                        )
                )
            }
            .reduce(into: (0, [Range<Int>]())) { result, range in
                result.0 += range.count
                result.0 -= result.1[...].alreadyIncluded(range)
                result.1.append(range)
            }
            .0 - beacons.count
    }
    
    func part2(coordinates: [(Coordinate, Coordinate)]) -> Int {
        for y in 0...range {
            let ranges = coordinates
                .map { (sensor: $0.0, distance: $0.0.distance(to: $0.1)) }
                .filter { $0.distance - abs(y - $0.sensor.y) >= 0 }
                .map {
                    Range(
                        uncheckedBounds:
                            (
                                lower: -($0.distance - abs(y - $0.sensor.y)) + $0.sensor.x,
                                upper: ($0.distance - abs(y - $0.sensor.y)) + $0.sensor.x + 1
                            )
                    )
                }
            
            var x = 0
            while x <= range {
                guard let nextX = ranges.filter({ $0.contains(x) }).map(\.upperBound).max()
                else {
                    return x * 4000000 + y
                }
                
                x = nextX
            }
        }
        
        fatalError()
    }
    
    func run() throws {
        let input = try stdin.map { try parser.parse($0) }
        print("part 1", notClear(coordinates: input, y: Y))
        print("part 2", part2(coordinates: input))
    }
}
