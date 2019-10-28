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

        /// For debugging purpose.
        var isDebug: Bool = false
        {
            didSet {
                print("===> Root.State = \(self)".noAppPrefix)
            }
        }

        init(_ state: Root.State)
        {
            self.timeTravel = .init(inner: state)
        }
    }

    static func effectMapping<S: Scheduler>(
        scheduler: S
    ) -> EffectMapping
    {
        return .reduce(.all, [
            Root.effectMapping(scheduler: scheduler)
                .transform(input: fromEnumProperty(\.timeTravel) >>> fromEnumProperty(\.inner))
                .transform(state: .init(lens: .init(\.timeTravel) >>> .init(\.inner))),

            // Important: TimeTravel mapping needs to be called after `Root.effectMapping` (after `Root.State` changed).
            TimeTravel.effectMapping(scheduler: scheduler)
                .transform(input: fromEnumProperty(\.timeTravel))
                .transform(state: .init(lens: .init(\.timeTravel))),
        ])
    }

    typealias EffectMapping = Harvester<Input, State>.EffectMapping<EffectQueue, EffectID>
    typealias EffectQueue = CommonEffectQueue
    typealias EffectID = Root.EffectID
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
