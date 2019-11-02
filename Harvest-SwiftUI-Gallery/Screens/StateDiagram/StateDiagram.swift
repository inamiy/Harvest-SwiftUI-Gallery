import Foundation
import Combine
import Harvest

/// StateDiagram example namespace.
enum StateDiagram {}

extension StateDiagram
{
    enum Input: String, CustomStringConvertible
    {
        case login
        case loginOK
        case logout
        case forceLogout
        case logoutOK

        var description: String { return self.rawValue }
    }

    enum State: String, CustomStringConvertible
    {
        case loggedOut
        case loggingIn
        case loggedIn
        case loggingOut

        var description: String { return self.rawValue }
    }

    static func effectMapping<S: Scheduler>() -> EffectMapping<S>
    {
        /// Sends `.loginOK` after delay, simulating async work during `.loggingIn`.
        let loginOKEffect = Effect<S>(queue: .request) { world in
            Just(StateDiagram.Input.loginOK)
                .delay(for: world.simulatedAsyncWorkDelay, scheduler: world.scheduler)
        }

        /// Sends `.logoutOK` after delay, simulating async work during `.loggingOut`.
        let logoutOKEffect = Effect<S>(queue: .request) { world in
            Just(StateDiagram.Input.logoutOK)
                .delay(for: world.simulatedAsyncWorkDelay, scheduler: world.scheduler)
        }

        let canForceLogout: (State) -> Bool = [.loggingIn, .loggedIn].contains

        let mappings: [StateDiagram.EffectMapping<S>] = [
            .login    | .loggedOut  => .loggingIn  | loginOKEffect,
            .loginOK  | .loggingIn  => .loggedIn   | .empty,
            .logout   | .loggedIn   => .loggingOut | logoutOKEffect,
            .logoutOK | .loggingOut => .loggedOut  | .empty,

            .forceLogout | canForceLogout => .loggingOut | logoutOKEffect
        ]

        return .reduce(.first, mappings)
    }

    typealias EffectMapping<S: Scheduler> = Harvester<Input, State>.EffectMapping<World<S>, EffectQueue, Never>

    typealias Effect<S: Scheduler> = Harvest.Effect<World<S>, Input, EffectQueue, Never>

    typealias EffectQueue = CommonEffectQueue

    struct World<S: Scheduler>
    {
        let scheduler: S

        /// Simulated delay between ".loggingIn => .loggedIn" and ".loggingOut => .loggedOut".
        var simulatedAsyncWorkDelay: S.SchedulerTimeType.Stride = .seconds(1)
    }
}
