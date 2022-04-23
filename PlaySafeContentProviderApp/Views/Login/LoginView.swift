import SwiftUI

struct LoginView: View {
    @StateObject private var loginViewModel = LoginViewModel()
    @State private var username = ""
    @State private var password = ""
    @State private var navigateToRegisterAccount = false
    @State private var isLoading = false
    @State private var showRegistration = false
    @State private var showHome = false

    var body: some View {
        if showRegistration {
            RegisterAcccountView()
        } else if showHome {
            HomeView(networkRequestService: loginViewModel.networkRequestService ?? NetworkRequestService())
        } else {
            VStack {
                    Text("Welcome to PlaySafe Content Management Demo App")
                        .font(.system(size: 30))
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.vertical, 30)

                    Form {
                        TextField("Username", text: $username)
                        SecureField("Password", text: $password)
                        Button("Login") {
                            loginViewModel.login(username: username, password: password)
                            isLoading = true
                        }

                        Button("Register Acccount") {
                            showRegistration.toggle()
                        }
                    }
                    .padding()

                    Spacer()
            }
            .onReceive(loginViewModel.$isSuccess) { isSuccess in
                isLoading = false
                if isSuccess {
                    showHome.toggle()
                }
            }
            .alert(loginViewModel.errorMessage ?? "", isPresented: $loginViewModel.showingAlert) {
                Button("OK", role: .cancel) {
                    isLoading = false
                }
            }
            .overlay(ProgressView("Logging In ...")
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .opacity(isLoading ? 1 : 0))
        }
    }
}
