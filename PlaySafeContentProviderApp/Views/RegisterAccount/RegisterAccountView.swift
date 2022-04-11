import SwiftUI

struct RegisterAcccountView: View {
    @State private var email = ""
    @State private var username = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var countryCode: CountryCode = .MY
    @State private var isLoading = false
    @State private var showHome = false
    @StateObject private var viewModel = RegisterAccountViewModel()

    var body: some View {
        if showHome {
            LoginView()
        } else {
            VStack {
                Text("Welcome to PlaySafe Streaming Demo App")
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding()

                Form {
                    TextField("Email", text: $email)

                    TextField("Username", text: $username)

                    SecureField("New Password", text: $newPassword)

                    SecureField("Confirm Password", text: $confirmPassword)

                    Picker(selection: $countryCode, label: Text("Select your country")) {
                        Text("Malaysia").tag(CountryCode.MY)
                        Text("South Korea").tag(CountryCode.KR)
                        Text("Japan").tag(CountryCode.JP)
                        Text("Singapore").tag(CountryCode.SG)
                        Text("Thailand").tag(CountryCode.TH)
                        Text("Australia").tag(CountryCode.AU)
                        Text("Hong Kong").tag(CountryCode.HK)
                    }

                    Button("Confirm") {
                        viewModel.registerAccount(email: email,
                                                  username: username,
                                                  password: newPassword,
                                                  confirmPassword: confirmPassword,
                                                  countryCode: countryCode)
                        isLoading = true
                    }

                    Button("Back to login page") {
                        showHome.toggle()
                    }
                }
                .padding()

                Spacer()
            }
            .frame(maxWidth: 1500, maxHeight: 700)
            .navigationTitle("Register Account")
            .onReceive(viewModel.$isSuccess) { isSuccess in
                if isSuccess {
                    showHome.toggle()
                }
                isLoading = false
            }
            .alert(viewModel.errorMessage ?? "", isPresented: $viewModel.showingAlert) {
                Button("OK", role: .cancel) {
                    isLoading = false
                }
            }
            .overlay(ProgressView("Registering account ...")
                .padding()
                .background(Color.black)
                .cornerRadius(10)
                .shadow(radius: 10)
                .opacity(isLoading ? 1 : 0))
        }
    }
}
