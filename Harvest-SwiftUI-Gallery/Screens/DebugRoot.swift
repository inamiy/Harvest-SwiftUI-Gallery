import Combine
import FunOptics
import Harvest
import HarvestOptics

/// DebugRoot namespace.
enum DebugRoot {}

extension DebugRoot
{
    enum Input
    {
        case timeTravel(TimeTravel.Input<Root.Input>)
    }

    struct State
    {
        var timeTravel: TimeTravel.State<Root.State>
        let usesTimeTravel: Bool

        /// For debugging purpose.
        var isDebug: Bool = false
        {
            didSet {
                print("===> Root.State = \(self)".noAppPrefix)
            }
        }

        init(inner state: Root.State, usesTimeTravel: Bool)
        {
            self.timeTravel = .init(inner: state)
            self.usesTimeTravel = usesTimeTravel
        }
    }

    static func effectMapping<S: Scheduler>(usesTimeTravel: Bool = true) -> EffectMapping<S>
    {
        let rootMapping: EffectMapping<S> = Root.effectMapping()
            .transform(input: .fromEnum(\.timeTravel) >>> .fromEnum(\.inner))
            .transform(state: .init(lens: .init(\.timeTravel) >>> .init(\.inner)))

        if usesTimeTravel {
            return .reduce(.all, [
                rootMapping,

                // Important: TimeTravel mapping needs to be called after `Root.effectMapping` (after `Root.State` changed).
                TimeTravel.effectMapping()
                    .contramapWorld { TimeTravel.World(inner: $0, scheduler: $0.scheduler) }
                    .transform(input: .fromEnum(\.timeTravel))
                    .transform(state: .init(lens: .init(\.timeTravel))),
            ])
        }
        else {
            return rootMapping
        }
    }

    typealias EffectMapping<S: Scheduler> = Harvester<Input, State>.EffectMapping<World<S>, EffectQueue, EffectID>
    typealias EffectQueue = CommonEffectQueue
    typealias EffectID = Root.EffectID
    typealias World = Harvest_SwiftUI_Gallery.World
}

// MARK: - Enum Properties

extension DebugRoot.Input
{
    var timeTravel: TimeTravel.Input<Root.Input>?
    {
        get {
            guard case let .timeTravel(value) = self else { return nil }
            return value
        }
        set {
            guard case .timeTravel = self, let newValue = newValue else { return }
            self = .timeTravel(newValue)
        }
    }
}

// MARK: - Private

extension String
{
    fileprivate var noAppPrefix: String
    {
        self.replacingOccurrences(of: "Harvest_SwiftUI_Gallery.", with: "")
    }
}
