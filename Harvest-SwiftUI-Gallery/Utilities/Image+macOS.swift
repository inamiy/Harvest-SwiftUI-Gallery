import SwiftUI

#if canImport(AppKit)

/// What a workaround.
/// https://stackoverflow.com/questions/58172532/initsystemname-is-unavailable-in-macos
struct Image: View
{
    let symbol: String

    init(systemName: String)
    {
        self.symbol = [
            "smiley": "🙂",
            "goforward.plus": "1️⃣",
            "checkmark.square": "✅",
            "arrow.3.trianglepath": "🔄",
            "stopwatch": "⏱",
            "g.circle.fill": "🐙",
        ][systemName] ?? ""
    }

    var body: some View
    {
        Text(self.symbol)
    }
}

#endif
