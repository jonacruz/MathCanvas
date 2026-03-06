# MathCanvas

A lightweight Swift package for rendering math equations natively in SwiftUI using Canvas and CoreGraphics — no WebView, no JavaScript, no dependencies.

```swift
MathCanvas("x^2 + y^2 = 25")
```

## Requirements

- iOS 16+ / macOS 13+
- Swift 5.9+
- Xcode 15+

## Installation

Add MathCanvas to your project via Swift Package Manager.

**In Xcode:** File → Add Package Dependencies and enter the repository URL.

**In `Package.swift`:**

```swift
dependencies: [
    .package(url: "https://github.com/jonacruz/MathCanvas", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["MathCanvas"]
    )
]
```

## Usage

Import the package and use `MathCanvas` like any SwiftUI view:

```swift
import MathCanvas
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 24) {
            MathCanvas("x^2 + y^2 = 25")

            MathCanvas("frac(1,2) + frac(3,4) = frac(5,4)")
                .equationFont(size: 32)

            MathCanvas("sqrt(x^2 + y^2)")
                .equationColor(.blue)
        }
    }
}
```

### Modifiers

| Modifier | Description |
|---|---|
| `.equationFont(size:)` | Sets the base font size |
| `.equationColor(_:)` | Sets the equation color |

## Syntax

MathCanvas uses its own simple syntax — no LaTeX required.

### Numbers and Variables

```
42          → number
3.14        → decimal
x           → variable (rendered in italic)
```

### Operators

| Syntax | Result |
|---|---|
| `x + y` | Addition |
| `x - y` | Subtraction |
| `x * y` | Multiplication |
| `x / y` | Division |
| `x ^ 2` | Power / Exponent |
| `x = y` | Equation |
| `-x`    | Negation |

### Functions

| Syntax | Result |
|---|---|
| `sqrt(x)` | Square root with overline |
| `frac(a, b)` | Fraction with horizontal bar |
| `mfrac(n, a, b)` | Mixed fraction: integer part `n` next to fraction `a/b` |
| `sin(x)` | Sine |
| `cos(x)` | Cosine |
| `tan(x)` | Tangent |
| `log(x)` | Logarithm |

### Examples

```
x^2 + y^2 = 25
frac(1, 2) + frac(1, 3) = frac(5, 6)
mfrac(1, 1, 2) + mfrac(2, 3, 4)
sqrt(x^2 + y^2)
sin(x)^2 + cos(x)^2 = 1
tan(x) = frac(sin(x), cos(x))
log(x + 1) = y
-b + sqrt(b^2)
frac(sqrt(x), 2)
```

## Architecture

MathCanvas processes expressions in three stages:

```
"x^2 + y^2 = 25"
    → Lexer     →  [Token]
    → Parser    →  ASTNode
    → Renderer  →  MathLayout → Canvas
```

**Lexer** tokenizes the raw string into a flat list of tokens. **Parser** builds an AST respecting operator precedence and right-associativity for `^`. **Renderer** traverses the AST, computes bounding boxes for each node, and draws using CoreGraphics — giving pixel-perfect layout without any external dependencies.

## Roadmap

- [ ] Scaled parentheses that grow with content — `( frac(1,2) )`
- [ ] Subscripts — `x_i`
- [ ] Display vs inline mode
- [ ] Multiplatform SwiftUI preview support
- [ ] Swift 6 concurrency compatibility

## License

MIT
