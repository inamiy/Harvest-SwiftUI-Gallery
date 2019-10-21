import Combine
import Harvest
import HarvestOptics

/// Root namespace.
enum Root {}

extension Root
{
    enum Input
    {
        case navigation(Example)
        case counter(Counter.Input)
        case stopwatch(Stopwatch.Input)
        case stateDiagram(StateDiagram.Input)
        case todo(Todo.Input)
        case github(GitHub.Input)
    }

    struct State
    {
        /// Current example state (not shared).
        var current: Current?

        /// Shared state.
        var shared: Shared = .init()

        /// For debugging purpose.
        var isDebug: Bool = false
        {
            didSet {
                print("===> Root.State = \(self)")
            }
        }

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

            // MARK: - get-set enum properties (for SwiftUI binding)
            // See also: https://www.pointfree.co/episodes/ep70-composable-state-management-action-pullbacks

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

        struct Shared
        {
            // To be done someday :)
        }
    }

    static func effectMapping<S: Scheduler>(
        scheduler: S
    ) -> EffectMapping
    {
        return .reduce([
            Counter.mapping.toEffectMapping()
                .transform(input: .init(prism: .counter))
                .transform(state: .counter),

            Todo.mapping.toEffectMapping()
                .transform(input: .init(prism: .todo))
                .transform(state: .todo)
                .transform(id: .init(tryGet: { _ in .none }, inject: absurd)),

            StateDiagram.effectMapping(scheduler: scheduler)
                .transform(input: .init(prism: .stateDiagram))
                .transform(state: .stateDiagram)
                .transform(id: .init(tryGet: { _ in .none }, inject: absurd)),

            Stopwatch.effectMapping(scheduler: scheduler)
                .transform(input: .init(prism: .stopwatch))
                .transform(state: .stopwatch)
                .transform(id: .init(tryGet: { $0.stopwatch }, inject: EffectID.stopwatch)),

            GitHub.effectMapping(scheduler: scheduler, maxConcurrency: .max(3))
                .transform(input: .init(prism: .github))
                .transform(state: .github)
                .transform(id: .init(tryGet: { $0.github }, inject: EffectID.github)),
        ])
    }

    typealias EffectMapping = Harvester<Input, State>.EffectMapping<EffectQueue, EffectID>

    typealias EffectQueue = CommonEffectQueue

    enum EffectID: Equatable
    {
        case stopwatch(Stopwatch.EffectID)
        case github(GitHub.EffectID)

        var stopwatch: Stopwatch.EffectID?
        {
            guard case let .stopwatch(value) = self else { return nil }
            return value
        }

        var github: GitHub.EffectID?
        {
            guard case let .github(value) = self else { return nil }
            return value
        }
    }
}
