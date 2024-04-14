
import Combine
import Foundation

final class DetailedInfoViewModel<T: MediaAPI>: DetailedInfoViewModelProtocol {
    internal var model: T
    
    init(model: T) {
        self.model = model
    }
    
    public func fetchDetails(with id: Int?) -> AnyPublisher<Artist, T.ErrorType> {
        return model.lookup(with: id)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

protocol DetailedInfoViewModelProtocol {
    associatedtype T: MediaAPI
    var model: T { get set }
    
    init(model: T)
    
    func fetchDetails(with id: Int?) -> AnyPublisher<Artist, T.ErrorType>
}


