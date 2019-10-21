import Combine
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

        /// For debugging purpose.
        var isDebug: Bool = false
        {
            didSet {
                print("===> Root.State = \(self)")
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
            .makeInout { input, state in
                switch input {
                case let .changeCurrent(current):
                    state.current = current

                    // When navigating to example, cancel its previous running effects.
                    //
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
            },

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
