// The Swift Programming Language
// https://docs.swift.org/swift-book

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import CoreGraphics
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
            //guard let cgContext = context.cgContext else { return }
            guard let mathLayout = try? buildLayout() else { return }
            let origin = CGPoint(
                x: (size.width - mathLayout.width) / 2,
                y: (size.height - mathLayout.height) / 2
            )
            context.withCGContext { cgContext in
                mathLayout.draw(cgContext, origin)
            }
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
        let renderer = MathRenderer(
            fontSize: fontSize,
            color: PlatformColor(color)
        )
        return renderer.layout(ast)
    }

    private var layoutSize: CGSize {
        guard let layout = try? buildLayout() else { return CGSize(width: 100, height: 40) }
        return CGSize(width: layout.width, height: layout.height)
    }
}
