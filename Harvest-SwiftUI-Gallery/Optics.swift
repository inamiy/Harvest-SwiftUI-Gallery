import FunOptics
import Harvest
import FunOptics

// MARK: - Root

extension Lens where Whole == Root.State, Part == Root.State.Current?
{
    static let current: Lens<Whole, Part> = .init(
        get: { $0.current },
        set: { whole, part in
            var whole = whole
            whole.current = part
            return whole
        }
    )
}

// MARK: - Root to Counter

extension Prism where Whole == Root.Input, Part == Counter.Input
{
    static let counter: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let .counter(value) = $0 else { return nil }
            return value
        },
        inject: Root.Input.counter
    )
}

extension Prism where Whole == Root.State.Current, Part == Counter.State
{
    static let counter: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let .counter(value) = $0 else { return nil }
            return value
        },
        inject: Root.State.Current.counter
    )
}

extension AffineTraversal where Whole == Root.State, Part == Counter.State
{
    static let counter: AffineTraversal<Whole, Part>
        = Lens<Root.State, Root.State.Current?>.current
            >>> some()
            >>> Prism<Root.State.Current, Counter.State>.counter
}

// MARK: - Root to Stopwatch

extension Prism where Whole == Root.Input, Part == Stopwatch.Input
{
    static let stopwatch: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let .stopwatch(value) = $0 else { return nil }
            return value
        },
        inject: Root.Input.stopwatch
    )
}

extension Prism where Whole == Root.State.Current, Part == Stopwatch.State
{
    static let stopwatch: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let .stopwatch(value) = $0 else { return nil }
            return value
        },
        inject: Root.State.Current.stopwatch
    )
}

extension AffineTraversal where Whole == Root.State, Part == Stopwatch.State
{
    static let stopwatch: AffineTraversal<Whole, Part>
        = Lens<Root.State, Root.State.Current?>.current
            >>> some()
            >>> Prism<Root.State.Current, Stopwatch.State>.stopwatch
}

// MARK: - Root to StateDiagram

extension Prism where Whole == Root.Input, Part == StateDiagram.Input
{
    static let stateDiagram: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let .stateDiagram(value) = $0 else { return nil }
            return value
        },
        inject: Root.Input.stateDiagram
    )
}

extension Prism where Whole == Root.State.Current, Part == StateDiagram.State
{
    static let stateDiagram: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let .stateDiagram(value) = $0 else { return nil }
            return value
        },
        inject: Root.State.Current.stateDiagram
    )
}

extension AffineTraversal where Whole == Root.State, Part == StateDiagram.State
{
    static let stateDiagram: AffineTraversal<Whole, Part>
        = Lens<Root.State, Root.State.Current?>.current
            >>> some()
            >>> Prism<Root.State.Current, StateDiagram.State>.stateDiagram
}

// MARK: - Root to Todo

extension Prism where Whole == Root.Input, Part == Todo.Input
{
    static let todo: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let .todo(value) = $0 else { return nil }
            return value
        },
        inject: Root.Input.todo
    )
}

extension Prism where Whole == Root.State.Current, Part == Todo.State
{
    static let todo: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let .todo(value) = $0 else { return nil }
            return value
        },
        inject: Root.State.Current.todo
    )
}

extension AffineTraversal where Whole == Root.State, Part == Todo.State
{
    static let todo: AffineTraversal<Whole, Part>
        = Lens<Root.State, Root.State.Current?>.current
            >>> some()
            >>> Prism<Root.State.Current, Todo.State>.todo
}

// MARK: - Root to GitHub

extension Prism where Whole == Root.Input, Part == GitHub.Input
{
    static let github: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let .github(value) = $0 else { return nil }
            return value
        },
        inject: Root.Input.github
    )
}

extension Prism where Whole == Root.State.Current, Part == GitHub.State
{
    static let github: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let .github(value) = $0 else { return nil }
            return value
        },
        inject: Root.State.Current.github
    )
}

extension AffineTraversal where Whole == Root.State, Part == GitHub.State
{
    static let github: AffineTraversal<Whole, Part>
        = Lens<Root.State, Root.State.Current?>.current
            >>> some()
            >>> Prism<Root.State.Current, GitHub.State>.github
}

// MARK: - GitHub to ImageLoader

extension Prism where Whole == GitHub.Input, Part == ImageLoader.Input
{
    static let imageLoader: Prism<Whole, Part> = .init(
        tryGet: {
            guard case let ._imageLoader(value) = $0 else { return nil }
            return value
        },
        inject: GitHub.Input._imageLoader
    )
}

extension Lens where Whole == GitHub.State, Part == ImageLoader.State
{
    static let imageLoader: Lens<Whole, Part> = Lens(\.imageLoader)
}
