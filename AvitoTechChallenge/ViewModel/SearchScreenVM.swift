import Combine
import UIKit

enum ViewState {
    case loading
    case loaded
    case error(iTunesApi.iTunesError)
}

final class SearchScreenVM<T: MediaAPI>: ObservableObject, searchVM {
    // костыль: нельзя в протокол нельзя прописать @Published поля, но можно прописать Publisher
    var suggestionsPublisher: Published<[Suggestion]>.Publisher { $suggestions }
    var mediaPublisher: Published<[Media]>.Publisher { $media }
    var viewStatePublisher: Published<ViewState>.Publisher { $viewState }
    
    @Published var suggestions: [Suggestion] = []
    @Published var media: [Media] = []
    @Published var viewState: ViewState = .loaded
    
    let contentAPI: T
    let suggestionAPI = SuggestionEngine()
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(model: T) {
        contentAPI = model
        fetchSuggestions(with: "")
    }
    
    // загружаем изображения
    private func fetchImages() {
        for i in 0..<media.count {
            contentAPI.fetchImage(from: URL(string: media[i].result.artworkUrl100 ?? ""))
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { _ in
                   
                }, receiveValue: { [weak self] in
                    self?.media[i].image = $0
                })
                .store(in: &subscriptions)
        }
    }
    
    // опустошаем переменную с медиаконтентом
    public func clearMedia() {
        media = []
    }
    
    // загружаем контент с изображениями
    public func fetchContentWithImages(with input: String) {
        contentAPI.fetchMediawithImage(for: input, limit: 30)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.viewState = .error(error as! iTunesApi.iTunesError)
                case .finished:
                    self.viewState = .loaded
                    break
                }
            }, receiveValue: { [weak self] data in
                // костыльно: так как ссылка на изображения лежит в ответе, после получения нужно обращаться к серверу за картинками
                self?.media = []
                for result in data {
                    self?.media.append(Media(result: result))
                }
                self?.fetchImages()
                self?.viewState = .loaded
            })
            .store(in: &subscriptions)
    }
    
    // получаем предложения по введенной строку
    public func fetchSuggestions(with input: String) {
        suggestions = suggestionAPI.getSuggestions(with: input)
    }
    
    // добавляем предложение
    public func createNewSuggestion(with input: String) {
        suggestionAPI.saveSuggestion(for: input)
    }
    
    // очищаем предложения
    public func voidSuggestions() {
        self.suggestions = []
    }
}


protocol searchVM {
    var suggestionsPublisher: Published<[Suggestion]>.Publisher { get }
    var mediaPublisher: Published<[Media]>.Publisher { get }
    var viewStatePublisher: Published<ViewState>.Publisher { get }
    
    var suggestions: [Suggestion] { get set }
    var media: [Media] { get set }
    var viewState: ViewState { get set }
    
    func clearMedia()
    
    func fetchContentWithImages(with input: String)
    
    func fetchSuggestions(with input: String)
    
    func createNewSuggestion(with input: String)
    
    func voidSuggestions()
    
}
