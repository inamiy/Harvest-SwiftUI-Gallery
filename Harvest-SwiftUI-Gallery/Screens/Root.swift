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
        case lifegame(LifeGame.Input)
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

    static func effectMapping<S: Scheduler>() -> EffectMapping<S>
    {
        .reduce(.all, [
            previousEffectCancelMapping(),

            Counter.mapping.toEffectMapping()
                .transform(input: .fromEnum(\.counter))
                .transform(state: Lens(\.current) >>> some() >>> .fromEnum(\.counter)),

            Todo.mapping.toEffectMapping()
                .transform(input: .fromEnum(\.todo))
                .transform(state: Lens(\.current) >>> some() >>> .fromEnum(\.todo))
                .transform(id: .never),

            StateDiagram.effectMapping()
                .contramapWorld { StateDiagram.World(scheduler: $0.scheduler) }
                .transform(input: .fromEnum(\.stateDiagram))
                .transform(state: Lens(\.current) >>> some() >>> .fromEnum(\.stateDiagram))
                .transform(id: .never),

            Stopwatch.effectMapping()
                .contramapWorld { $0.stopwatch }
                .transform(input: .fromEnum(\.stopwatch))
                .transform(state: Lens(\.current) >>> some() >>> .fromEnum(\.stopwatch))
                .transform(id: Prism(tryGet: { $0.stopwatch }, inject: EffectID.stopwatch)),

            GitHub.effectMapping()
                .contramapWorld { $0.github }
                .transform(input: .fromEnum(\.github))
                .transform(state: Lens(\.current) >>> some() >>> .fromEnum(\.github))
                .transform(id: Prism(tryGet: { $0.github }, inject: EffectID.github)),

            LifeGame.effectMapping()
                .contramapWorld { .init(fileScheduler: $0.fileScheduler) }
                .transform(input: .fromEnum(\.lifegame))
                .transform(state: Lens(\.current) >>> some() >>> .fromEnum(\.lifegame))
                .transform(id: Prism(tryGet: { $0.lifegame }, inject: EffectID.lifegame))
                .mapQueue { _ in .defaultEffectQueue }
        ])
    }

    /// When navigating to example, cancel its previous running effects.
    private static func previousEffectCancelMapping<S: Scheduler>() -> EffectMapping<S>
    {
        .makeInout { input, state, world in
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

    typealias EffectMapping<S: Scheduler> = Harvester<Input, State>.EffectMapping<World<S>, EffectQueue, EffectID>

    typealias EffectQueue = CommonEffectQueue

    enum EffectID: Equatable
    {
        case stopwatch(Stopwatch.EffectID)
        case github(GitHub.EffectID)
        case lifegame(LifeGame.EffectID)

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

        var lifegame: LifeGame.EffectID?
        {
            guard case let .lifegame(value) = self else { return nil }
            return value
        }
    }

    typealias World = Harvest_SwiftUI_Gallery.World
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

    var lifegame: LifeGame.Input?
    {
        get {
            guard case let .lifegame(value) = self else { return nil }
            return value
        }
        set {
            guard case .lifegame = self, let newValue = newValue else { return }
            self = .lifegame(newValue)
        }
    }
}
