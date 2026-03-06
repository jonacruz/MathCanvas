//
// ParserTests.swift
//  MathCanvas
//
//  Created by Jonathan Abimael on 05/03/26.
//

import Testing
@testable import MathCanvas

@Suite("Parser")
struct ParserTests {

    private func parse(_ source: String) throws -> ASTNode {
        var lexer = Lexer(source)
        let tokens = try lexer.tokenize()
        var parser = Parser(tokens: tokens)
        return try parser.parse()
    }

    @Test func simpleEquation() throws {
        let ast = try parse("x^2 = 25")
        #expect(ast == .equals(.power(.variable("x"), .number(2)), .number(25)))
    }

    @Test func precedence() throws {
        // x + y * z debe ser x + (y * z)
        let ast = try parse("x + y * z")
        #expect(ast == .add(.variable("x"), .multiply(.variable("y"), .variable("z"))))
    }

    @Test func rightAssociativePower() throws {
        // 2^3^2 debe ser 2^(3^2)
        let ast = try parse("2^3^2")
        #expect(ast == .power(.number(2), .power(.number(3), .number(2))))
    }

    @Test func frac() throws {
        let ast = try parse("frac(1,2)")
        #expect(ast == .frac(numerator: .number(1), denominator: .number(2)))
    }

    @Test func tanFunction() throws {
        let ast = try parse("tan(x)")
        #expect(ast == .tan(.variable("x")))
    }

    @Test func logFunction() throws {
        let ast = try parse("log(x)")
        #expect(ast == .log(.variable("x")))
    }

    @Test func trigonometricIdentity() throws {
        // sin(x)^2 + cos(x)^2 = 1
        let ast = try parse("sin(x)^2 + cos(x)^2 = 1")
        #expect(ast == .equals(
            .add(
                .power(.sin(.variable("x")), .number(2)),
                .power(.cos(.variable("x")), .number(2))
            ),
            .number(1)
        ))
    }

    @Test func mixedFraction() throws {
        let ast = try parse("mfrac(1,1,2)")
        #expect(ast == .mixedFrac(whole: .number(1), numerator: .number(1), denominator: .number(2)))
    }

    @Test func mixedFractionInExpression() throws {
        // mfrac(2,3,4) + x debe ser add(mixedFrac(2,3,4), x)
        let ast = try parse("mfrac(2,3,4) + x")
        #expect(ast == .add(
            .mixedFrac(whole: .number(2), numerator: .number(3), denominator: .number(4)),
            .variable("x")
        ))
    }

    @Test func mixedFractionWithExpressions() throws {
        // La parte entera puede ser una expresión
        let ast = try parse("mfrac(x,1,3)")
        #expect(ast == .mixedFrac(whole: .variable("x"), numerator: .number(1), denominator: .number(3)))
    }

    @Test func negate() throws {
        let ast = try parse("-x")
        #expect(ast == .negate(.variable("x")))
    }

    @Test func sqrt() throws {
        let ast = try parse("sqrt(x^2)")
        #expect(ast == .sqrt(.power(.variable("x"), .number(2))))
    }
}
