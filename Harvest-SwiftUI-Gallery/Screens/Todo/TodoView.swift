import SwiftUI
import HarvestStore

struct TodoView: View
{
    private let store: Store<Todo.Input, Todo.State>.Proxy

    init(store: Store<Todo.Input, Todo.State>.Proxy)
    {
        self.store = store
    }

    var body: some View
    {
        VStack {
            newItemTextField()

            Divider()

            List {
                ForEach(self.store.state.visibleItems.indices, id: \.self) { index in
                    self.itemRow(at: index, isEditing: self.store.state.isEditing)
                }
                .onDelete(perform: { self.store.send(.delete($0)) })
            }

            picker()
        }
        .navigationBarItems(
            trailing: Button(action: { self.store.send(.toggleEdit) }) {
                if self.store.state.isEditing {
                    Text("Done")
                }
                else {
                    Text("Edit")
                }
            }
        )
    }

    private func newItemTextField() -> some View
    {
        HStack {
            Image(systemName: "square.and.pencil")
                .onTapGesture { self.store.send(.createTodo) }

            TextField(
                "Create a new TODO",

                // IMPORTANT:
                // Explicit subscript access helper is required to avoid
                // `SwiftUI.BindingOperations.ForceUnwrapping` failure crash.
                // This issue occurs when `TodoView` is navigation-poped.
                //text: self.store.$state[\.newText],

                // Or, use `stateBinding(onChange:)` with providing an explicit next `Input`.
                // NOTE: This also allows to time-travel each character inputting.
                text: self.store.newText.stateBinding(onChange: Todo.Input.updateNewText),
                onCommit: { self.store.send(.createTodo) }
            )
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }

    private func itemRow(at visibleIndex: Int, isEditing: Bool) -> some View
    {
        let textBinding = self.store
            .stateBinding(
                get: { $0.visibleItems[visibleIndex] },
                onChange: { .updateText($0.id, $0.text) }
            )
            .text

        let item = self.store.state.visibleItems[visibleIndex]

        return HStack {
            if isEditing {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .onTapGesture {
                        self.store.send(.delete([visibleIndex]))
                    }
            }
            else {
                self.checkbox(isCompleted: item.isCompleted)
                    .onTapGesture {
                        self.store.send(.toggleCompleted(item.id))
                }
            }

            TextField(
                item.text,
                text: textBinding,
                onCommit: { self.store.send(.updateText(item.id, item.text)) }
            )
        }
    }

    private func checkbox(isCompleted: Bool) -> some View
    {
        isCompleted
            ? Image(systemName: "checkmark.circle").foregroundColor(Color.green)
            : Image(systemName: "circle").foregroundColor(Color.gray)
    }

    private func picker() -> some View
    {
        let selection = self.store.displayMode
            .stateBinding(onChange: Todo.Input.updateDisplayMode)

        return Picker("Picker", selection: selection) {
            ForEach(Todo.DisplayMode.allCases, id: \.self) {
                Text(verbatim: "\($0)")
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
    }
}

struct TodoView_Previews: PreviewProvider
{
    static var previews: some View
    {
        TodoView(
            store: .init(
                state: .constant(.init()),
                send: { _ in }
            )
        )
            .previewLayout(.sizeThatFits)
    }
}
