import Foundation
import Combine

struct Token: Codable {
    let accessToken: String

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.accessToken = try values.decode(String.self, forKey: .accessToken)
    }

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

class AuthService {
    func fetchAccessToken(username: String, password: String) -> AnyPublisher<User, Error> {
        var request = URLRequest(url: NetworkRequestService.baseUrl!.appendingPathComponent("/api/auth/login"))
        request.httpMethod = URLRequest.HTTPMethod.post.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let requestBody = LoginRequestBody(username: username, password: password)
        let data = try? JSONEncoder().encode(requestBody)
        request.httpBody = data!

        return urlSession.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpURLResponse = response as? HTTPURLResponse,
                      (200 ... 299).contains(httpURLResponse.statusCode)
                else {
                    throw self.handleResponseFailure(data: data, response: response)
                }

                return data
            }
            .decode(type: Token.self, decoder: JSONDecoder())
            .map { token -> Token in
                self.accessToken = token
                return token
            }
            .flatMap { [weak self] token -> AnyPublisher<User, Error> in
                guard let strongSelf = self else {
                    return Empty().eraseToAnyPublisher()
                }
                var request = URLRequest(url: NetworkRequestService.baseUrl!.appendingPathComponent("/api/auth/me"))
                request.httpMethod = URLRequest.HTTPMethod.post.rawValue
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
                return strongSelf.urlSession.dataTaskPublisher(for: request)
                    .tryMap { data, response in
                        guard let httpURLResponse = response as? HTTPURLResponse,
                              (200 ... 299).contains(httpURLResponse.statusCode)
                        else {
                            throw strongSelf.handleResponseFailure(data: data, response: response)
                        }

                        return data
                    }
                    .decode(type: User.self, decoder: JSONDecoder())
                    .mapError({ error in
                        print(error)
                        return error
                    })
                    .eraseToAnyPublisher()
            }
            .map { user in
                self.user = user
                return user
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    private func handleResponseFailure(
        data: Data?,
        response: URLResponse
    ) -> NetworkRequestError {
        var error = NetworkRequestError.badRequest(reason: decodeErrorMessage(data: data))

        if let response = response as? HTTPURLResponse {
            switch response.statusCode {
            case 401:
                error = NetworkRequestError.unauthorized(reason: decodeErrorMessage(data: data))

            case 404:
                error = NetworkRequestError.notFound(reason: decodeErrorMessage(data: data))

            default:
                break
            }
        }

        return error
    }

    private let urlSession = URLSession.shared
    var accessToken: Token?
    var user: User?
}

