import Foundation

enum MessageSegment {
    case text(String)
    case latex(String, isInline: Bool)
}

private extension String {
    func splitIntoMathSegments() -> [MessageSegment] {
        let pattern = #"""
        (?msx)                      # multiline, dotMatchesLineSeparators, extended
        (
          ```latex[\s\S]+?```       # тройные fences
        | `(?:math:[^`]+|latex[^`]+|[^`]+)`  # single‐backtick inline: math:…, latex… или любая `ФОРМУЛА`
        | math:\([^)\n]+\)          # plain math:(...)
        | \\ \[ [\s\S]+? \\ \]      # display \[...\]
        | \\ \( [\s\S]+? \\ \)      # inline  \(...\)
        )
        """#

        let re = try! NSRegularExpression(
            pattern: pattern,
            options: [.allowCommentsAndWhitespace, .dotMatchesLineSeparators]
        )
        let text = self as NSString
        let full = NSRange(location: 0, length: text.length)
        var segments: [MessageSegment] = []
        var last = 0

        re.enumerateMatches(in: self, options: [], range: full) { m, _, _ in
            guard let m = m else { return }

            if m.range.location > last {
                let r = NSRange(location: last, length: m.range.location - last)
                let raw = text.substring(with: r)
                let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count > 2 {
                    segments.append(.text(raw))
                }
            }

            let rawF = text.substring(with: m.range)
            let (body, inline): (String, Bool)

            if rawF.hasPrefix("```latex") {
                let inner = rawF
                    .dropFirst("```latex".count)
                    .dropLast(3)
                body = String(inner).trimmingCharacters(in: .whitespacesAndNewlines)
                inline = false

            } else if rawF.hasPrefix("math:(") {
                let inner = rawF
                    .dropFirst("math:(".count)
                    .dropLast(1)
                body = String(inner).trimmingCharacters(in: .whitespacesAndNewlines)
                inline = true

            } else if rawF.hasPrefix("`") {
                let inner = rawF
                    .dropFirst()
                    .dropLast()
                body = inner
                    .replacingOccurrences(of: "math:", with: "")
                    .replacingOccurrences(of: "latex", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                inline = true

            } else if rawF.hasPrefix("\\[") {
                // --- display \[...\]
                let inner = rawF
                    .dropFirst(2)
                    .dropLast(2)
                body = String(inner).trimmingCharacters(in: .whitespacesAndNewlines)
                inline = false

            }
            else {
                let inner = rawF
                    .dropFirst(2)
                    .dropLast(2)
                body = String(inner).trimmingCharacters(in: .whitespacesAndNewlines)
                inline = true
            }

            segments.append(.latex(body, isInline: inline))
            last = m.range.location + m.range.length
        }

        if last < text.length {
            let r = NSRange(location: last, length: text.length - last)
            let raw = text.substring(with: r)
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 2 {
                segments.append(.text(raw))
            }
        }

        return segments
    }
}





extension OpenAIChatMessage {
    var segments: [MessageSegment] {
        let rawSegments = content.splitIntoMathSegments()
        return rawSegments.filter { segment in
            switch segment {
            case .latex:
                return true

            case .text(let txt):
                guard txt.count > 3 else { return false }
                return true
            }
        }
    }
}
