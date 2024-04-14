import Combine
import UIKit

final class iTunesApi: MediaAPI {
    // перечисления с ошибками и их описаниями
    enum iTunesError: String, Error {
        case invalidURL = "URL is invalid"
        case unknownError = "Unknown error"
        case noArtistFound = "Detailed info not available"
        case noResultsFound = "No results found"
    }
    typealias ErrorType = iTunesError
    
    private let decoder = JSONDecoder()
    
    private let contentSearchBaseLink: String = "https://itunes.apple.com/search?"
    private let lookupBaseLink: String = "https://itunes.apple.com/lookup?id="
    
    public func fetchImage(from url: URL?) -> AnyPublisher<UIImage, ErrorType> {
        guard let url = url else {
            return Fail(error: iTunesError.invalidURL)
                .eraseToAnyPublisher()
        }
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .tryMap { data -> UIImage in
                guard let image = UIImage(data: data) else {
                    throw iTunesError.unknownError
                }
                return image
            }
            .catch { error -> AnyPublisher<UIImage, ErrorType> in
                if let itunesError = error as? iTunesError {
                    return Fail(error: itunesError)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: iTunesError.unknownError)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    
    public func lookup(with artistID: Int?) -> AnyPublisher<Artist, ErrorType> {
        guard let artistID = artistID else {
            return Fail(error: iTunesError.noArtistFound)
                .eraseToAnyPublisher()
        }
        let link = lookupBaseLink+"\(artistID)"
        guard let url = URL(string: link) else {
            return Fail(error: iTunesError.invalidURL)
                .eraseToAnyPublisher()
        }
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: ArtistsInfo.self, decoder: decoder)
            .tryMap { artistsInfo -> Artist in
                guard let firstArtist = artistsInfo.results.first else {
                    throw iTunesError.noArtistFound
                }
                return firstArtist
            }
            .catch { error -> AnyPublisher<Artist, ErrorType> in
                if let itunesError = error as? iTunesError {
                    return Fail(error: itunesError)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: iTunesError.unknownError)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    public func fetchMediawithImage(for query: String, limit: Int = 30 ) -> AnyPublisher<[Result], ErrorType> {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let link = contentSearchBaseLink + "term=\(encodedQuery)"
        
        guard let url = URL(string: link) else {
            return Fail(error: iTunesError.invalidURL)
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: Itunes.self, decoder: decoder)
            .tryMap { itunes -> [Result] in
                if itunes.resultCount == 0 {
                    throw iTunesError.noResultsFound
                }
                return itunes.results
            }
            .map { results in
                // уберем результаты, которые не имеют ссылки на трек
                results.filter { $0.trackViewURL != nil }
            }
            .prefix(limit) // возьмем первые n объектов, ибо запросили больше с расчетом на фильтр по ссылке
            .catch { error -> AnyPublisher<[Result], ErrorType> in
                if let itunesError = error as? iTunesError {
                    return Fail(error: itunesError)
                        .eraseToAnyPublisher()
                } else {
                    return Fail(error: iTunesError.unknownError)
                        .eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - протокол для DI
protocol MediaAPI {
    associatedtype ErrorType: Error
    func fetchImage(from url: URL?) -> AnyPublisher<UIImage, ErrorType>
    func lookup(with artistID: Int?) -> AnyPublisher<Artist, ErrorType>
    func fetchMediawithImage(for query: String, limit: Int) -> AnyPublisher<[Result], ErrorType>
}
