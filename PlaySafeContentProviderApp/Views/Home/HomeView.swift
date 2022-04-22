import SwiftUI
import AVFoundation
import AVKit

struct HomeView: View {
    var networkRequestService: NetworkRequestService
    @StateObject var homeViewModel: HomeViewModel
    @State private var isLoading = false
    @State private var showLogin = false
    @State private var showNewSheet = false
    @State private var mediaContent: MediaContent?

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
                        ForEach(homeViewModel.mediaContents, id: \.self) { content in
                            Button {
                                self.mediaContent = content
                            } label: {
                                MediaCatalogueCellView(imageUrl: "\(apiBaseUrl)\(content.contentCovertArtUrl!)",
                                                       title: content.contentName!, genre: content.genre!.rawValue)
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
            .sheet(item: $mediaContent) { content in
                ContentEditorView(mediaContent: content, networkRequestService: networkRequestService)
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
