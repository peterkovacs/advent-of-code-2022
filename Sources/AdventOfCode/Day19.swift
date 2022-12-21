import ArgumentParser
import Parsing
import Collections

// Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 18 clay. Each geode robot costs 4 ore and 8 obsidian.

import Foundation
extension Collection {
    func parallelMap<R>(_ transform: @escaping (Element) -> R) -> [R] {
        var res: [R?] = .init(repeating: nil, count: count)

        let lock = NSRecursiveLock()
        DispatchQueue.concurrentPerform(iterations: count) { i in
            let result = transform(self[index(startIndex, offsetBy: i)])
            lock.lock()
            res[i] = result
            lock.unlock()
        }

        return res.map({ $0! })
    }
}

struct Blueprint: Hashable {
    static func == (lhs: Blueprint, rhs: Blueprint) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    let id: Int
    let ore: Int
    let clay: Int
    let obsidian: (ore: Int, clay: Int)
    let geode: (ore: Int, obsidian: Int)
    
    static let parser = Parse(Blueprint.init) {
        "Blueprint "
        Int.parser()
        ":"
        Whitespace()
        "Each ore robot costs "
        Int.parser()
        " ore."
        Whitespace()
        "Each clay robot costs "
        Int.parser()
        " ore."
        Whitespace()
        Parse {
            "Each obsidian robot costs "
            Int.parser()
            " ore and "
            Int.parser()
            " clay."
        }
        Whitespace()
        
        Parse {
            "Each geode robot costs "
            Int.parser()
            " ore and "
            Int.parser()
            " obsidian."
        }
    }
}

struct Inventory: Hashable {
    let blueprint: Blueprint
    var ore = 0
    var clay = 0
    var obsidian = 0
    var geode = 0
    
    var oreRobot = 1
    var clayRobot = 0
    var obsidianRobot = 0
    var geodeRobot = 0
    
    mutating func buildOre() -> Bool {
        if ore >= blueprint.ore {
            ore -= blueprint.ore
            tick()
            oreRobot += 1
            return true
        } else {
            return false
        }
    }
    
    mutating func buildClay() -> Bool {
        if ore >= blueprint.clay {
            ore -= blueprint.clay
            tick()
            clayRobot += 1
            return true
        } else {
            return false
        }
    }
    
    mutating func buildObsidian() -> Bool {
        if ore >= blueprint.obsidian.ore &&
            clay >= blueprint.obsidian.clay
        {
            ore -= blueprint.obsidian.ore
            clay -= blueprint.obsidian.clay
            tick()
            obsidianRobot += 1
            return true
        } else {
            return false
        }
    }
    
    mutating func buildGeode() -> Bool {
        if obsidian >= blueprint.geode.obsidian &&
            ore >= blueprint.geode.ore
        {
            obsidian -= blueprint.geode.obsidian
            ore -= blueprint.geode.ore
            tick()
            geodeRobot += 1
            return true
        } else {
            return false
        }
        
    }
    
    mutating func tick() {
        ore += oreRobot
        clay += clayRobot
        obsidian += obsidianRobot
        geode += geodeRobot
    }
}

fileprivate struct State: Comparable {
    static func < (lhs: State, rhs: State) -> Bool {
        if lhs.inventory.geode == rhs.inventory.geode {
            return lhs.minutes < rhs.minutes
        } else {
            return lhs.inventory.geode < rhs.inventory.geode
        }
    }
    
    static func == (lhs: State, rhs: State) -> Bool {
        lhs.inventory == rhs.inventory && lhs.minutes == rhs.minutes
    }
    
    let inventory: Inventory
    let minutes: Int
}

fileprivate func bfs(inventory: Inventory, minutes: Int) -> Inventory {
    // Making more than the max of a blueprint would be wasted production.
    let oreLimit = [
        inventory.blueprint.clay,
        inventory.blueprint.ore,
        inventory.blueprint.obsidian.ore,
        inventory.blueprint.geode.ore
    ].max()!

    var visited = Set<Inventory>()
    
    // Using a heap to prioritize getting to a large value of max.geode so that our heuristic kicks in earlier.
    var queue = Heap<State>.init([ .init(inventory: inventory, minutes: minutes )])
    var max = inventory
    
    while !queue.isEmpty {
        let state = queue.popMax()!
        var (inventory, minutes) = (state.inventory, state.minutes)
        
        if minutes > 1 {

            // Does this blueprint have a hope of beating the current max even if we magically made a geodeRobot from here to the end?
            let hasHopeOfWinning = (
                (0..<minutes).reduce(inventory.geode) { $0 + inventory.geodeRobot + $1 } > max.geode
            )
            
            guard hasHopeOfWinning else { continue }

            do {
                var geode = inventory
                if geode.buildGeode() {
                    if visited.insert(geode).inserted {
                        queue.insert(.init(inventory: geode, minutes: minutes - 1))
                    }
                    continue // if we can build a geodeRobot, don't bother trying any other paths.
                }
            }
            do {
                var obsidian = inventory
                if obsidian.obsidianRobot < inventory.blueprint.geode.obsidian, obsidian.buildObsidian() {
                    if visited.insert(obsidian).inserted {
                        queue.insert(.init(inventory: obsidian, minutes: minutes - 1))
                    }
                }
            }
            do {
                var clay = inventory
                if clay.clayRobot < inventory.blueprint.obsidian.clay, clay.buildClay() {
                    if visited.insert(clay).inserted {
                        queue.insert(.init(inventory: clay, minutes: minutes - 1))
                    }
                }
            }
            do {
                var ore = inventory
                if ore.oreRobot < oreLimit, ore.buildOre() {
                    if visited.insert(ore).inserted {
                        queue.insert(.init(inventory: ore, minutes: minutes - 1))
                    }
                }
            }
            
            inventory.tick()
            if visited.insert(inventory).inserted {
                queue.insert(.init(inventory: inventory, minutes: minutes - 1))
            }
        } else {
            inventory.tick()
        }
        
        if inventory.geode > max.geode {
            max = inventory
        }
    }
    
    return max
    
}

struct Day19: ParsableCommand {
    func run() throws {
        let blueprints = try Many { Blueprint.parser } separator: {
            Whitespace(1...2, .vertical)
        } terminator: {
            Whitespace(0...1, .vertical)
            End()
        }
        .parse(allInput)
        
        let part1 = blueprints.parallelMap { bfs(inventory: Inventory(blueprint: $0), minutes: 24) }.map { $0.blueprint.id * $0.geode }.reduce(0, +)
        print("part 1", part1)
        
        
        let part2 = blueprints[0..<3].parallelMap { bfs(inventory: Inventory(blueprint: $0), minutes: 32).geode }.reduce(1, *)
        print("part 2", part2)

    }
}
