import Combine

extension Publisher
{
    public func delaySubscription<S: Scheduler>(
        for interval: S.SchedulerTimeType.Stride,
        tolerance: S.SchedulerTimeType.Stride? = nil,
        scheduler: S,
        options: S.SchedulerOptions? = nil
    ) -> Publishers.DelaySubscription<Self, S>
    {
        Publishers.DelaySubscription(
            upstream: self,
            interval: interval,
            tolerance: tolerance ?? scheduler.minimumTolerance,
            scheduler: scheduler,
            options: options
        )
    }
}

extension Publishers
{
    /// A publisher that delays subscription of upstream.
    public struct DelaySubscription<Upstream: Publisher, _Scheduler: Scheduler>: Publisher
    {
        public typealias Output = Upstream.Output
        public typealias Failure = Upstream.Failure

        /// The publisher that this publisher receives elements from.
        public let upstream: Upstream

        /// The amount of time to delay.
        public let interval: _Scheduler.SchedulerTimeType.Stride

        /// The allowed tolerance in firing delayed subscription.
        public let tolerance: _Scheduler.SchedulerTimeType.Stride

        /// The scheduler for the delayed subscription.
        public let scheduler: _Scheduler

        public let options: _Scheduler.SchedulerOptions?

        public init(
            upstream: Upstream,
            interval: _Scheduler.SchedulerTimeType.Stride,
            tolerance: _Scheduler.SchedulerTimeType.Stride,
            scheduler: _Scheduler,
            options: _Scheduler.SchedulerOptions? = nil
        )
        {
            self.upstream = upstream
            self.interval = interval
            self.tolerance = tolerance
            self.scheduler = scheduler
            self.options = options
        }

        public func receive<S>(subscriber: S)
            where S : Subscriber, Upstream.Failure == S.Failure, Upstream.Output == S.Input
        {
            self.upstream.subscribe(
                Inner(
                    publisher: self,
                    downstream: subscriber
                )
            )
        }
    }
}

extension Publishers.DelaySubscription
{
    private final class Inner<Downstream: Subscriber>:
        Subscriber,
        CustomStringConvertible,
        CustomReflectable,
        CustomPlaygroundDisplayConvertible
        where
        Downstream.Input == Output, Downstream.Failure == Upstream.Failure
    {
        typealias Input = Upstream.Output

        typealias Failure = Upstream.Failure

        private let interval: _Scheduler.SchedulerTimeType.Stride
        private let tolerance: _Scheduler.SchedulerTimeType.Stride
        private let scheduler: _Scheduler
        private let options: _Scheduler.SchedulerOptions?

        private let downstream: Downstream

        private var subscription: Subscription?

        let combineIdentifier = CombineIdentifier()

        fileprivate init(
            publisher: Publishers.DelaySubscription<Upstream, _Scheduler>,
            downstream: Downstream
        )
        {
            self.interval = publisher.interval
            self.tolerance = publisher.tolerance
            self.scheduler = publisher.scheduler
            self.options = publisher.options
            self.downstream = downstream
        }

        func receive(subscription: Subscription)
        {
            self.scheduler.schedule(
                after: self.scheduler.now.advanced(by: self.interval),
                tolerance: self.tolerance,
                options: self.options
            ) {
                self.downstream.receive(subscription: subscription)
            }
        }

        func receive(_ input: Input) -> Subscribers.Demand
        {
            return self.downstream.receive(input)
        }

        func receive(completion: Subscribers.Completion<Failure>)
        {
            self.downstream.receive(completion: completion)
        }

        var description: String { "DelayedSubscription" }

        var customMirror: Mirror
        {
            return Mirror(self, children: EmptyCollection())
        }

        var playgroundDescription: Any { self.description }
    }
}

// MARK: - Fallback implementation

extension Publisher
{
    /// Fallback implementation in case of `struct DelaySubscripton` has bug.
    public func _delaySubscription<S: Scheduler>(
        for interval: S.SchedulerTimeType.Stride,
        tolerance: S.SchedulerTimeType.Stride? = nil,
        scheduler: S,
        options: S.SchedulerOptions? = nil
    ) -> Publishers.FlatMap<Self, Publishers.Delay<Result<Void, Self.Failure>.Publisher, S>>
    {
        Result<Void, Failure>.Publisher(())
            .delay(
                for: interval,
                tolerance: tolerance,
                scheduler: scheduler,
                options: options
            )
            .flatMap { _ in self }
    }
}
