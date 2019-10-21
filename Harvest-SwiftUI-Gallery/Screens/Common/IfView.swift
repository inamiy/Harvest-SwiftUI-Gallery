import SwiftUI

/// Workaround for missing `if flag { ... } else { ... }` control-flow **outside of `ViewBuilder`** in SwiftUI.
public struct If<Content: View>: View
{
    private let flag: Bool
    private let build: () -> Content

    public init(_ flag: Bool, _ build: @escaping () -> Content)
    {
        self.flag = flag
        self.build = build
    }

    public var body: some View
    {
        Group {
            if self.flag {
                self.build()
            }
        }
    }

    public func `else`<ElseContent: View>(
        _ build: @escaping () -> ElseContent
    ) -> _ConditionalContent<Self, ElseContent>
    {
        if self.flag {
            return ViewBuilder.buildEither(first: self)
        }
        else {
            return ViewBuilder.buildEither(second: build())
        }
    }
}

extension View
{
    func `if`<TrueContent: View>(
        _ condition: Bool,
        modifier: (Self) -> TrueContent
    ) -> _ConditionalContent<TrueContent, Self>
    {
        if condition {
            return ViewBuilder.buildEither(first: modifier(self))
        }
        else {
            return ViewBuilder.buildEither(second: self)
        }
    }
}
