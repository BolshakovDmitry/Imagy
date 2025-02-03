
import Foundation

protocol NetworkRouting {
    func fetch(urlrequest: URLRequest, requiresCodeCheck: Bool?, handler: @escaping (Result<Data, Error>) -> Void)
}
