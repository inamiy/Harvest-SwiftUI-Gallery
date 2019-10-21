import Foundation
import Harvest

/// Todo example namespace.
enum Todo {}

extension Todo
{
    enum Input
    {
        case updateNewText(String)
        case createTodo
        case updateText(Item.ID, String)
        case toggleCompleted(Item.ID)
        case updateDisplayMode(DisplayMode)
        case toggleEdit
        case delete(IndexSet)
    }

    struct State
    {
        fileprivate var items: [Item] = [
            .init(id: -1, text: "🍎 Buy Apple", isCompleted: false),
            .init(id: -2, text: "🏃 Run 5 km", isCompleted: false),
            .init(id: -3, text: "🌾 Learn Harvest", isCompleted: true),
        ]

        var newText: String = ""

        var displayMode: DisplayMode = .all

        var isEditing: Bool = false

        fileprivate var nextItemID: Item.ID = 1

        var visibleItems: [Item]
        {
            self.items.filter(self.displayMode.filter)
        }
    }

    static var mapping: Mapping
    {
        .makeInout { input, state in
            switch input {
            case let .updateNewText(text):
                state.newText = text

            case .createTodo:
                guard !state.newText.isEmpty else { return }
                state.items.append(Item(id: state.nextItemID, text: state.newText))
                state.newText = ""
                state.nextItemID += 1

            case let .updateText(id, text):
                guard let index = state.items.firstIndex(where: { $0.id == id }) else { return }
                state.items[index].text = text

            case let .toggleCompleted(id):
                guard let index = state.items.firstIndex(where: { $0.id == id }) else { return }
                state.items[index].isCompleted.toggle()

            case let .updateDisplayMode(displayMode):
                state.displayMode = displayMode

            case .toggleEdit:
                state.isEditing.toggle()

            case let .delete(indexes):
                state.items.remove(atOffsets: indexes)
            }
        }
    }

    typealias Mapping = Harvester<Input, State>.Mapping
}

// MARK: - Data Models

extension Todo
{
    struct Item: Identifiable
    {
        var id: ID
        var text: String = ""
        var isCompleted: Bool = false

        typealias ID = Int
    }

    enum DisplayMode: Int, CaseIterable
    {
        case all
        case active
        case completed

        /// Workaround getter/setter to allow `Store.Proxy` to access to `rawValue` as `Int`
        /// since `SwiftUI.Picker` seems to only work for `Int`.
        var intValue: Int
        {
            get { self.rawValue }
            set {
                // Do nothing. This setter will be replaced via `Store.Proxy.stateBinding(get:onChange:)`.
            }
        }

        fileprivate var filter: (Item) -> Bool
        {
            switch self {
            case .all:          return { _ in true }
            case .active:       return { !$0.isCompleted }
            case .completed:    return { $0.isCompleted }
            }
        }
    }
}
