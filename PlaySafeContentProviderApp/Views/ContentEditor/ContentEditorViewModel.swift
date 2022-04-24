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

    func editContentMetadata() {
        if mediaContent != nil {
            do {
                let data = try JSONEncoder().encode(mediaContent)
                self.networkRequestService.apiRequest(.post, "/api/media/editContentMetadata", requestBody: data, queryItems: nil)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] completion in
                        guard let strongSelf = self else {
                            return
                        }
                        switch completion {
                        case .failure(let error):
                            strongSelf.errorMessage = error.localizedDescription
                            strongSelf.showingAlert = true
                            trace("Edit metadata error: \(error)")
                        case .finished:
                            trace("Edit metadata Success")
                        }
                    } receiveValue: { [weak self] (data: Data, httpResponseCode: Int) in
                        guard let strongSelf = self else {
                            return
                        }
                        if (200 ... 299).contains(httpResponseCode) {
                            strongSelf.isSuccess = true
                            trace("Edit metadata Success")
                        } else {
                            strongSelf.errorMessage = "Alert: Bad response code \(httpResponseCode)."
                            strongSelf.showingAlert = true
                        }
                    }
                    .store(in: &cancelleble)
            } catch {
                trace("\(error)")
                errorMessage = "Something when wrong, please contact administrator for further assistance."
                showingAlert = true
            }
        }
    }

    func manualKeyRotation() {
        if let id = mediaContent?.contentId {
            networkRequestService.apiRequest(.post, "/api/media/rotateKey/\(id)",
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
                    trace("Key rotate error: \(error)")
                case .finished:
                    trace("Key rotate request sent Success")
                }
            } receiveValue: { [weak self] (data: Data, httpResponseCode: Int) in
                guard let strongSelf = self else {
                    return
                }
                if (200 ... 299).contains(httpResponseCode) {
                    strongSelf.isSuccess = true
                    trace("Key rotate request sent Success")
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
