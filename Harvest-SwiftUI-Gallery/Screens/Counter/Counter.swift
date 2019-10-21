import Harvest

/// Counter example namespace.
enum Counter {}

extension Counter
{
    enum Input: String, CustomStringConvertible
    {
        case increment
        case decrement

        var description: String { return self.rawValue }
    }

    struct State
    {
        var count: Int = 0
    }

    static var mapping: Mapping
    {
        .makeInout { input, state in
            switch input {
            case .increment:
                state.count += 1
            case .decrement:
                state.count -= 1
            }
        }
    }

    typealias Mapping = Harvester<Input, State>.Mapping
}
