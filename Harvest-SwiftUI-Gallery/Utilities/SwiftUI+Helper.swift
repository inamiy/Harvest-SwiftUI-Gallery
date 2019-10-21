import SwiftUI

extension View
{
    public func toAnyView() -> AnyView
    {
        AnyView(self)
    }
}
