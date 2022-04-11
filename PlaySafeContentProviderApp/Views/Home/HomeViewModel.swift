import Foundation
import Combine

class HomeViewModel: ObservableObject {
    init(networkRequestService: NetworkRequestService) {
        self.networkRequestService = networkRequestService
        self.authService = networkRequestService.authService!
    }

    func fetchAllMediaContent() {
        networkRequestService.apiRequest(.get, "/api/media/getProviderContentList/",
                                         requestBody: nil,
                                         queryItems: nil)
            .map { (data, Int) in
                return data
            }
            .decode(type: [MediaContent].self, decoder: JSONDecoder())
            .mapError { error -> NetworkRequestError in
                trace("Decoding error: \(error.localizedDescription)")
                return NetworkRequestError.dataSerialization(reason: error.localizedDescription)
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    trace("getContentList API request error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] mediaContents in
                guard let strongSelf = self else {
                    return
                }

                strongSelf.mediaContents = mediaContents
            }
            .store(in: &cancelleble)
    }

    func logout() {
        networkRequestService.apiRequest(.post, "/api/auth/logout", requestBody: nil, queryItems: nil)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    trace("getContentList API request error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            } receiveValue: { [weak self] _ in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.logoutSuccess = true
            }
            .store(in: &cancelleble)
    }

    private let networkRequestService: NetworkRequestService
    private let authService: AuthService
    private var cancelleble: Set<AnyCancellable> = Set()
    @Published var errorMessage: String?
    @Published var mediaContents: [MediaContent] = []
    @Published var showingAlert = false
    @Published var logoutSuccess = false
}
