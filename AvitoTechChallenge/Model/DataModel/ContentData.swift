import UIKit


struct Media {
    let result: Result
    var image: UIImage?
}
// MARK: - Artist

struct ArtistsInfo: Codable {
    let resultCount: Int
    let results: [Artist]
}

struct Artist: Codable {
    let wrapperType: String
    let artistType: String
    let artistName: String
    let artistLinkUrl: String
    let artistId: Int?
    let amgArtistId: Int?
    let primaryGenreName: String
    let primaryGenreId: Int?
    
    enum CodingKeys: String, CodingKey {
        case wrapperType = "wrapperType"
        case artistType = "artistType"
        case artistName = "artistName"
        case artistLinkUrl = "artistLinkUrl"
        case artistId = "artistId"
        case amgArtistId = "amgArtistId"
        case primaryGenreName = "primaryGenreName"
        case primaryGenreId = "primaryGenreId"
    }
}



// MARK: - Itunes
struct Itunes: Codable {
    let resultCount: Int
    let results: [Result]

    enum CodingKeys: String, CodingKey {
        case resultCount = "resultCount"
        case results = "results"
    }
}

// MARK: - Result
struct Result: Codable {
    let wrapperType: String?
    let kind: Kind?
    let artistName: String?
    let collectionName: String? // ?
    let trackName: String? //
    let collectionCensoredName: String?
    let trackViewURL: String?
    let artworkUrl30: String?
    let artworkUrl60: String?
    let artworkUrl100: String?
    let collectionPrice: Double?
    let trackPrice: Double?
    let collectionExplicitness: Explicitness?
    let trackExplicitness: Explicitness?
    let discCount: Int?
    let discNumber: Int?
    let trackCount: Int?
    let trackNumber: Int?
    let currency: String?
    let description: String?
    let shortDescription: String?
    let longDescription: String?
    let artistID: Int?
    let amgArtistId: Int?
    let collectionArtistName: String?

    enum CodingKeys: String, CodingKey {
        case wrapperType = "wrapperType"
        case kind = "kind"
        case amgArtistId = "amgArtistId"
        case artistName = "artistName"
        case collectionName = "collectionName"
        case trackName = "trackName"
        case collectionCensoredName = "collectionCensoredName"
        case trackViewURL = "trackViewUrl"
        case artworkUrl30 = "artworkUrl30"
        case artworkUrl60 = "artworkUrl60"
        case artworkUrl100 = "artworkUrl100"
        case collectionPrice = "collectionPrice"
        case trackPrice = "trackPrice"
        case collectionExplicitness = "collectionExplicitness"
        case trackExplicitness = "trackExplicitness"
        case discCount = "discCount"
        case discNumber = "discNumber"
        case trackCount = "trackCount"
        case trackNumber = "trackNumber"
        case currency = "currency"
        case description = "description"
        case shortDescription = "shortDescription"
        case longDescription = "longDescription"
        case artistID = "artistId"
        case collectionArtistName = "collectionArtistName"
    }
}


enum Explicitness: String, Codable {
    case explicit = "explicit"
    case notExplicit = "notExplicit"
    case cleaned = "cleaned"
}

// возьмем несколько типов контента, а остальное приведем к типу "other": по типу будем значок выбирать
enum Kind: String, Codable {
    // book, album, coached-audio, feature-movie, interactive- booklet, music-video, pdf podcast, podcast-episode, software-package, song, tv- episode, artist
    case featureMovie = "feature-movie"
    case song = "song"
    case book = "book"
    case album = "album"
    case artist = "artist"
    case audioBook = "audiobook"
    case other
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Kind(rawValue: rawValue) ?? .other
    }
}
