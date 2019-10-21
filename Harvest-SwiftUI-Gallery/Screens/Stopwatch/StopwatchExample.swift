import SwiftUI
import HarvestStore

struct StopwatchExample: Example
{
    var exampleIcon: Image { Image(systemName: "stopwatch") }

    var exampleInitialState: Root.State.Current
    {
        .stopwatch(Stopwatch.State())
    }

    func exampleView(store: Store<Root.Input, Root.State>.Proxy) -> AnyView
    {
        guard let currentBinding = Binding(store.$state.current),
            let stateBinding = Binding(currentBinding.stopwatch) else
        {
            return EmptyView().toAnyView()
        }

        let substore = Store<Stopwatch.Input, Stopwatch.State>.Proxy(
            state: stateBinding,
            send: contramap(Root.Input.stopwatch)(store.send)
        )

        return StopwatchView(store: substore).toAnyView()
    }
}
