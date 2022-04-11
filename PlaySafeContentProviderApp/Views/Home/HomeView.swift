import SwiftUI
import AVFoundation
import AVKit

struct HomeView: View {
    var networkRequestService: NetworkRequestService
    @StateObject var homeViewModel: HomeViewModel
    @State private var isLoading = false
    @State private var showLogin = false
    @State private var showEditSheet = false
    @State private var showNewSheet = false

    init(networkRequestService: NetworkRequestService) {
        self.networkRequestService = networkRequestService
        self._homeViewModel = StateObject(wrappedValue: HomeViewModel(networkRequestService: networkRequestService))
    }

    var rows: [GridItem] = [
        GridItem(.flexible(minimum: 300), spacing: 16)
        ]

    var body: some View {
        if showLogin {
            LoginView()
        } else {
            VStack {
                ScrollView {
                    LazyHGrid(rows: rows,
                              spacing: 10) {
                        ForEach(homeViewModel.mediaContents, id: \.self) { mediaContent in
                            Button {
                                showEditSheet.toggle()
                            } label: {
                                MediaCatalogueCellView(imageUrl: "\(apiBaseUrl)\(mediaContent.contentCovertArtUrl!)",
                                                       title: mediaContent.contentName!, genre: mediaContent.genre!.rawValue)
                            }
                            .sheet(isPresented: $showEditSheet) {
                                ContentEditorView(mediaContent: mediaContent, networkRequestService: networkRequestService)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.leading, 12)
                }
                .padding(.leading, 10)
                Spacer()
            }
            .frame(width: 800, height: 700)
            .onReceive(homeViewModel.$logoutSuccess) { isSuccess in
                if isSuccess {
                    showLogin.toggle()
                }
                isLoading = false
            }
            .onAppear(perform: homeViewModel.fetchAllMediaContent)
            .navigationTitle("Home")
            .toolbar {
                Button("Add new content") {
                    showNewSheet.toggle()
                }
                .sheet(isPresented: $showNewSheet) {
                    ContentEditorView(networkRequestService: networkRequestService)
                }
                Button("Logout") {
                    isLoading = true
                    homeViewModel.logout()
                }
                Button("Refresh") {
                    homeViewModel.fetchAllMediaContent()
                }
            }
            .overlay(ProgressView("Logging out ...")
                .padding()
                .background(Color.black)
                .cornerRadius(10)
                .shadow(radius: 10)
                .opacity(isLoading ? 1 : 0))
        }
    }
}
