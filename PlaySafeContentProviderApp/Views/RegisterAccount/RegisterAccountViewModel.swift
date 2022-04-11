import Foundation
import Combine

class RegisterAccountViewModel: ObservableObject {
    init() {
        self.networkRequestService = NetworkRequestService()
    }

    func registerAccount(email: String,
                         username: String,
                         password: String,
                         confirmPassword: String,
                         countryCode: CountryCode) {
        let requestBody = RegisterAccountDetailsRequestBody(email: email,
                                                            username: username,
                                                            password: password,
                                                            registeredRegion: countryCode,
                                                            subscriptionType: .basic)

        do {
            let data = try JSONEncoder().encode(requestBody)
            self.networkRequestService.apiRequest(.post, "/api/auth/register", requestBody: data, queryItems: nil)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let strongSelf = self else {
                        return
                    }
                    switch completion {
                    case .failure(let error):
                        strongSelf.errorMessage = error.localizedDescription
                        strongSelf.showingAlert = true
                        trace("Registration error: \(error)")
                    case .finished:
                        trace("Registration Success")
                    }
                } receiveValue: { [weak self] (data: Data, httpResponseCode: Int) in
                    guard let strongSelf = self else {
                        return
                    }
                    if (200 ... 299).contains(httpResponseCode) {
                        strongSelf.isSuccess = true
                        trace("Registration Success")
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

    private var networkRequestService: NetworkRequestService
    private var cancelleble: Set<AnyCancellable> = Set()
    @Published var errorMessage: String? = nil
    @Published var isSuccess: Bool = false
    @Published var showingAlert = false
}
