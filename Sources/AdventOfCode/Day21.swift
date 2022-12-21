import ArgumentParser
import Parsing

fileprivate enum Expr {
    case const(Int)
    case op(String, String, String, (Int, Int) -> Int)
    
    static var parser = OneOf {
        Int.parser().map(Expr.const)

        Parse {
            Expr.op(String($0.0), String($0.1), "+", +)
        } with: {
            Prefix(4)
            " + "
            Prefix(4)
        }
        
        Parse {
            Expr.op(String($0.0), String($0.1), "*", *)
        } with: {
            Prefix(4)
            " * "
            Prefix(4)
        }

        Parse {
            Expr.op(String($0.0), String($0.1), "-", -)
        } with: {
            Prefix(4)
            " - "
            Prefix(4)
        }
        
        Parse {
            Expr.op(String($0.0), String($0.1), "/", /)
        } with: {
            Prefix(4)
            " / "
            Prefix(4)
        }
    }
}

fileprivate enum Simpl: CustomStringConvertible {
    case const(Int)
    case variable(String)
    indirect case expr(Simpl, Simpl, String, (Int, Int) -> Int)
    
    var description: String {
        switch self {
        case let .const(a): return "\(a)"
        case let .variable(a): return a
        case let .expr(a, b, op, _): return "(\(a.description) \(op) \(b.description))"
        }
    }
    
    mutating func invert(rhs: Simpl) -> Simpl {
        guard case .const(let int) = rhs else {
            fatalError()
        }

        switch self {
        case let .expr(newSelf, .const(val), "+", _):
            self = newSelf
            return .const(int - val)
        case let .expr(newSelf, .const(val), "-", _):
            self = newSelf
            return .const(int + val)
        case let .expr(newSelf, .const(val), "*", _):
            self = newSelf
            return .const(int / val)
        case let .expr(newSelf, .const(val), "/", _):
            self = newSelf
            return .const(int * val)

        case let .expr(.const(val), newSelf, "+", _):
            self = newSelf
            return .const(int - val)
        case let .expr(.const(val), newSelf, "-", _):
            self = newSelf
            return .const(val - int)
        case let .expr(.const(val), newSelf, "*", _):
            self = newSelf
            return .const(int / val)
        case let .expr(.const(val), newSelf, "/", _):
            self = newSelf
            return .const(val / int)

        default:
            fatalError()

        }
    }
}

extension Dictionary where Key == String, Value == Expr {
    func evaluate(_ named: String) -> Int {
        switch self[named]! {
        case let .const(val): return val
        case let .op(a, b, _, op): return op(evaluate(a), evaluate(b))
        }
    }
    
    func simplify(_ named: String) -> Simpl {
        guard named != "humn" else { return .variable("humn") }
        switch self[named]! {
        case let .const(val):
            return .const(val)
        case let .op(a, b, opStr, op):
            let simplA = simplify(a)
            let simplB = simplify(b)
            
            switch (simplA, simplB) {
            case let (.const(constA), .const(constB)):
                return .const(op(constA, constB))
            default:
                return .expr(simplA, simplB, opStr, op)
            }
        }
    }
}

struct Day21: ParsableCommand {
    func run() throws {
        let expressions = try Dictionary(uniqueKeysWithValues: Many {
            Prefix(4).map(.string)
            ": "
            Expr.parser
        } separator: {
            Whitespace(.vertical)
        } terminator: {
            Whitespace(.vertical)
            End()
        }.parse(allInput) )
        
        print("part 1", expressions.evaluate("root"))

        guard case let .op(lhs, rhs, _, _) = expressions["root"]! else { fatalError() }
        var equal1 = expressions.simplify(lhs)
        var equal2 = expressions.simplify(rhs)
        
        while case .expr = equal1 {
            equal2 = equal1.invert(rhs: equal2)
        }
        
        print("part 2", equal2)
    }
}
