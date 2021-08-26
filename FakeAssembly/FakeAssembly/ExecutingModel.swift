//
//  ExecutingModel.swift
//  FakeAssembly
//
//  Created by Harry Potter on 2021/7/15.
//

import Foundation

protocol VirtualDisplay {
    func setCharAt(x: Int, y: Int, ch: Character)
    func getBuffer() -> [String]
    func setBuffer(buffer: [String])
    func clearBuffer()
}

public struct StateFlags {
    public var equ: Bool
    public var gt: Bool
    public var lt: Bool
    
    mutating func clear() {
        equ = false
        gt = false
        lt = false
    }
}

class ExecutingModel {
    private var pc: Int = 0
    private var symbolTable: Dictionary<String, String> = [
        "__version__": "2"
    ]
    private var __stdout: VirtualDisplay
    private var flags: StateFlags = StateFlags(equ: false, gt: false, lt: false)
    private var stack: [Int] = []
    private var callStack: [Int] = []
    
    init(outDevice: VirtualDisplay) {
        __stdout = outDevice
    }
    
    private func justDoNothing() {}
    
    func tokenize(_ line: String) -> [String] {
        var result: [String] = []
        var cur: String = ""
        for ch in line {
            if (ch == Character(" ")) && (cur != "") {
                result.append(cur)
                cur = ""
                continue
            }
            if (ch == Character(" ")) && (result.isEmpty) {
                continue
            }
            cur.append(ch)
        }
        if cur != "" {
            result.append(cur)
            cur = ""
        }
        
        for i in result.enumerated() {
            if i.element.first == "#" {
                // Replace symbol with its value
                result[i.offset] = "\(symbolTable[String(i.element.suffix(i.element.count - 1))] ?? "undefined")"
            }
        }
        
        return result
    }
    
    func execute(fakeAsm content: String) {
        let codes: [String.SubSequence] = content.split(separator: "\n")
        // Scan all labels
        var linecode = 0
        while linecode < codes.count {
            let tokens = tokenize(String(codes[linecode]))
            if tokens[0] == "label" {
                // A label symbol, and maybe is global, so should record it BEFORE the script really runs
                print("here: \(tokens[0]) \(tokens[1])")
                if tokens.count == 2 {
                    symbolTable[tokens[1]] = "\(linecode + 1)"
                    // Avoid infinite loop
                }
            }
            linecode += 1
        }
        while pc < codes.count {
            let line = codes[pc]
            let curlineStr = String(line)
            if curlineStr.first != "@" { // Is a normal statement
                let tokens = tokenize(curlineStr)
//                print("Tokenized: \(tokens)")
                switch tokens[0] {
                case "setpc":
                    if tokens.count == 2 {
                        let __tmp = Int(tokens[1])
                        guard let __tmp = __tmp else {
                            print("Error: must be a int :\(tokens[1])")
                            return
                        }
                        pc = __tmp
                        continue
                    }
                case "dchar":
                    if tokens.count == 4 {
                        var __tmp: Character = "?"
                        if Array(tokens[1])[0] != "'" {
                            let __t = Int(tokens[1])
                            guard let __t = __t else {
                                print("Error: must be a int: \(tokens[1])")
                                return
                            }
                            __tmp = Character(Unicode.Scalar(__t) ?? "?")
                        } else if tokens[1].count == 3 && Array(tokens[1])[2] == "'" {
                            // Character Literal
                            __tmp = Array(tokens[1])[1]
                        }
                        let __x = Int(tokens[2])
                        guard let __x = __x else {
                            print("Error: must be a int")
                            return
                        }
                        let __y = Int(tokens[3])
                        guard let __y = __y else {
                            print("Error: must be a int")
                            return
                        }
                        __stdout.setCharAt(x: __x, y: __y, ch: __tmp)
                    }
                case "dint":
                    let __x = Int(tokens[2])
                    guard let __x = __x else {
                        print("Error: must be a int")
                        return
                    }
                    let __y = Int(tokens[3])
                    guard let __y = __y else {
                        print("Error: must be a int")
                        return
                    }
                    if tokens.count == 4 {
                        if tokens[1] == "undefined" {
                            var sx = __x
                            for __ec in "undefined" {
                                __stdout.setCharAt(x: sx, y: __y, ch: __ec)
                                sx += 1
                            }
                        } else {
                            if Int(tokens[1]) == nil {
                                print("Error: Must be a int")
                                return
                            }
                            var sx = __x
                            for __ec in tokens[1] {
                                __stdout.setCharAt(x: sx, y: __y, ch: __ec)
                                sx += 1
                            }
                        }
                    }
                case "dliteral":
                    if tokens.count == 4 {
                        let __x = Int(tokens[2])
                        guard let __x = __x else {
                            print("Error: must be a int")
                            return
                        }
                        let __y = Int(tokens[3])
                        guard let __y = __y else {
                            print("Error: must be a int")
                            return
                        }
                        var sx = __x
                        for __ec in tokens[1] {
                            __stdout.setCharAt(x: sx, y: __y, ch: __ec)
                            sx += 1
                        }
                    }
                case "symbol":
                    if tokens.count == 3 {
                        symbolTable[tokens[1]] = tokens[2]
                    }
                case "label":
                    // Processed before, just do nothing
                    justDoNothing()
                case "nop":
                    justDoNothing()
                case "cmp":
                    if tokens.count == 3 {
                        let __x = Int(tokens[1])
                        guard let __x = __x else {
                            print("Error: must be a int")
                            return
                        }
                        let __y = Int(tokens[2])
                        guard let __y = __y else {
                            print("Error: must be a int")
                            return
                        }
                        if __x == __y {
                            flags.equ = true
                        }
                        if __x > __y {
                            flags.gt = true
                        }
                        if __x < __y {
                            flags.lt = true
                        }
                    }
                case "clflags":
                    flags.clear()
                case "jmp":
                    if tokens.count == 2 {
                        let __tmp = Int(tokens[1])
                        guard let __tmp = __tmp else {
                            print("Error: must be a int :\(tokens[1])")
                            return
                        }
                        pc = __tmp
                        continue
                    }
                case "je":
                    if flags.equ {
                        if tokens.count == 2 {
                            let __tmp = Int(tokens[1])
                            guard let __tmp = __tmp else {
                                print("Error: must be a int :\(tokens[1])")
                                return
                            }
                            pc = __tmp
                            continue
                        }
                    }
                case "jg":
                    if flags.gt {
                        if tokens.count == 2 {
                            let __tmp = Int(tokens[1])
                            guard let __tmp = __tmp else {
                                print("Error: must be a int :\(tokens[1])")
                                return
                            }
                            pc = __tmp
                            continue
                        }
                    }
                case "jl":
                    if flags.lt {
                        if tokens.count == 2 {
                            let __tmp = Int(tokens[1])
                            guard let __tmp = __tmp else {
                                print("Error: must be a int :\(tokens[1])")
                                return
                            }
                            pc = __tmp
                            continue
                        }
                    }
                case "ics":
                    if tokens.count == 2 {
                        let __tmp = symbolTable[tokens[1]] // Get the content of the symbol
                        guard let __tmp = __tmp else {
                            print("Undefined symbol \(tokens[1])")
                            return
                        }
                        let __ti = Int(__tmp)
                        guard let __ti = __ti else {
                            print("Error: must be a int :\(__tmp)")
                            return
                        }
                        symbolTable[tokens[1]] = "\(__ti + 1)"
                    }
                case "dcs":
                    if tokens.count == 2 {
                        let __tmp = symbolTable[tokens[1]] // Get the content of the symbol
                        guard let __tmp = __tmp else {
                            print("Undefined symbol \(tokens[1])")
                            return
                        }
                        let __ti = Int(__tmp)
                        guard let __ti = __ti else {
                            print("Error: must be a int :\(__tmp)")
                            return
                        }
                        symbolTable[tokens[1]] = "\(__ti - 1)"
                    }
                case "push":
                    if tokens.count == 2 {
                        let __ti = Int(tokens[1])
                        guard let __ti = __ti else {
                            print("Error: must be a int :\(tokens[1])")
                            return
                        }
                        stack.append(__ti)
                    }
                case "pop":
                    if tokens.count == 2 {
                        let __tmp = stack.popLast()
                        if __tmp != nil {
                            symbolTable[tokens[1]] = "\(__tmp!)"
                        } else {
                            print("Stack is empty.")
                            return
                        }
                    }
                case "call":
                    if tokens.count == 2 {
                        let __ti = Int(tokens[1])
                        guard let __ti = __ti else {
                            print("Error: must be a int :\(tokens[1])")
                            return
                        }
                        callStack.append(pc)
                        pc = __ti
                    }
                case "ret":
                    if tokens.count == 1 {
                        let __newpc = callStack.popLast()
                        guard let __newpc = __newpc else {
                            print("Stack is empty")
                            return
                        }
                        pc = __newpc
                    } else if tokens.count == 2 {
                        symbolTable["__lastreturn__"] = tokens[1]
                        let __newpc = callStack.popLast()
                        guard let __newpc = __newpc else {
                            print("Stack is empty")
                            return
                        }
                        pc = __newpc
                    }
                default:
                    print("UNDEFINED>>>")
                }
            } else {
                if(Array(curlineStr)[1] == ";") {
                    pc += 1
                    continue  // Is a comment.
                }
            }
            // Increment the program counter
            pc += 1
        }
    }
}
