import Foundation
import Combine

class NetworkRequestService {

    init(authService: AuthService) {
        self.authService = authService
    }

    init() {}

    func apiRequest(_ method: URLRequest.HTTPMethod,
                    _ path: String,
                    requestBody: Data? = nil,
                    queryItems: [URLQueryItem]? = nil) -> AnyPublisher<(Data, Int), Error>{
        var apiURL: URL?
        guard var urlComponents = URLComponents(url: NetworkRequestService.baseUrl!.appendingPathComponent(path),
                                                resolvingAgainstBaseURL: false
        ) else {
            return Empty().eraseToAnyPublisher()
        }

        // Append query items.
        urlComponents.queryItems = queryItems
        apiURL = urlComponents.url

        guard let url = apiURL else {
            return Empty().eraseToAnyPublisher()
        }

        var request: URLRequest = .init(url: url)
        request.httpMethod = method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Accept-Encoding", forHTTPHeaderField: "gzip")

        if let accessToken = authService?.accessToken {
            request.setValue("Bearer \(accessToken.accessToken)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = requestBody

        return sendRequest(request)
    }

    private func sendRequest(_ request: URLRequest) -> AnyPublisher<(Data, Int), Error> {
        return urlSession.dataTaskPublisher(for: request)
            .mapError { _ in
                return NetworkRequestError.requestToServerFailed(reason: "Request to server failed")
            }
            .tryMap { data, response in
                guard let httpURLResponse = response as? HTTPURLResponse, (200 ... 299).contains(httpURLResponse.statusCode) else {
                    throw self.handleResponseFailure(data: data,
                                                    response: response)
                }
                return (data, httpURLResponse.statusCode)
            }
            .eraseToAnyPublisher()
    }

    private func handleResponseFailure(
        data: Data?,
        response: URLResponse?
    ) -> NetworkRequestError {
        var error = NetworkRequestError.badRequest(reason: decodeErrorMessage(data: data))

        if let response = response as? HTTPURLResponse {
            switch response.statusCode {
            case 400:
                guard let data = data else {
                    break
                }
                print("Network request missing required field error (Data): \(String(decoding: data, as: UTF8.self))")
                error = NetworkRequestError.missingRequiredField(reason: String(decoding: data, as: UTF8.self))
            case 401:
                error = NetworkRequestError.unauthorized(reason: decodeErrorMessage(data: data))
            case 404:
                error = NetworkRequestError.notFound(reason: decodeErrorMessage(data: data))
            case 500:
                error = NetworkRequestError.internalServerError(reason: decodeErrorMessage(data: nil))
            default:
                break
            }
        }

        return error
    }

    private let urlSession = URLSession.shared
    var authService: AuthService?
    static let baseUrl = URL(string: apiBaseUrl)
}

extension URLRequest {
    public enum HTTPMethod: String {
        case options = "OPTIONS"
        case get = "GET"
        case head = "HEAD"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
        case trace = "TRACE"
        case connect = "CONNECT"
    }
}
