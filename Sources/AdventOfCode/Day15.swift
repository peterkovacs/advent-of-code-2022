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

extension Coordinate {
    func neighbors(atDistance distance: Int) -> [Coordinate] {
        var x = self.go(in: \.up, distance)
        var result = [x]

        (1...distance).forEach { _ in
            x = x.down.right
            result.append(x)
        }
        (1...distance).forEach { _ in
            x = x.down.left
            result.append(x)
        }
        
        (1...distance).forEach { _ in
            x = x.up.left
            result.append(x)
        }
        (1..<distance).forEach { _ in
            x = x.up.right
            result.append(x)
        }
        
        return result
    }
}

struct Day15: ParsableCommand {
    @Option var Y: Int = 2000000
    @Option var range: Int = 4000000
    
    func part1(coordinates: [(Coordinate, Coordinate)], y: Int) -> Int {
        // abs(x - sensor.x) + abs(y - sensor.y) <= sensor.distance, y = 2000000
        // abs(x - sensor.x) <= sensor.distance - abs(y - sensor.y)
        // eliminate anything with: sensor.distance - abs(y - sensor.y) < 0
        // -(sensor.distance - abs(y - sensor.y)) + sensor.x <= x <= (sensor.distance - abs(y - sensor.y)) + sensor.x
        
        let beacons = Set(coordinates.map(\.1).filter { $0.y == y })
        
        let ranges: [Range<Int>] = coordinates
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
            .sorted {
                $0.lowerBound < $1.lowerBound
            }
            
        var count = ranges[0].count
        var x = ranges[0].upperBound
        for i in ranges.dropFirst() {
            if i.contains(x) {
                count += (x..<i.upperBound).count
                x = i.upperBound
            } else if x < i.lowerBound {
                x = i.lowerBound
            }
        }

        return count - beacons.count
    }

    func part2(coordinates: [(Coordinate, Coordinate)]) -> Int {
        let distances = coordinates.map {
            (sensor: $0.0, distance: $0.0.distance(to: $0.1))
        }
        
        let point = distances.lazy.flatMap {
            $0.sensor.neighbors(atDistance: $0.distance + 1).filter {
                $0.isValid(x: range, y: range)
            }
        }.first { coordinate in
            distances.allSatisfy { $0.sensor.distance(to: coordinate) > $0.distance }
        }!
        
        return point.x * 4000000 + point.y
    }
    
    func run() throws {
        let input = try stdin.map { try parser.parse($0) }

        print("part 1", part1(coordinates: input, y: Y))
        print("part 2", part2(coordinates: input))
    }
}
