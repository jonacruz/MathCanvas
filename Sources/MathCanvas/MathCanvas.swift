// The Swift Programming Language
// https://docs.swift.org/swift-book

// MathCanvas.swift
import SwiftUI

public struct MathCanvas: View {
    private let source: String
    private var fontSize: CGFloat = 24
    private var color: Color = .primary

    public init(_ source: String) {
        self.source = source
    }

    public var body: some View {
        Canvas { context, size in
            guard let mathLayout = try? buildLayout() else { return }
            let origin = CGPoint(
                x: (size.width - mathLayout.width) / 2,
                y: (size.height - mathLayout.height) / 2
            )
            mathLayout.draw(&context, origin)
        }
        .frame(width: layoutSize.width + 16, height: layoutSize.height + 16)
    }

    // MARK: - Modifiers

    public func equationFont(size: CGFloat) -> MathCanvas {
        var copy = self; copy.fontSize = size; return copy
    }

    public func equationColor(_ color: Color) -> MathCanvas {
        var copy = self; copy.color = color; return copy
    }

    // MARK: - Private

    private func buildLayout() throws -> MathLayout {
        var lexer = Lexer(source)
        let tokens = try lexer.tokenize()
        var parser = Parser(tokens: tokens)
        let ast = try parser.parse()
        return MathRenderer(fontSize: fontSize, color: color).layout(ast)
    }

    private var layoutSize: CGSize {
        guard let layout = try? buildLayout() else { return CGSize(width: 100, height: 40) }
        return CGSize(width: layout.width, height: layout.height)
    }
}
