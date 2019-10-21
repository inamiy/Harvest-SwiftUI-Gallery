import SwiftUI
import HarvestStore

struct IntroExample: Example
{
    var exampleIcon: Image { Image(systemName: "smiley") }

    var exampleInitialState: Root.State.Current
    {
        .intro
    }

    func exampleView(store: Store<Root.Input, Root.State>.Proxy) -> AnyView
    {
        IntroView().toAnyView()
    }
}
