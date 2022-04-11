import Foundation
import Combine

class LoginViewModel: ObservableObject {
    init() {
        self.authService = AuthService()
    }

    func login(username: String, password: String) {
        authService.fetchAccessToken(username: username, password: password)
            .sink { [weak self] completion in
                guard let strongSelf = self else {
                    return
                }
                switch completion {
                case .failure(let error):
                    trace("Login failed with error: \(error.localizedDescription)")
                    strongSelf.errorMessage = error.localizedDescription
                    strongSelf.showingAlert = true
                case .finished:
                    break
                }
            } receiveValue: { [weak self] token in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.networkRequestService = NetworkRequestService(authService: strongSelf.authService)
                trace("Login Success")
                strongSelf.isSuccess = true
                strongSelf.isCredentialValid = true
            }
            .store(in: &cancelleble)
    }

    let authService: AuthService
    private var cancelleble: Set<AnyCancellable> = Set()
    @Published var networkRequestService: NetworkRequestService? = nil
    @Published var isCredentialValid: Bool = false
    @Published var showingAlert = false
    @Published var errorMessage: String?
    @Published var isSuccess = false
}

