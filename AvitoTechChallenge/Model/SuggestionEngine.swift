
import Foundation

final class SuggestionEngine {
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private let key = "savedSuggestions"
    // синглтон, ай-ай-ай, нарушение DI
    public static let shared = SuggestionEngine()
    
    // метод для сохранения нового предложения
    public func saveSuggestion(for query: String) {
        // по дате найдем самый старый индекс
        func findTheOldestQueryIndex(suggestions: [Suggestion]) -> Int {
            var oldestIndex = 0 // индекс самого старого запроса
            var oldestDate = Date.now // дата
            for (index, suggestion) in suggestions.enumerated() {
                if oldestDate >= suggestion.date {
                    oldestIndex = index
                    oldestDate = suggestion.date
                }
            }
            return oldestIndex
        }
        
        let input = Suggestion(date: Date.now, query: query)
        if let encodedData = try? encoder.encode(input) {
            var savedInputs: [Data] = userDefaults.array(forKey: key) as? [Data] ?? []
            // по условию, сохраняется до 5 запросов: удаляем самый старый
            if savedInputs.count >= 5 {
                savedInputs.remove(at: findTheOldestQueryIndex(suggestions: savedInputs.compactMap { try? decoder.decode(Suggestion.self, from: $0) }))
            }
            savedInputs.append(encodedData)
            userDefaults.set(savedInputs, forKey: key)
        }
    }
    
    // получим предложения по введенному тексту
    public func getSuggestions(with query: String) -> [Suggestion] {
        // функция для фильтрации предложений
        func hasOccurrence(suggestionText: String, query: String) -> Bool {
            return suggestionText.range(of: query, options: .caseInsensitive) != nil
        }
            guard let savedInputsData = userDefaults.array(forKey: key) as? [Data] else {
                return []
            }
            var savedInputs: [Suggestion] = []
            for data in savedInputsData {
                if let input = try? decoder.decode(Suggestion.self, from: data) {
                    savedInputs.append(input)
                }
            }
        if query == "" { return savedInputs}
        return savedInputs.filter { return hasOccurrence(suggestionText: $0.query, query: query) }
    }
    
    // отчистим все значения из UserDefaults если захотим подебажить
    public func clearSuggestions() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
