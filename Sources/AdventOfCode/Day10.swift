import ArgumentParser
import Parsing

fileprivate enum OP {
    case noop
    case addx(Int)
    
    static let parser = Many {
        OneOf {
            Parse { _ in (OP.noop, 1) } with: { "noop" }
            Parse { (OP.addx($0), 2) } with: {
                "addx "
                Int.parser()
            }
        }
    } separator: {
        Whitespace(.vertical)
    } terminator: {
        Whitespace(.vertical)
        End()
    }
}

fileprivate struct CPU {
    var instructions: [(OP, Int)]
    var x: Int = 1
    var ip: Array<OP>.Index
    var clock: Int
    var signal = 0

    private var ticks = 0
    
    init(instructions: [(OP, Int)]) {
        self.instructions = instructions
        self.x = 1
        self.ip = instructions.startIndex
        self.clock = 0
    }
    
    var isRunning: Bool {
        ip != instructions.endIndex
    }
    
    mutating func execute() -> Void {
        clock += 1
        instructions[ip].1 -= 1
        
        if (clock - 20) % 40 == 0 {
            signal += clock * x
        }
        
        switch instructions[ip] {
        case (.noop, 0):
            self.ip = ip.advanced(by: 1)
            
        case let (.addx(x), 0):
            self.ip = ip.advanced(by: 1)
            self.x += x
            
        default: break
        }
    }
    
    var display: [Bool] = .init(repeating: false, count: 240)
    mutating func scan() -> Void {
        if ((x-1)...(x+1)).contains(clock % 40) {
            display[clock] = true
        }

        execute()
    }
}


struct Day10: ParsableCommand {
    fileprivate func part1(instructions: [(OP, Int)]) {
        var cpu = CPU(instructions: instructions)
        
        while cpu.isRunning {
            cpu.execute()
        }
        
        print("part 1", cpu.signal)
    }
    
    fileprivate func part2(instructions: [(OP, Int)]) {
        var cpu = CPU(instructions: instructions)
        
        while cpu.isRunning {
            cpu.scan()
        }
        
        print(Grid(cpu.display, maxX: 40, maxY: 6)!.map { $0 ? "#" : " " })
    }
    
    func run() throws {
        let instructions = try OP.parser.parse(allInput)
        part1(instructions: instructions)
        part2(instructions: instructions)
    }
}
