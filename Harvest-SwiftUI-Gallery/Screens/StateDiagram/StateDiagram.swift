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

    static func effectMapping<S: Scheduler>(
        scheduler: S
    ) -> EffectMapping
    {
        /// Sends `.loginOK` after delay, simulating async work during `.loggingIn`.
        let loginOKProducer =
            Just(StateDiagram.Input.loginOK)
                .delay(for: 1, scheduler: scheduler)

        /// Sends `.logoutOK` after delay, simulating async work during `.loggingOut`.
        let logoutOKProducer =
            Just(StateDiagram.Input.logoutOK)
                .delay(for: 1, scheduler: scheduler)

        let canForceLogout: (State) -> Bool = [.loggingIn, .loggedIn].contains

        let mappings: [StateDiagram.EffectMapping] = [
            .login    | .loggedOut  => .loggingIn  | Effect(loginOKProducer, queue: .request),
            .loginOK  | .loggingIn  => .loggedIn   | .empty,
            .logout   | .loggedIn   => .loggingOut | Effect(logoutOKProducer, queue: .request),
            .logoutOK | .loggingOut => .loggedOut  | .empty,

            .forceLogout | canForceLogout => .loggingOut | Effect(logoutOKProducer, queue: .request)
        ]

        return .reduce(.first, mappings)
    }

    typealias EffectMapping = Harvester<Input, State>.EffectMapping<EffectQueue, Never>

    typealias EffectQueue = CommonEffectQueue
}
