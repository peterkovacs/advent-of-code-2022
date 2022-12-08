import ArgumentParser

fileprivate extension Grid where Element == (Int, Bool) {
    mutating func findVisible(size: Int) {
        for x in 0..<size {
            var max = -1
            for y in 0..<size {
                if self[x: x, y: y].0 > max {
                    self[x: x, y: y].1 = true
                    max = self[x: x, y: y].0
                }
            }
        }
    }
}
 
fileprivate extension Grid where Element == Int {
    func score(x: Int, y: Int) -> Int {
        var val = [0, 0, 0, 0]
        for i in (0..<x).reversed() {
            val[0] += 1
            if self[x: i, y: y] >= self[x: x, y: y] { break }
        }
        
        for i in (x+1)..<maxX {
            val[1] += 1
            if self[x: i, y: y] >= self[x: x, y: y] { break }
        }

        for i in (0..<y).reversed() {
            val[2] += 1
            if self[x: x, y: i] >= self[x: x, y: y] { break }
        }

        for i in (y+1)..<maxY {
            val[3] += 1
            if self[x: x, y: i] >= self[x: x, y: y] { break }
        }
        
        return val.reduce(1, *)
    }
}

struct Day8: ParsableCommand {
    func part1(input: [String]) {
        let size = input.count
        var grid = Grid(input.joined().map { (Int(String($0))!, false) }, maxX: input[0].count, maxY: input.count)!
        
        grid.findVisible(size: size)
        grid = grid.rotated
        grid.findVisible(size: size)
        grid = grid.rotated
        grid.findVisible(size: size)
        grid = grid.rotated
        grid.findVisible(size: size)
        grid = grid.rotated
        print("part 1", grid.filter(\.1).count)
    }
    
    func part2(input: [String]) {
        let size = input.count
        let grid = Grid(input.joined().map { Int(String($0))! }, maxX: size, maxY: size)!
        let part2 = grid.indices.map {
            grid.score(x: $0.x, y: $0.y)
        }.max()!
        
        print("part 2", part2)
    }
    func run() {
        let input = Array(stdin)
        
        part1(input: input)
        part2(input: input)
    }
}
