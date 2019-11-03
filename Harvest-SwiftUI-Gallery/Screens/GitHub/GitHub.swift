import UIKit
import Combine
import FunOptics
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

        case requestImage(at: Int)
        case cancelImage(at: Int)
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

    static func effectMapping<S: Scheduler>() -> EffectMapping<S>
    {
        let effectMapping = EffectMapping<S>.makeInout { input, state in
            switch input {
            case .onAppear:
                state.isLoading = true
                return githubRequest(text: state.searchText)

            case let .updateSearchText(text):
                state.searchText = text
                state.isLoading = !text.isEmpty
                return githubRequest(text: text)

            case let ._updateItems(items):
                state.items = items
                state.isLoading = false
                return .empty

            case let ._showError(message):
                state.isLoading = false
                state.errorMessage = .init(message: message)

            case let .tapRow(index):
                state.selectedIndex = index

            case .dismiss:
                state.selectedIndex = nil

            case let .requestImage(index):
                guard let imageURL = state.items[safe: index]?.owner.avatarUrl else { return nil }
                return Effect(Just(Input._imageLoader(.requestImage(url: imageURL))))

            case let .cancelImage(index):
                guard let imageURL = state.items[safe: index]?.owner.avatarUrl else { return nil }
                return Effect(Just(Input._imageLoader(.cancelRequest(url: imageURL))))

            case ._imageLoader:
                return nil
            }

            return .empty
        }

        return .reduce(.first, [
            effectMapping,
            ImageLoader.effectMapping()
                .contramapWorld { ImageLoader.World(urlSession: $0.urlSession) }
                .transform(input: .fromEnum(\._imageLoader))
                .transform(state: .init(lens: Lens(\.imageLoader)))
        ])
    }

    private static func githubRequest<_EffectID: Equatable, S: Scheduler>(
        text: String
    ) -> Effect<World<S>, Input, EffectQueue, _EffectID>
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

        return Effect(queue: .request) { world in
            // Search request.
            // NOTE: `delaySubscription` + `EffectQueue.request` (`.latest` strategy) will work as `debounce`.
            world.urlSession.dataTaskPublisher(for: request)
                .delaySubscription(for: world.searchRequestDelay, scheduler: world.scheduler)
                .map { $0.data }
                .decode(type: SearchRepositoryResponse.self, decoder: decoder)
                .map(Input.init(response:))
                .catch { Result<Input, Never>.Publisher(Input._showError(message: $0.localizedDescription)) }
        }
    }

    typealias EffectMapping<S: Scheduler> = Harvester<Input, State>.EffectMapping<World<S>, EffectQueue, EffectID>

    typealias EffectQueue = CommonEffectQueue

    typealias EffectID = ImageLoader.EffectID

    struct World<S: Scheduler>
    {
        let urlSession: URLSession
        let scheduler: S

        var searchRequestDelay: S.SchedulerTimeType.Stride
    }
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

// MARK: - Enum Properties

extension GitHub.Input
{
    var onAppear: Void?
    {
        guard case .onAppear = self else { return nil }
        return ()
    }

    var updateSearchText: String?
    {
        get {
            guard case let .updateSearchText(value) = self else { return nil }
            return value
        }
        set {
            guard case .updateSearchText = self, let newValue = newValue else { return }
            self = .updateSearchText(newValue)
        }
    }

    var _updateItems: [GitHub.Repository]?
    {
        get {
            guard case let ._updateItems(value) = self else { return nil }
            return value
        }
        set {
            guard case ._updateItems = self, let newValue = newValue else { return }
            self = ._updateItems(newValue)
        }
    }

    var _showError: String?
    {
        get {
            guard case let ._showError(value) = self else { return nil }
            return value
        }
        set {
            guard case ._showError = self, let newValue = newValue else { return }
            self = ._showError(message: newValue)
        }
    }

    var tapRow: Int?
    {
        get {
            guard case let .tapRow(value) = self else { return nil }
            return value
        }
        set {
            guard case .tapRow = self, let newValue = newValue else { return }
            self = .tapRow(at: newValue)
        }
    }

    var dismiss: Void?
    {
        guard case .dismiss = self else { return nil }
        return ()
    }

    var _imageLoader: ImageLoader.Input?
    {
        get {
            guard case let ._imageLoader(value) = self else { return nil }
            return value
        }
        set {
            guard case ._imageLoader = self, let newValue = newValue else { return }
            self = ._imageLoader(newValue)
        }
    }
}
