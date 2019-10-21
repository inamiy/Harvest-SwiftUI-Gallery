extension Root.State
{
    /// Current example state as sum type where each state is not shared.
    enum Current
    {
        case intro
        case counter(Counter.State)
        case stopwatch(Stopwatch.State)
        case stateDiagram(StateDiagram.State)
        case todo(Todo.State)
        case github(GitHub.State)

        var example: Example
        {
            switch self {
            case .intro:        return IntroExample()
            case .counter:      return CounterExample()
            case .stopwatch:    return StopwatchExample()
            case .stateDiagram: return StateDiagramExample()
            case .todo:         return TodoExample()
            case .github:       return GitHubExample()
            }
        }
    }
}

// MARK: - allEffectIDs

extension Root.State.Current
{
    /// Used for previous effects cancellation.
    var allEffectIDs: (Root.EffectID) -> Bool
    {
        switch self {
        case .stopwatch:
            return { $0.stopwatch != nil }

        case .github:
            return { $0.github != nil }

        default:
            return { _ in false }
        }
    }
}

// MARK: - get-set enum properties (for SwiftUI binding)
// See also: https://www.pointfree.co/episodes/ep70-composable-state-management-action-pullbacks

extension Root.State.Current
{
    var counter: Counter.State?
    {
        get {
            guard case let .counter(value) = self else { return nil }
            return value
        }
        set {
            guard case .counter = self, let newValue = newValue else { return }
            self = .counter(newValue)
        }
    }

    var stopwatch: Stopwatch.State?
    {
        get {
            guard case let .stopwatch(value) = self else { return nil }
            return value
        }
        set {
            guard case .stopwatch = self, let newValue = newValue else { return }
            self = .stopwatch(newValue)
        }
    }

    var stateDiagram: StateDiagram.State?
    {
        get {
            guard case let .stateDiagram(value) = self else { return nil }
            return value
        }
        set {
            guard case .stateDiagram = self, let newValue = newValue else { return }
            self = .stateDiagram(newValue)
        }
    }

    var todo: Todo.State?
    {
        get {
            guard case let .todo(value) = self else { return nil }
            return value
        }
        set {
            guard case .todo = self, let newValue = newValue else { return }
            self = .todo(newValue)
        }
    }

    var github: GitHub.State?
    {
        get {
            guard case let .github(value) = self else { return nil }
            return value
        }
        set {
            guard case .github = self, let newValue = newValue else { return }
            self = .github(newValue)
        }
    }
}
