import SwiftUI

/// Workaround for missing `if let { ... } else { ... }` control-flow in SwiftUI.
public struct IfLet<Value, Content: View>: View
{
    private let value: Value?
    private let build: (Value) -> Content

    public init(_ value: Value?, _ build: @escaping (Value) -> Content)
    {
        self.value = value
        self.build = build
    }

    public var body: some View
    {
        Group {
            if self.value != nil {
                self.build(self.value!)
            }
        }
    }

    public func `else`<ElseContent: View>(
        _ build: @escaping () -> ElseContent
    ) -> _ConditionalContent<Self, ElseContent>
    {
        if self.value != nil {
            return ViewBuilder.buildEither(first: self)
        }
        else {
            return ViewBuilder.buildEither(second: build())
        }
    }
}

extension View
{
    func ifLet<Value, TrueContent: View>(
        _ value: Value?,
        modifier: (Self, Value) -> TrueContent
    ) -> _ConditionalContent<TrueContent, Self>
    {
        if let value = value {
            return ViewBuilder.buildEither(first: modifier(self, value))
        }
        else {
            return ViewBuilder.buildEither(second: self)
        }
    }
}
