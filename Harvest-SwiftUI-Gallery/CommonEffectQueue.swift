import Harvest

enum CommonEffectQueue: EffectQueueProtocol
{
    case `default`
    case request

    var flattenStrategy: FlattenStrategy
    {
        switch self {
        case .default: return .merge
        case .request: return .latest
        }
    }

    static var defaultEffectQueue: CommonEffectQueue
    {
        .default
    }
}
