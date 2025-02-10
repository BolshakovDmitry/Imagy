import Foundation

protocol NetworkRouting {
    associatedtype T: Codable // Ассоциированный тип, который должен соответствовать протоколу Codable
    
    func fetch(_ type: T.Type, urlRequest: URLRequest, requiresCodeCheck: Bool?, handler: @escaping (Result<T, Error>) -> Void)
}
