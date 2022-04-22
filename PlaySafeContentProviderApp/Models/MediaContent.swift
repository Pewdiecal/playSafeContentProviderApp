import Foundation

struct MediaContent: Codable, Identifiable, Hashable {
    let id = UUID()
    var contentId: Int?
    var contentName: String?
    var genre: Genre?
    var contentDescription: String?
    var availableRegions: CountryCode?
    var contentCovertArtUrl: String?
    var maxQualityPremium: StreamingResolution
    var maxQualityStandard: StreamingResolution
    var maxQualityBasic: StreamingResolution
    var maxQualityBudget: StreamingResolution
    var maxQualityPremiumTrial: StreamingResolution

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.contentId = try values.decodeIfPresent(Int.self, forKey: .contentId)
        self.contentName = try values.decode(String.self, forKey: .contentName)
        self.genre = try values.decode(Genre.self, forKey: .genre)
        self.contentDescription = try values.decode(String.self, forKey: .contentDescription)
        self.availableRegions = try values.decode(CountryCode.self, forKey: .availableRegions)
        self.contentCovertArtUrl = try values.decode(String.self, forKey: .contentCovertArtUrl)
        self.maxQualityPremium = try values.decode(StreamingResolution.self, forKey: .maxQualityPremium)
        self.maxQualityStandard = try values.decode(StreamingResolution.self, forKey: .maxQualityStandard)
        self.maxQualityBasic = try values.decode(StreamingResolution.self, forKey: .maxQualityBasic)
        self.maxQualityBudget = try values.decode(StreamingResolution.self, forKey: .maxQualityBudget)
        self.maxQualityPremiumTrial = try values.decode(StreamingResolution.self, forKey: .maxQualityPremiumTrial)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(contentId, forKey: .contentId)
        try container.encode(contentName, forKey: .contentName)
        try container.encode(genre, forKey: .genre)
        try container.encode(contentDescription, forKey: .contentDescription)
        try container.encode(availableRegions, forKey: .availableRegions)
        try container.encode(maxQualityPremium, forKey: .maxQualityPremium)
        try container.encode(maxQualityStandard, forKey: .maxQualityStandard)
        try container.encode(maxQualityBasic, forKey: .maxQualityBasic)
        try container.encode(maxQualityBudget, forKey: .maxQualityBudget)
        try container.encode(maxQualityPremiumTrial, forKey: .maxQualityPremiumTrial)
    }

    enum CodingKeys: String, CodingKey {
        case contentId = "content_id"
        case contentName = "content_name"
        case genre
        case contentDescription = "content_description"
        case availableRegions = "available_regions"
        case contentCovertArtUrl = "content_cover_art_url"
        case maxQualityPremium = "max_quality_premium"
        case maxQualityStandard = "max_quality_standard"
        case maxQualityBasic = "max_quality_basic"
        case maxQualityBudget = "max_quality_budget"
        case maxQualityPremiumTrial = "max_quality_premiumTrial"
    }
}
