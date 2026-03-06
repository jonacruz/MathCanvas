//
//  Lexer.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 04/03/26.
//

import Foundation

struct Lexer {
    private let input: [Character]
    private var pos: Int = 0
    
    init(_ source: String) {
        self.input = Array(source)
    }
    
    mutating func tokenize() throws -> [Token] {
        var tokens: [Token] = []
        
        while pos < input.count {
            let char = input[pos]
            
            switch char {
            case " ": // Ignore spacing
                pos += 1
            case "+": tokens.append(.plus);         pos += 1
            case "-": tokens.append(.minus);        pos += 1
            case "*": tokens.append(.multiply);     pos += 1
            case "/": tokens.append(.divide);       pos += 1
            case "^": tokens.append(.caret);        pos += 1
            case "=": tokens.append(.equals);       pos += 1
            case "(": tokens.append(.leftParen);    pos += 1
            case ")": tokens.append(.rightParen);   pos += 1
            case ",": tokens.append(.comma);        pos += 1
                
            case "0"..."9", ".":
                tokens.append(try readNumber())
            case "a"..."z", "A"..."Z":
                tokens.append(readWord())
            default:
                throw LexerError.unexpectedCharacter(char, pos)
            }
        }
        
        tokens.append(.end)
        return tokens
    }
    
    // Read number include decimals
    private mutating func readNumber() throws -> Token {
        var raw =  ""
        
        while pos < input.count, input[pos].isNumber || input[pos] == "." {
            raw.append(input[pos])
            pos += 1
        }
        
        guard let value = Double(raw) else {
            throw LexerError.invalidNumber(raw)
        }
        
        return .number(value)
    }
    
    // Read a word can be variable (x) or function(sqrt)
    private mutating func readWord() -> Token {
        var raw = ""
        
        while pos < input.count, input[pos].isLetter || input[pos].isNumber {
            raw.append(input[pos])
            pos += 1
        }
        
        // if has more than one character is a function
        let knownFunctions: Set<String> = ["sqrt", "frac", "mfrac", "sin", "cos", "tan", "log"]
        if knownFunctions.contains(raw) {
            return .function(raw)
        }
        
        return .variable(raw)
    }
}
