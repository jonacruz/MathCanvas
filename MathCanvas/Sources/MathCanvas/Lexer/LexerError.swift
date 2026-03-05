//
//  LexerError.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 04/03/26.
//

import Foundation

enum LexerError: Error, CustomStringConvertible {
    case unexpectedCharacter(Character, Int)
    case invalidNumber(String)
    
    var description: String {
        switch self {
        case .unexpectedCharacter(let c, let pos):
            return "Unexpected character '\(c)' at index \(pos)"
        case .invalidNumber(let raw):
            return "Invalid number: \(raw)"
        }
    }
}
