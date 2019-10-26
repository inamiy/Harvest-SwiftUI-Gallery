#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif
import Combine
import Harvest
import HarvestOptics

/// GitHub example namespace.
/// - Credit:
///   - https://github.com/marty-suzuki/GitHubSearchWithSwiftUI
///   - https://github.com/ra1028/SwiftUI-Combine
enum GitHub {}

extension GitHub
{
    enum Input
    {
        case onAppear
        case updateSearchText(String)
        case _updateItems([Repository])
        case _showError(message: String)
        case tapRow(at: Int)
        case dismiss

        case _imageLoader(ImageLoader.Input)

        init(response: SearchRepositoryResponse)
        {
            switch response.value {
            case let .left(items):
                self = ._updateItems(items)
            case let .right(error):
                self = ._showError(message: error.message)
            }
        }
    }

    struct State
    {
        var searchText: String = "SwiftUI"

        var selectedIndex: Int? = nil

        var errorMessage: ErrorMessage? = nil

        fileprivate(set) var isLoading: Bool = false

        fileprivate(set) var items: [Repository] = []

        var imageLoader: ImageLoader.State = .init()

        var selectedWebURL: URL?
        {
            guard let selectedIndex = self.selectedIndex else { return nil }
            return self.items[selectedIndex].htmlUrl
        }

        var isWebViewPresented: Bool
        {
            get { self.selectedIndex != nil }
            set { self.selectedIndex = nil }
        }

        struct ErrorMessage: Identifiable
        {
            let message: String

            var id: String { self.message }
        }
    }

    static func effectMapping<S: Scheduler>(
        scheduler: S,
        maxConcurrency: Subscribers.Demand
    ) -> EffectMapping
    {
        let effectMapping = EffectMapping.makeInout { input, state in
            switch input {
            case .onAppear:
                state.isLoading = true
                return githubRequest(text: state.searchText, scheduler: scheduler)

            case let .updateSearchText(text):
                state.searchText = text
                state.isLoading = !text.isEmpty
                return githubRequest(text: text, scheduler: scheduler)

            case let ._updateItems(items):
                state.items = items
                state.isLoading = false

                guard !items.isEmpty else {
                    return .empty
                }

                let imageURLs = items.map { $0.owner.avatarUrl }

                // FIXME: No lazy loading yet.
                return Effect<Input, EffectQueue, EffectID>(
                    Publishers.Sequence(sequence: imageURLs)
                        .flatMap(maxPublishers: maxConcurrency) {
                            Just(Input._imageLoader(.requestImage(url: $0)))
                        }
                        .mapError(absurd)
                )

            case let ._showError(message):
                state.isLoading = false
                state.errorMessage = .init(message: message)

            case let .tapRow(index):
                state.selectedIndex = index

            case .dismiss:
                state.selectedIndex = nil

            case ._imageLoader:
                return nil
            }

            return .empty
        }

        return .reduce(.first, [
            effectMapping,
            ImageLoader.effectMapping(scheduler: scheduler)
                .transform(input: .init(prism: .imageLoader))
                .transform(state: .init(lens: .imageLoader))
        ])
    }

    private static func githubRequest<_EffectID: Equatable, S: Scheduler>(
        text: String,
        scheduler: S
    ) -> Effect<Input, EffectQueue, _EffectID>
    {
        guard !text.isEmpty else {
            return Effect(Just(Input._updateItems([])))
        }

        var urlComponents = URLComponents(string: "https://api.github.com/search/repositories")!
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: text)
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        // Search request.
        // NOTE: `delaySubscription` + `EffectQueue.request` (`.latest` strategy) will work as `debounce`.
        let publisher = URLSession.shared.dataTaskPublisher(for: request)
            .delaySubscription(for: .seconds(0.3), scheduler: scheduler)
            .map { $0.data }
            .decode(type: SearchRepositoryResponse.self, decoder: decoder)
            .map(Input.init(response:))
            .catch { Result<Input, Never>.Publisher(Input._showError(message: $0.localizedDescription)) }

        return Effect(publisher, queue: .request)
    }

    typealias EffectMapping = Harvester<Input, State>.EffectMapping<EffectQueue, EffectID>

    typealias EffectQueue = CommonEffectQueue

    typealias EffectID = ImageLoader.EffectID
}

// MARK: - Data Models

extension GitHub
{
    struct Repository: Decodable, Identifiable
    {
        let id: Int
        let fullName: String
        let description: String?
        let stargazersCount: Int
        let htmlUrl: URL
        let owner: Owner

        struct Owner: Decodable, Identifiable
        {
            let id: Int
            let login: String
            let avatarUrl: URL
        }
    }

    /// Mainly for decoding 403 API limit error.
    struct Error: Swift.Error, Decodable
    {
        let message: String
    }

    struct SearchRepositoryResponse: Decodable
    {
        var value: Either<[Repository], GitHub.Error>

        init(from decoder: Decoder) throws
        {
            do {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.value = .left(try container.decode([Repository].self, forKey: .items))
            }
            catch {
                let container = try decoder.singleValueContainer()
                self.value = .right(try container.decode(GitHub.Error.self))
            }
        }

        private enum CodingKeys: CodingKey
        {
            case items
        }
    }
}
