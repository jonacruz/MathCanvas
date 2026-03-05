//
//  Parser.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 05/03/26.
//

import Foundation

struct Parser {
    private var tokens: [Token]
    private var pos: Int = 0
    private var current: Token {
        tokens[pos]
    }
    
    init(tokens: [Token]) {
        self.tokens = tokens
    }
    
    private mutating func consume() -> Token {
        let token = tokens[pos]
        pos += 1
        return token
    }
    
    private mutating func expect(_ token: Token) throws {
        guard current == token else {
            throw ParserError.expected(token, got: current)
        }
        pos += 1
    }
    
    // MARK: - Entry point

    mutating func parse() throws -> ASTNode {
        let node = try parseEquals()
        guard current == .end else {
            throw ParserError.unexpectedToken(current)
        }
        return node
    }
    
    // MARK: - Precedencia (de menor a mayor)

    // Nivel 1: =
    private mutating func parseEquals() throws -> ASTNode {
        var left = try parseAddSub()
        if case .equals = current {
            _ = consume()
            let right = try parseAddSub()
            left = .equals(left, right)
        }
        return left
    }
    
    // Nivel 2: + -
    private mutating func parseAddSub() throws -> ASTNode {
        var left = try parseMulDiv()
        while true {
            switch current {
            case .plus:
                _ = consume()
                left = .add(left, try parseMulDiv())
            case .minus:
                _ = consume()
                left = .subtract(left, try parseMulDiv())
            default:
                return left
            }
        }
    }
    
    // Nivel 3: * /
    private mutating func parseMulDiv() throws -> ASTNode {
        var left = try parsePower()
        while true {
            switch current {
            case .multiply:
                _ = consume()
                left = .multiply(left, try parsePower())
            case .divide:
                _ = consume()
                left = .divide(left, try parsePower())
            default:
                return left
            }
        }
    }
    
    // Nivel 4: ^ (right-associative)
    private mutating func parsePower() throws -> ASTNode {
        let base = try parseUnary()
        if case .caret = current {
            _ = consume()
            let exp = try parsePower()  // recursivo → right-associative
            return .power(base, exp)
        }
        return base
    }
    
    // Nivel 5: unario -
    private mutating func parseUnary() throws -> ASTNode {
        if case .minus = current {
            _ = consume()
            return .negate(try parseUnary())
        }
        return try parsePrimary()
    }
    
    // Nivel 6: valores y funciones
    private mutating func parsePrimary() throws -> ASTNode {
        switch current {
        case .number(let val):
            _ = consume()
            return .number(val)

        case .variable(let name):
            _ = consume()
            return .variable(name)

        case .leftParen:
            _ = consume()
            let node = try parseAddSub()
            try expect(.rightParen)
            return node

        case .function(let name):
            _ = consume()
            return try parseFunction(name)

        default:
            throw ParserError.unexpectedToken(current)
        }
    }
    
    // Parsea argumentos de funciones
    private mutating func parseFunction(_ name: String) throws -> ASTNode {
        try expect(.leftParen)
        switch name {
        case "sqrt":
            let arg = try parseAddSub()
            try expect(.rightParen)
            return .sqrt(arg)
        case "frac":
            let num = try parseAddSub()
            try expect(.comma)
            let den = try parseAddSub()
            try expect(.rightParen)
            return .frac(numerator: num, denominator: den)
        case "sin":
            let arg = try parseAddSub()
            try expect(.rightParen)
            return .sin(arg)
        case "cos":
            let arg = try parseAddSub()
            try expect(.rightParen)
            return .cos(arg)
        default:
            throw ParserError.unknownFunction(name)
        }
    }
}
