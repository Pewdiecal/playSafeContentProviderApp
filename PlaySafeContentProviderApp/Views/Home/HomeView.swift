import SwiftUI
import AVFoundation
import AVKit

enum SheetAction {
    case cancel
    case confirm
    case nothing
}

struct HomeView: View {
    var networkRequestService: NetworkRequestService
    @StateObject var homeViewModel: HomeViewModel
    @State private var isLoading = false
    @State private var showLogin = false
    @State private var showNewSheet = false
    @State private var mediaContent: MediaContent?
    @State private var sheetAction: SheetAction = SheetAction.nothing

    init(networkRequestService: NetworkRequestService) {
        self.networkRequestService = networkRequestService
        self._homeViewModel = StateObject(wrappedValue: HomeViewModel(networkRequestService: networkRequestService))
    }

    var rows: [GridItem] = [
        GridItem(.flexible(minimum: 300), spacing: 16)
        ]

    var columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)

    var body: some View {
        if showLogin {
            LoginView()
        } else {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns) {
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
                    .padding(10)
                }
                Spacer()
            }
            .frame(width: 800, height: 700)
            .onReceive(homeViewModel.$logoutSuccess) { isSuccess in
                if isSuccess {
                    showLogin.toggle()
                }
                isLoading = false
            }
            .sheet(item: $mediaContent, onDismiss: {
                if sheetAction != .cancel {
                    homeViewModel.fetchAllMediaContent()
                }
            }) { content in
                ContentEditorView(mediaContent: content, networkRequestService: networkRequestService, action: $sheetAction)
            }
            .onAppear(perform: homeViewModel.fetchAllMediaContent)
            .navigationTitle("Home")
            .toolbar {
                Button("Add new content") {
                    showNewSheet.toggle()
                }
                .sheet(isPresented: $showNewSheet) {
                    ContentEditorView(networkRequestService: networkRequestService, action: $sheetAction)
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
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 10)
                .opacity(isLoading ? 1 : 0))
        }
    }
}
