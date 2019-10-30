import Foundation
import Combine
import FunOptics
import Harvest
import HarvestOptics

/// Root namespace.
enum Root {}

extension Root
{
    enum Input
    {
        case changeCurrent(State.Current?)

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

        struct Shared
        {
            // To be done someday :)
        }
    }

    static func effectMapping<S: Scheduler>(
        urlSession: URLSession,
        scheduler: S
    ) -> EffectMapping
    {
        return .reduce(.all, [
            previousEffectCancelMapping(),

            Counter.mapping.toEffectMapping()
                .transform(input: fromEnumProperty(\.counter))
                .transform(state: Lens(\.current) >>> some() >>> fromEnumProperty(\.counter)),

            Todo.mapping.toEffectMapping()
                .transform(input: fromEnumProperty(\.todo))
                .transform(state: Lens(\.current) >>> some() >>> fromEnumProperty(\.todo))
                .transform(id: .init(tryGet: { _ in .none }, inject: absurd)),

            StateDiagram.effectMapping(scheduler: scheduler)
                .transform(input: fromEnumProperty(\.stateDiagram))
                .transform(state: Lens(\.current) >>> some() >>> fromEnumProperty(\.stateDiagram))
                .transform(id: .init(tryGet: { _ in .none }, inject: absurd)),

            Stopwatch.effectMapping(scheduler: scheduler)
                .transform(input: fromEnumProperty(\.stopwatch))
                .transform(state: Lens(\.current) >>> some() >>> fromEnumProperty(\.stopwatch))
                .transform(id: .init(tryGet: { $0.stopwatch }, inject: EffectID.stopwatch)),

            GitHub.effectMapping(urlSession: urlSession, scheduler: scheduler, maxConcurrency: .max(3))
                .transform(input: fromEnumProperty(\.github))
                .transform(state: Lens(\.current) >>> some() >>> fromEnumProperty(\.github))
                .transform(id: .init(tryGet: { $0.github }, inject: EffectID.github)),
        ])
    }

    /// When navigating to example, cancel its previous running effects.
    private static func previousEffectCancelMapping() -> EffectMapping
    {
        .makeInout { input, state in
            switch input {
            case let .changeCurrent(current):
                state.current = current

                // NOTE:
                // We should NOT cancel previous effects at example screen's
                // `onAppear`, `onDisappear`, `init`, `deinit`, etc,
                // because we sometimes want to keep them running
                // (e.g. Stopwatch temporarily visiting child screen),
                // so `.changeCurrent` is the best timing to cancel them.
                let currentEffectIDs = current?.allEffectIDs
                return currentEffectIDs.map { .cancel($0) } ?? .empty

            default:
                return nil
            }
        }
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

// MARK: - Enum Properties

extension Root.Input
{
    var changeCurrent: Root.State.Current??
    {
        get {
            guard case let .changeCurrent(value) = self else { return nil }
            return value
        }
        set {
            guard case .changeCurrent = self, let newValue = newValue else { return }
            self = .changeCurrent(newValue)
        }
    }

    var counter: Counter.Input?
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

    var stopwatch: Stopwatch.Input?
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

    var stateDiagram: StateDiagram.Input?
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

    var todo: Todo.Input?
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

    var github: GitHub.Input?
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
