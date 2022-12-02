import ArgumentParser

struct Day2: ParsableCommand {
    enum Shape: UInt8 {
        case rock = 1 // lose
        case paper = 2 // draw
        case scissors = 3 // win
    }

    func run() {
        let input = stdin.map {
            let row = $0.split(separator: #/\s/#).compactMap { $0.first?.asciiValue }
            return (Shape(rawValue: row[0] - ("A" as Character).asciiValue! + 1)!, Shape(rawValue: row[1] - ("X" as Character).asciiValue! + 1)!)
        }
        
        let part1 = input.map(value)
        print(part1.reduce(0, +))
        
        let part2 = input.map(value2)
        print(part2.reduce(0, +))

    }
    
    func value(x: Shape, y: Shape) -> Int {
        switch (x, y) {
        case let (x, y) where x == y:
            return 3 + Int(y.rawValue)
        case let (x, y) where y == win(x: x):
            return 6 + Int(y.rawValue)
        case let (_, y):
            return 0 + Int(y.rawValue)
        }
    }
    
    func value2(x: Shape, y: Shape) -> Int {
        switch y {
        case .rock: return 0 + Int(lose(x: x).rawValue)
        case .paper: return 3 + Int(x.rawValue)
        case .scissors: return 6 + Int(win(x: x).rawValue)
        }
    }
    
    func lose(x: Shape) -> Shape {
        return Shape(rawValue: ((x.rawValue + 1) % 3) + 1)!
    }
    
    func win(x: Shape) -> Shape {
        return Shape(rawValue: ((x.rawValue + 3) % 3) + 1)!
    }
}
