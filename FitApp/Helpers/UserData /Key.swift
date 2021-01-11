//
//  Key.swift
//  FitApp
//
//  Created by iOS Bthere on 08/01/2021.
//

import Foundation


struct Key: RawRepresentable {
    let rawValue: String
}

extension Key: ExpressibleByStringLiteral {
    init(stringLiteral: String) {
        rawValue = stringLiteral
    }
}
