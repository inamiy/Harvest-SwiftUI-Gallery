import Foundation
import Combine

/// Dependencies that interacts with `Effect`s.
struct World<S: Scheduler>
{
    let urlSession: URLSession
    let scheduler: S
    let fileScheduler: S
    let getDate: () -> Date

    var github: GitHub.World<S>
    {
        GitHub.World(
            urlSession: urlSession,
            scheduler: scheduler,
            searchRequestDelay: .seconds(0.3),
            imageLoadMaxConcurrency: .max(3)
        )
    }

    var stopwatch: Stopwatch.World<S>
    {
        Stopwatch.World(
            getDate: getDate,
            scheduler: scheduler
        )
    }
}

func makeRealWorld() -> World<DispatchQueue>
{
    World<DispatchQueue>(
        urlSession: URLSession.shared,
        scheduler: DispatchQueue.main,
        fileScheduler: DispatchQueue(label: "fileScheduler"),
        getDate: { Date() }
    )
}
