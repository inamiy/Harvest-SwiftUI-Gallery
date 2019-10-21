enum Either<L, R>
{
    case left(L)
    case right(R)
}

extension Either
{
    var left: L?
    {
        switch self {
        case let .left(l): return l
        case .right: return .none
        }
    }

    var right: R?
    {
        switch self {
        case .left: return .none
        case let .right(r): return r
        }
    }
}

extension Either: Decodable where L: Decodable, R: Decodable
{
    init(from decoder: Decoder) throws
    {
        let container = try decoder.singleValueContainer()

        // Left-biased parsing.
        do {
            let leftValue = try container.decode(L.self)
            self = .left(leftValue)
        } catch {
            let rightValue = try container.decode(R.self)
            self = .right(rightValue)
        }
    }
}

extension Either: Encodable where L: Encodable, R: Encodable
{
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.singleValueContainer()
        switch self {
        case .left(let value):
            try container.encode(value)
        case .right(let value):
            try container.encode(value)
        }
    }
}
