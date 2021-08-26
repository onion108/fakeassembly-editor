//
//  ConsoleController.swift
//  FakeAssembly
//
//  Created by Harry Potter on 2021/7/15.
//

import Cocoa

class ConsoleController: NSViewController, VirtualDisplay {
    func setCharAt(x: Int, y: Int, ch: Character) {
        if y >= _buffer.count {
            _buffer.append(" " * 80)
            setCharAt(x: x, y: y, ch: ch)
        }
        if x >= (_buffer[0].count) {
            return
        }
        var arr = Array(_buffer[y])
        arr[x] = ch
        _buffer[y] = String(arr)
        flushView()
    }
    
    func getBuffer() -> [String] {
        return _buffer
    }
    
    func setBuffer(buffer: [String]) {
        //
    }
    
    func clearBuffer() {
        //
    }
    
    var _buffer: [String] = Array<String>(repeating: String(repeating: " ", count: 80), count: 25)
    @IBOutlet var content: NSTextView!
    
    private func flushView() {
        content.string = ""
        for i in _buffer {
            content.string += "\(i)\n"
        }
        content.font = NSFont(name: "Menlo", size: 12.0)
        content.textColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        content.string = ""
        for i in _buffer {
            content.string += "\(i)\n"
        }
        content.font = NSFont(name: "Menlo", size: 12.0)
        content.textColor = .white
    }
    
    
}
