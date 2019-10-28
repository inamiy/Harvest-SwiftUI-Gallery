import SwiftUI

extension View
{
    public func toAnyView() -> AnyView
    {
        AnyView(self)
    }
}

extension Binding where Value: Equatable
{
    /// Workaround for `NavigationLink's `isActive = false` called multiple times per dismissal.
    public func removeDuplictates() -> Binding<Value>
    {
        var previous: Value? = nil

        return Binding<Value>(
            get: { self.wrappedValue },
            set: { newValue in
                guard newValue != previous else {
                    return
                }
                previous = newValue
                self.wrappedValue = newValue
            }
        )
    }
}
