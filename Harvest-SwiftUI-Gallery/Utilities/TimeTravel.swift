import Combine
import Harvest
import FunOptics

/// Simple time-traveller for Harvest Architecture.
enum TimeTravel {}

extension TimeTravel
{
    enum Input<InnerInput>
    {
        case timeTravelStepper(diff: Int)
        case timeTravelSlider(sliderValue: Double)
        case _didTimeTravel
        case resetHistories

        case inner(InnerInput)
    }

    struct State<InnerState>
    {
        var inner: InnerState

        fileprivate(set) var histories: [InnerState] = []

        fileprivate(set) var timeTravellingIndex: Int = 0

        // Workaround flag for avoiding SwiftUI iOS navigation binding issue
        // where `isActive = false` binding is called during time-travelling.
        fileprivate(set) var isTimeTravelling: Bool = false

        init(inner: InnerState)
        {
            self.inner = inner
            self.histories.append(inner)
        }

        var timeTravellingSliderRange: ClosedRange<Double>
        {
            let count = self.histories.count

            // NOTE: `0 ... 0` is not allowed in `Slider`.
            return count > 1
                ? 0 ... Double(count - 1)
                : -1 ... 0
        }

        var timeTravellingSliderValue: Double
        {
            get { Double(timeTravellingIndex) }
            set { assertionFailure("Should be replaced by `Store.Proxy.stateBinding`") }
        }

        var canTimeTravel: Bool
        {
            self.histories.count > 1
        }

        mutating func appendHistory(_ state: InnerState)
        {
            self.histories.removeSubrange((self.timeTravellingIndex + 1)...)
            self.histories.append(state)
            self.timeTravellingIndex += 1
        }
    }

    /// - Important: This mapping needs to be called after `InnerState` has changed.
    static func effectMapping<World, InnerInput, InnerState, Queue: EffectQueueProtocol, ID, S: Scheduler>(
        scheduler: S
    ) -> Harvester<Input<InnerInput>, State<InnerState>>.EffectMapping<World, Queue, ID>
    {
        func tryTimeTravel(state: inout State<InnerState>, newIndex: Int) -> Effect<World, Input<InnerInput>, Queue, ID>?
        {
            guard !state.histories.isEmpty && newIndex >= 0 && newIndex < state.histories.count else {
                return nil
            }

            // Load history.
            state.inner = state.histories[newIndex]

            // NOTE: Modify other states after history is loaded.
            state.timeTravellingIndex = newIndex
            state.isTimeTravelling = true

            // Workaround effect for changing to `isTimeTravelling = false` after delay.
            return Effect(
                Just(Input._didTimeTravel)
                    .delay(for: .seconds(0.1), scheduler: scheduler)
            )
        }

        return .makeInout { input, state in
            switch input {
            case let .timeTravelSlider(sliderValue):
                guard sliderValue >= 0 else { return nil }

                let newIndex = Int(sliderValue)
                return tryTimeTravel(state: &state, newIndex: newIndex)

            case let .timeTravelStepper(diff):
                guard diff != 0 else { return nil }

                let newIndex = state.timeTravellingIndex + diff
                return tryTimeTravel(state: &state, newIndex: newIndex)

            case ._didTimeTravel:
                state.isTimeTravelling = false

            case .resetHistories:
                state.histories.removeAll()
                state.histories.append(state.inner)
                state.timeTravellingIndex = 0

            default:
                // IMPORTANT:
                // Guard `appendHistory` while `isTimeTravelling` to avoid SwiftUI iOS navigation binding issue
                // where `isActive = false` binding is called during time-travelling.
                guard !state.isTimeTravelling else {
                    return nil
                }

                state.appendHistory(state.inner)
            }

            return .empty
        }
    }

    typealias EffectMapping<World, InnerInput, InnerState, EffectQueue, EffectID>
        = Harvester<Input<InnerInput>, State<InnerState>>.EffectMapping<World, EffectQueue, EffectID>
        where EffectQueue: EffectQueueProtocol, EffectID: Equatable

}

// MARK: - Enum Properties

extension TimeTravel.Input
{
    var timeTravelStepper: Int?
    {
        get {
            guard case let .timeTravelStepper(value) = self else { return nil }
            return value
        }
        set {
            guard case .timeTravelStepper = self, let newValue = newValue else { return }
            self = .timeTravelStepper(diff: newValue)
        }
    }

    var timeTravelSlider: Double?
    {
        get {
            guard case let .timeTravelSlider(value) = self else { return nil }
            return value
        }
        set {
            guard case .timeTravelSlider = self, let newValue = newValue else { return }
            self = .timeTravelSlider(sliderValue: newValue)
        }
    }

    var _didTimeTravel: Void?
    {
        guard case ._didTimeTravel = self else { return nil }
        return ()
    }

    var resetHistories: Void?
    {
        get {
            guard case .resetHistories = self else { return nil }
            return ()
        }
        set {
            guard case .resetHistories = self, case .some = newValue else { return }
            self = .resetHistories
        }
    }

    var inner: InnerInput?
    {
        get {
            guard case let .inner(value) = self else { return nil }
            return value
        }
        set {
            guard case .inner = self, let newValue = newValue else { return }
            self = .inner(newValue)
        }
    }
}
