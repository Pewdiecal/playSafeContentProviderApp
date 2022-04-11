import Foundation

/// App network request errors
enum NetworkRequestError: Error {
    // App determined error
    case dataSerialization(reason: String?)
    case urlError(reason: String?)
    case requestToServerFailed(reason: String?)
    case notConnectedToInternet(reason: String?)
    case invalidData(reason: String?)

    // HTTP Status Code 400 range
    case badRequest(reason: String?)
    case notFound(reason: String?)
    case unauthorized(reason: String?)

    case missingRequiredField(reason: String?)

    // HTTP Status code 500 range
    case internalServerError(reason: String?)

    case limitExceeded(reason: String?)
}

extension NetworkRequestError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .dataSerialization(reason: let reason):
            return reason
        case .urlError(reason: let reason):
            return reason
        case .requestToServerFailed(reason: let reason):
            return reason
        case .notConnectedToInternet(reason: let reason):
            return reason
        case .invalidData(reason: let reason):
            return reason
        case .badRequest(reason: let reason):
            return reason
        case .notFound(reason: let reason):
            return reason
        case .unauthorized(reason: let reason):
            return reason
        case .missingRequiredField(reason: let reason):
            return reason
        case .internalServerError(reason: let reason):
            return reason
        case .limitExceeded(reason: let reason):
            return reason
        }
    }
}
