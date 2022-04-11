import Foundation

struct RegisterAccountDetailsRequestBody: Codable {
    var email: String
    var username: String
    var password: String
    var registeredRegion: CountryCode
    var subscriptionType: SubscribtionType
    var isContentProvider: Bool = true
}

struct LoginRequestBody: Codable {
    var username: String
    var password: String
}

struct MediaContentRequestBody: Codable {

}
