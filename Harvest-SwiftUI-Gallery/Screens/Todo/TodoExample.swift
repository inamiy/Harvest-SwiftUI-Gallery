import SwiftUI
import HarvestStore

struct TodoExample: Example
{
    var exampleIcon: Image { Image(systemName: "checkmark.square") }

    var exampleInitialState: Root.State.Current
    {
        .todo(Todo.State())
    }

    func exampleView(store: Store<Root.Input, Root.State>.Proxy) -> AnyView
    {
        guard let currentBinding = Binding(store.$state.current),
            let stateBinding = Binding(currentBinding.todo) else
        {
            return EmptyView().toAnyView()
        }

        let substore = Store<Todo.Input, Todo.State>.Proxy(
            state: stateBinding,
            send: contramap(Root.Input.todo)(store.send)
        )

        return TodoView(store: substore).toAnyView()
    }
}
