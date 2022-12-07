import ArgumentParser
import Parsing

fileprivate enum Token {
    case ls
    case dir(name: String)
    case file(size: Int, name: String)
    case cd(name: String)
    case cdup
    
    static let parser = Parse {
        OneOf {
            Parse { "$ cd .." }.map { _ in Token.cdup }
            Parse {
                "$ cd "
                Rest()
            }.map { Token.cd(name: String($0)) }
            Parse { "$ ls" }.map { _ in Token.ls }
            
            Parse {
                "dir "
                Rest()
            }.map { Token.dir(name: String($0)) }
            Parse {
                Int.parser()
                " "
                Rest()
            }.map { Token.file(size: $0, name: String($1)) }
        }
    }
}



struct Day7: ParsableCommand {
    fileprivate func part1(commands: [Token]) -> [String:Int] {
        var dir = [String]()
        var sizes = [String:Int]()
        
        for i in commands {
            switch i {
            case .ls: break
            case .dir(name: _): break
            case .file(size: let size, name: _):
                for i in dir.indices {
                    sizes[
                        dir[ dir.startIndex...i ].joined(separator: "/"),
                        default: 0
                    ] += size
                }
                
            case .cd(name: let name):
                dir.append(name)
            case .cdup:
                dir.removeLast()
            }
        }
        
        print("Part 1", sizes.values.filter { $0 < 100000 }.reduce(0, +))
        return sizes
    }
    
    func part2(sizes: [String:Int]) {
        let availableSpace = 70000000 - sizes["/"]!
        let targetSpace = 30000000
        
        let value = sizes.filter {
            $0.value > targetSpace - availableSpace
        }.min { $0.value < $1.value }?.value
        print("Part 2", value!)
    }
    
    func run() throws {
        let commands = try stdin.map { try Token.parser.parse($0) }
        let sizes = part1(commands: commands)
        part2(sizes: sizes)
    }
}
