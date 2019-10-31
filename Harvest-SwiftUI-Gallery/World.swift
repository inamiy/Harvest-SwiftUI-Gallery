import Foundation

/// Dependencies that interacts with `Effect`s.
struct World
{
    let urlSession: URLSession
    let date: () -> Date

    static func makeRealWorld() -> World
    {
        World(
            urlSession: .shared,
            date: { Date() }
        )
    }
}
