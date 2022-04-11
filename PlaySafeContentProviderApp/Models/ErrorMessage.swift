import Foundation

struct ErrorMessage: Codable {
    var error: String
}

func decodeErrorMessage(data: Data?) -> String {
    let jsonDecoder = JSONDecoder()
    if let data = data {
        let errorMessage = try? jsonDecoder.decode(ErrorMessage.self, from: data)
        return errorMessage?.error ?? ""
    } else {
        return ""
    }
}
