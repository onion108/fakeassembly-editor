//
//  Extensions.swift
//  FakeAssembly
//
//  Created by Harry Potter on 2021/7/16.
//

import Foundation

public extension String {
    static func *(_ me: String, _ rhs: Int) -> String {
        return String(repeating: me, count: rhs)
    }
}
