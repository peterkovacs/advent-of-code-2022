import ArgumentParser
import Algorithms
import Collections

extension Array where Element == (index: Int, element: Int) {
    func calculate(index actualIndex: Int, value: Int) -> Int {
        if actualIndex + value > count {
            return (actualIndex + value) % count
        } else if (actualIndex + value) < 0 {
            var i = actualIndex + value
            i += count * (abs(i) / count) + count
            return i
        } else {
            return actualIndex + value
        }
    }
    
    func mix(index: Int) -> Self {
        let actualIndex = firstIndex { $0.index == index }!
        
        var result = self
        let value = result.remove(at: actualIndex)

        result.insert(value, at: result.calculate(index: actualIndex, value: value.element))
        return result
    }
}

struct Day20: ParsableCommand {
    func run() {
        let input = Array(stdin.compactMap(Int.init).indexed())

        do {
            let output = (0..<input.count).reduce(input) { $0.mix(index: $1) }
            let zeroIndex = output.firstIndex { $0.element == 0 }!
            
            let part1 = output[ (zeroIndex + 1000) % output.count ].element +
            output[ (zeroIndex + 2000) % output.count ].element +
            output[ (zeroIndex + 3000) % output.count ].element
            
            print("part 1", part1)
        }
        
        do {
            let output = (0..<10).reduce(input.map { (index: $0.index, element: $0.element * 811589153) }) { i, _ in
                (0..<input.count).reduce(i) { $0.mix(index: $1) }
            }
            let zeroIndex = output.firstIndex { $0.element == 0 }!
            
            let part2 = output[ (zeroIndex + 1000) % output.count ].element +
            output[ (zeroIndex + 2000) % output.count ].element +
            output[ (zeroIndex + 3000) % output.count ].element
            
            print("part 2", part2)

        }
    }
}
