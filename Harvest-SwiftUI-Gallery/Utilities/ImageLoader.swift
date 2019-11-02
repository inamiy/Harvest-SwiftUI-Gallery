import UIKit
import Combine
import Harvest
import HarvestStore

/// Simple image loader for Harvest Architecture.
enum ImageLoader {}

extension ImageLoader
{
    enum Input
    {
        case requestImage(url: URL)
        case _cacheImage(url: URL, image: UIImage)
        case cancelRequest(url: URL)
        case removeImage(url: URL)
    }

    struct State
    {
        var images: [URL: UIImage] = [:]
        var isRequesting: [URL: Bool] = [:]
    }

    static func effectMapping() -> EffectMapping
    {
        EffectMapping { input, state in
            var state = state

            switch input {
            case let .requestImage(url):
                // Skip if there is already cached image.
                if state.images[url] != nil { return nil }

                if !state.isRequesting[url, default: false] {
                    state.isRequesting[url] = true

                    // Fetch & cache image.
                    let effect = Effect<World, Input, CommonEffectQueue, EffectID>(
                        id: EffectID(url: url)
                    ) { world in
                        self.fetchImage(request: Request(url: url), world: world)
                            .compactMap { $0.map { Input._cacheImage(url: url, image: $0.image) } }
                    }

                    return (state, effect)
                }
                else {
                    return nil
                }

            case let ._cacheImage(url, image):
                state.isRequesting[url] = false
                state.images[url] = image

            case let .cancelRequest(url):
                state.isRequesting[url] = false
                return (state, Effect.cancel(EffectID(url: url)))

            case let .removeImage(url):
                state.images[url] = .none
            }

            return (state, .empty)
        }
    }

    typealias EffectMapping = Harvester<Input, State>.EffectMapping<World, EffectQueue, EffectID>

    typealias EffectQueue = CommonEffectQueue

    struct EffectID: Equatable
    {
        let url: URL
    }

    struct World
    {
        let urlSession: URLSession
    }
}

extension ImageLoader
{
    public struct Request
    {
        public let url: URL
    }

    public struct Response
    {
        public let image: UIImage
    }

    public static func fetchImage(
        request: Request,
        world: World
    ) -> AnyPublisher<Response?, Never>
    {
        print("===> fetchImage = \(request.url)")

        let urlRequest = URLRequest(url: request.url)
        return world.urlSession.dataTaskPublisher(for: urlRequest)
            .map { UIImage(data: $0.data).map { Response(image: $0) } }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
}
