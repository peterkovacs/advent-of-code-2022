import ArgumentParser
import Algorithms

fileprivate extension String.Element {
    var value: Int {
        switch self {
        case "a"..."z": return Int(self.asciiValue! - ("a" as Character).asciiValue! + 1)
        case "A"..."Z": return Int(self.asciiValue! - ("A" as Character).asciiValue! + 27)
        default: fatalError()
        }
    }
}

struct Day3: ParsableCommand {
    func run() {
        let input = stdin.map(Array.init)

        let part1 = input.flatMap {
            let a = Set($0[0..<$0.count/2])
            let b = Set( $0[($0.count/2)...] )
            return a.intersection(b).map(\.value)
        }.reduce(0, +)
        
        print(part1)
        
        let part2 = input.indices.striding(by: 3).flatMap {
            let a = Set(input[$0])
            let b = Set(input[$0 + 1])
            let c = Set(input[$0 + 2])
            
            return a.intersection(b).intersection(c).map(\.value)
        }.reduce(0, +)
        
        print(part2)
    }
}
