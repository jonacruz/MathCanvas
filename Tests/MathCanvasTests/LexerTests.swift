//
//  LexerTests.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 05/03/26.
//

import Testing
@testable import MathCanvas

@Suite("Lexer")
struct LexerTests {

    @Test func basicExpression() throws {
        var lexer = Lexer("x^2 + y^2 = 25")
        let tokens = try lexer.tokenize()
        #expect(tokens == [
            .variable("x"), .caret, .number(2),
            .plus,
            .variable("y"), .caret, .number(2),
            .equals, .number(25),
            .end
        ])
    }

    @Test func fraction() throws {
        var lexer = Lexer("frac(1,2)")
        let tokens = try lexer.tokenize()
        #expect(tokens == [
            .function("frac"), .leftParen, .number(1), .comma, .number(2), .rightParen,
            .end
        ])
    }

    @Test func negativeUnary() throws {
        var lexer = Lexer("-x")
        let tokens = try lexer.tokenize()
        #expect(tokens == [.minus, .variable("x"), .end])
    }

    @Test func decimalNumber() throws {
        var lexer = Lexer("3.14")
        let tokens = try lexer.tokenize()
        #expect(tokens == [.number(3.14), .end])
    }

    @Test func tanFunction() throws {
        var lexer = Lexer("tan(x)")
        let tokens = try lexer.tokenize()
        #expect(tokens == [.function("tan"), .leftParen, .variable("x"), .rightParen, .end])
    }

    @Test func logFunction() throws {
        var lexer = Lexer("log(x)")
        let tokens = try lexer.tokenize()
        #expect(tokens == [.function("log"), .leftParen, .variable("x"), .rightParen, .end])
    }

    @Test func mixedFraction() throws {
        var lexer = Lexer("mfrac(1,1,2)")
        let tokens = try lexer.tokenize()
        #expect(tokens == [
            .function("mfrac"), .leftParen,
            .number(1), .comma, .number(1), .comma, .number(2),
            .rightParen,
            .end
        ])
    }

    @Test func unexpectedCharacter() {
        var lexer = Lexer("x @ y")
        #expect(throws: (any Error).self) {
            try lexer.tokenize()
        }
    }
}
