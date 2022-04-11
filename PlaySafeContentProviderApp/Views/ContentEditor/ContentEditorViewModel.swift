import Foundation
import Combine

class ContentEditorViewModel: ObservableObject {
    init(mediaContent: MediaContent? = nil, networkRequestService: NetworkRequestService) {
        self.mediaContent = mediaContent
        self.networkRequestService = networkRequestService
    }

    func deleteContentFromServer() {
        if let id = mediaContent?.contentId {
            networkRequestService.apiRequest(.post, "/api/media/removeContent/\(id)",
                                             requestBody: nil,
                                             queryItems: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let strongSelf = self else {
                    return
                }
                switch completion {
                case .failure(let error):
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.showingAlert = true
                    trace("Deletion error: \(error)")
                case .finished:
                    trace("Delete Success")
                }
            } receiveValue: { [weak self] (data: Data, httpResponseCode: Int) in
                guard let strongSelf = self else {
                    return
                }
                if (200 ... 299).contains(httpResponseCode) {
                    strongSelf.isSuccess = true
                    trace("Delete Success")
                } else {
                    strongSelf.errorMessage = "Alert: Bad response code \(httpResponseCode)."
                    strongSelf.showingAlert = true
                }
            }
            .store(in: &cancelleble)
        }
    }

    var mediaContent: MediaContent?
    var networkRequestService: NetworkRequestService
    @Published var errorMessage: String? = nil
    @Published var isSuccess: Bool = false
    @Published var showingAlert = false
    private var cancelleble: Set<AnyCancellable> = Set()
}
