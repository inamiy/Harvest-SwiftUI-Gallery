import SwiftUI
import HarvestStore

struct StateDiagramExample: Example
{
    var exampleIcon: Image { Image(systemName: "arrow.3.trianglepath") }

    var exampleInitialState: Root.State.Current
    {
        .stateDiagram(.loggedOut)
    }

    func exampleView(store: Store<Root.Input, Root.State>.Proxy) -> AnyView
    {
        guard let currentBinding = Binding(store.$state.current),
            let stateBinding = Binding(currentBinding.stateDiagram) else
        {
            return EmptyView().toAnyView()
        }

        let substore = Store<StateDiagram.Input, StateDiagram.State>.Proxy(
            state: stateBinding,
            send: contramap(Root.Input.stateDiagram)(store.send)
        )

        return StateDiagramView(store: substore).toAnyView()
    }
}
