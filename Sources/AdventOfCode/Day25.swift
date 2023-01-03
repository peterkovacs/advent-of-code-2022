import ArgumentParser
import Algorithms

struct Snafu: Equatable, CustomStringConvertible {
    let rawValue: Int
    
    init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    init(string: String) {
        self.rawValue = string.reversed().reduce(into: (place: 1, value: 0)) { result, i in
            switch i {
            case "2":
                result.value += 2 * result.place
            case "1":
                result.value += result.place
            case "0": break
            case "-":
                result.value -= result.place
            case "=":
                result.value -= 2 * result.place
            default: fatalError()
            }
            
            result.place *= 5
        }.value
    }
    
    var description: String {
        guard rawValue > 0 else { return "0" }
        
        let result = (0...30)
            .reductions(into: 1) { i, _ in i *= 5 }
            .prefix { $0 < rawValue }
            .reversed()
            .map { place in Array((-2...2).map { place * $0 } ) }
            .reduce((string: "", value: rawValue)) { partialResult, value in
                let (index, val) = value.indexed().min { a, b in
                    abs(partialResult.value - a.element) < abs(partialResult.value - b.element)
                }!
                
                let digit: String
                switch index {
                case 0: digit = "="
                case 1: digit = "-"
                case 2: digit = "0"
                case 3: digit = "1"
                case 4: digit = "2"
                default: fatalError()
                }
                
                return (string: partialResult.string + digit, value: partialResult.value - val)
            }
        
        assert(result.value == 0)
        
        return result.string

    }
}

struct Day25: ParsableCommand {
    func run() {
        let values = stdin.map(Snafu.init(string:))
        let number = Snafu(rawValue: values.map(\.rawValue).reduce(0, +))
        
        print("sum", number.rawValue)
        print("part1", number)
    }
}
