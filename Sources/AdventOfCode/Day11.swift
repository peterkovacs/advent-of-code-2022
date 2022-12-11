import ArgumentParser
import Parsing
import Algorithms

fileprivate struct Monkey {
    var id: Int
    var items: [Int]
    let operation: (Int) -> Int
    let divisor: Int
    let destination: (Int, Int)
    var count: Int = 0
    
    static let parser = Parse {
        Monkey(id: $0.0, items: $0.1, operation: $0.2, divisor: $0.3, destination: $0.4)
    } with: {
        Parse {
            "Monkey "
            Int.parser()
            ":\n"
        }
        
        Parse {
            Whitespace()
            "Starting items: "
            Many { Int.parser() } separator: { ", " } terminator: { "\n" }
        }
        
        Parse {
            Whitespace()
            "Operation: new = "
            OneOf {
                Parse { val in { old in old * val } } with: {
                    "old * "
                    Int.parser()
                }
                Parse { { old in old * old } } with: {
                    "old * old"
                }
                Parse { val in { old in old + val } } with: {
                    "old + "
                    Int.parser()
                }
            }
            "\n"
        }
        
        Parse {
            Whitespace()
            "Test: divisible by "
            Int.parser()
            Whitespace(.vertical)
        }
        
        Parse {
            Whitespace()
            "If true: throw to monkey "
            Int.parser()
            Whitespace(.all)
            "If false: throw to monkey "
            Int.parser()
            "\n"
        }
    }
}

struct Day11: ParsableCommand {
    fileprivate func part1(monkeys: [Monkey]) {
        var monkeys = monkeys
        for _ in 0..<20 {
            for i in monkeys.indices {
                monkeys[i].count += monkeys[i].items.count
                let items = monkeys[i].items.map {
                    monkeys[i].operation($0) / 3
                }
                monkeys[i].items = []
                for item in items {
                    monkeys[
                        (item % monkeys[i].divisor) == 0 ? monkeys[i].destination.0 :
                            monkeys[i].destination.1
                    ].items.append(item)
                }
            }
        }
        
        print(
            "part 1",
            monkeys.max(
                count: 2
            ) { $0.count < $1.count }
                .map(\.count)
                .reduce(1, *)
        )
    }
    
    fileprivate func part2(monkeys: [Monkey]) {
        var monkeys = monkeys
        let multiple = monkeys.map(\.divisor).reduce(1, *)
        for _ in 0..<10000 {
            for i in monkeys.indices {
                monkeys[i].count += monkeys[i].items.count
                let items = monkeys[i].items.map {
                    monkeys[i].operation($0) % multiple
                }
                monkeys[i].items = []
                for item in items {
                    monkeys[
                        (item % monkeys[i].divisor) == 0 ? monkeys[i].destination.0 :
                            monkeys[i].destination.1
                    ].items.append(item)
                }
            }
        }
        
        print(
            "part 2",
            monkeys.max(
                count: 2
            ) { $0.count < $1.count }
                .map(\.count)
                .reduce(1, *)
        )
    }
    
    func run() throws {
        let monkeys = try Many {
            Monkey.parser
        } separator: {
            Whitespace(.vertical)
        } terminator: {
            End()
        }.parse(allInput)
        
        part1(monkeys: monkeys)
        part2(monkeys: monkeys)
    }
}
