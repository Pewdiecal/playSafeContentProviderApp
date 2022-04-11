import Foundation

enum CountryCode: String, Codable {
    case MY
    case KR
    case JP
    case SG
    case TH
    case AU
    case HK
}

enum StreamingResolution: String, Codable {
    case fullHD_1080 = "1080p"
    case HD_720 = "720p"
    case SD_480 = "480p"
    case SD_360 = "360p"
    case SD_240 = "240p"
    case SD_144 = "144p"
}

enum SubscribtionType: String, Codable {
    case premium = "premium"
    case standard = "standard"
    case basic = "basic"
    case budget = "budget"
    case premiumTrial = "premiumTrial"
}

enum Genre: String, Codable, CaseIterable {
    case comedy
    case kpop
    case horror
    case relaxing
    case sci_fi
    case drama
}
