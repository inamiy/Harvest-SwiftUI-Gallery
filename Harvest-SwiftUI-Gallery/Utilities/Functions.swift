/// Transforms `(T) -> U` to `(T2) -> U`.
public func contramap<T, T2, U>(
    _ f: @escaping (T2) -> T
)
    -> (@escaping (T) -> U)
    -> (T2) -> U
{
    { tu in { t2 in tu(f(t2)) } }
}

/// Principle of explosion.
func absurd<A>(_ x: Never) -> A {}
