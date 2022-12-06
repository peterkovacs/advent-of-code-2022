import ArgumentParser
import Algorithms

struct Day6: ParsableCommand {
    @Argument var count = 4
    
    func run() {
        let input = allInput
        let signal = input.windows(ofCount: count).enumerated().first { a in
            Set(a.element).count == count
        }!.offset + count
        
        print("signal @", signal)
    }
}
