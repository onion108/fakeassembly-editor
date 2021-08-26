//
//  ViewController.swift
//  FakeAssembly
//
//  Created by Harry Potter on 2021/7/15.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var contentField: NSScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        (contentField.contentView.documentView as! NSTextView).isAutomaticQuoteSubstitutionEnabled = false
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    @IBAction func onExecute(_ sender: Any) {
    }
    func execute(_ display: VirtualDisplay) {
        let _c: String = (contentField.contentView.documentView as! NSTextView).string
        print(_c)
        ExecutingModel(outDevice: display).execute(fakeAsm: _c)
    }
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let cc = (segue.destinationController as! NSWindowController).contentViewController as? ConsoleController
        execute(cc!)
    }
    

}

