
import Foundation

protocol NetworkRouting {
    func fetch(urlrequest: URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
}
