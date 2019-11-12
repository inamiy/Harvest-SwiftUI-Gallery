import SwiftUI
import HarvestStore

protocol Example
{
    var exampleTitle: String { get }
    var exampleIcon: Image { get }
    var exampleInitialState: Root.State.Current { get }

    func exampleView(store: Store<Root.Input, Root.State>.Proxy) -> AnyView
}

extension Example
{
    var exampleTitle: String
    {
        let title = String(describing: self)
        if let index = title.range(of: "Example")?.lowerBound { // trim "-Example()"
            return String(title.prefix(upTo: index))
        }
        else {
            return title
        }
    }
}

// MARK: - Example List

let allExamples: [Example] = [
    IntroExample(),
    CounterExample(),
    TodoExample(),
    StateDiagramExample(),
    StopwatchExample(),
    GitHubExample(),
    LifeGameExample(),
]
