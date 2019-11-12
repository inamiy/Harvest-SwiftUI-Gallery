import SwiftUI
import HarvestStore
import GameOfLife

struct LifeGameExample: Example
{
    var exampleIcon: Image { Image(systemName: "staroflife") }

    var exampleInitialState: Root.State.Current
    {
        .lifegame(.init(pattern: .glider))
    }

    func exampleView(store: Store<Root.Input, Root.State>.Proxy) -> AnyView
    {
        guard let currentBinding = Binding(store.$state.current),
            let stateBinding = Binding(currentBinding.lifegame) else
        {
            return EmptyView().toAnyView()
        }

        let substore = Store<LifeGame.Input, LifeGame.State>.Proxy(
            state: stateBinding,
            send: contramap(Root.Input.lifegame)(store.send)
        )

        return GameOfLife.RootView(store: substore).toAnyView()
    }
}
