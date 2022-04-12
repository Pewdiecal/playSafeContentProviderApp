import SwiftUI

struct ContentEditorView: View {
    @State private var contentName = ""
    @State private var rawMediaFile = ""
    @State private var coverArtFile = ""
    @State private var contentDescription = ""
    @State private var availableRegion: CountryCode = .MY
    @State private var genre: Genre = .kpop
    @State private var premiumRes: StreamingResolution = .fullHD_1080
    @State private var standardRes: StreamingResolution = .HD_720
    @State private var basicRes: StreamingResolution = .SD_480
    @State private var budgetRes: StreamingResolution = .SD_360
    @State private var premiumTrialRes: StreamingResolution = .fullHD_1080
    @State private var encryptMedia = true
    @State private var isLoading = false
    @State private var progressAmount = 0.0
    @State private var showProgress = false
    @State private var showAlert = false
    @State private var showDeleteProgress = false
    @State private var progressText = ""
    @StateObject private var viewModel: ContentEditorViewModel
    @Environment(\.dismiss) var dismiss
    let progressCount = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    init(mediaContent: MediaContent? = nil, networkRequestService: NetworkRequestService) {
        self._viewModel = StateObject(wrappedValue: ContentEditorViewModel(mediaContent: mediaContent,
                                                                           networkRequestService: networkRequestService))
    }

    var body: some View {
        VStack {
            Form {
                TextField("Content Name", text: $contentName)
                TextField("Content Description", text: $contentDescription)

                Picker(selection: $availableRegion, label: Text("Select region")) {
                    Text("Malaysia").tag(CountryCode.MY)
                    Text("South Korea").tag(CountryCode.KR)
                    Text("Japan").tag(CountryCode.JP)
                    Text("Singapore").tag(CountryCode.SG)
                    Text("Thailand").tag(CountryCode.TH)
                    Text("Australia").tag(CountryCode.AU)
                    Text("Hong Kong").tag(CountryCode.HK)
                }
                Picker(selection: $genre, label: Text("Select genre")) {
                    Text("Kpop").tag(Genre.kpop)
                    Text("Comedy").tag(Genre.comedy)
                    Text("Horror").tag(Genre.horror)
                    Text("Relaxing").tag(Genre.relaxing)
                    Text("Sci-Fi").tag(Genre.sci_fi)
                    Text("Drama").tag(Genre.drama)
                }

                Picker(selection: $premiumRes, label: Text("Premium resolution")) {
                    Text("1080p Full HD").tag(StreamingResolution.fullHD_1080)
                    Text("720p HD").tag(StreamingResolution.HD_720)
                    Text("480p SD").tag(StreamingResolution.SD_480)
                    Text("360p SD").tag(StreamingResolution.SD_360)
                    Text("240p SD").tag(StreamingResolution.SD_240)
                    Text("144p SD").tag(StreamingResolution.SD_144)
                }

                Picker(selection: $standardRes, label: Text("Standard resolution")) {
                    Text("1080p Full HD").tag(StreamingResolution.fullHD_1080)
                    Text("720p HD").tag(StreamingResolution.HD_720)
                    Text("480p SD").tag(StreamingResolution.SD_480)
                    Text("360p SD").tag(StreamingResolution.SD_360)
                    Text("240p SD").tag(StreamingResolution.SD_240)
                    Text("144p SD").tag(StreamingResolution.SD_144)
                }

                Picker(selection: $basicRes, label: Text("Basic resolution")) {
                    Text("1080p Full HD").tag(StreamingResolution.fullHD_1080)
                    Text("720p HD").tag(StreamingResolution.HD_720)
                    Text("480p SD").tag(StreamingResolution.SD_480)
                    Text("360p SD").tag(StreamingResolution.SD_360)
                    Text("240p SD").tag(StreamingResolution.SD_240)
                    Text("144p SD").tag(StreamingResolution.SD_144)
                }

                Picker(selection: $budgetRes, label: Text("Budget resolution")) {
                    Text("1080p Full HD").tag(StreamingResolution.fullHD_1080)
                    Text("720p HD").tag(StreamingResolution.HD_720)
                    Text("480p SD").tag(StreamingResolution.SD_480)
                    Text("360p SD").tag(StreamingResolution.SD_360)
                    Text("240p SD").tag(StreamingResolution.SD_240)
                    Text("144p SD").tag(StreamingResolution.SD_144)
                }

                Picker(selection: $premiumTrialRes, label: Text("Premium Trial resolution")) {
                    Text("1080p Full HD").tag(StreamingResolution.fullHD_1080)
                    Text("720p HD").tag(StreamingResolution.HD_720)
                    Text("480p SD").tag(StreamingResolution.SD_480)
                    Text("360p SD").tag(StreamingResolution.SD_360)
                    Text("240p SD").tag(StreamingResolution.SD_240)
                    Text("144p SD").tag(StreamingResolution.SD_144)
                }

                Toggle("Enable encryption", isOn: $encryptMedia)
                    .toggleStyle(.checkbox)
            }
            HStack {
                Text("Upload Media File: ")
                Text(rawMediaFile)
                    .frame(width: 200)
                Button("Choose File") {
                    let dialog = NSOpenPanel();
                    dialog.title = "Choose a media file";
                    dialog.showsResizeIndicator = true;
                    dialog.showsHiddenFiles = false;
                    dialog.allowsMultipleSelection = false;
                    dialog.canChooseDirectories = false;
                    dialog.allowedFileTypes = ["mp4", "mov"];

                    if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
                        let result = dialog.url // Pathname of the file

                        if (result != nil) {
                            rawMediaFile = result!.pathComponents.last!
                        }

                    } else {
                        // User clicked on "Cancel"
                        return
                    }
                }
            }
            .padding(.bottom, 0)

            HStack {
                Text("Upload Cover Art File: ")
                Text(coverArtFile)
                    .frame(width: 200)
                Button("Choose File") {
                    let dialog = NSOpenPanel();
                    dialog.title = "Choose an image";
                    dialog.showsResizeIndicator = true;
                    dialog.showsHiddenFiles = false;
                    dialog.allowsMultipleSelection = false;
                    dialog.canChooseDirectories = false;
                    dialog.allowedFileTypes = ["png", "jpg", "jpeg"];

                    if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
                        let result = dialog.url // Pathname of the file

                        if (result != nil) {
                            coverArtFile = result!.pathComponents.last!
                        }
                    } else {
                        // User clicked on "Cancel"
                        return
                    }
                }
            }
            .padding()

            HStack {
                Button("Confirm") {
                    if contentName == "" || rawMediaFile == "" || coverArtFile == "" || contentDescription == "" {
                        showAlert = true
                    } else {
                        showProgress.toggle()
                        progressText = "Uploading to server please wait..."
                    }
                }

                Button("Cancel") {
                    dismiss()
                }

                if viewModel.mediaContent != nil {
                    Button("Delete content from server", role: .destructive) {
                        progressText = "Deleting content from server...."
                        showDeleteProgress.toggle()
                        viewModel.deleteContentFromServer()
                    }
                }
            }
            Spacer()
        }
        .onAppear(perform: {
            if let contentDetail = viewModel.mediaContent {
                contentName = contentDetail.contentName!
                contentDescription = contentDetail.contentDescription!
                rawMediaFile = "uploadedMediaAsset.ts"
                coverArtFile = "uploadedImage.HEIC"
                availableRegion = contentDetail.availableRegions!
                genre = contentDetail.genre!
            }
        })
        .padding()
        .frame(width: 500, height: 500)
        .alert("There are some missing field, please fill it up before uploading", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                showAlert.toggle()
            }
        }
        .alert(viewModel.errorMessage ?? "", isPresented: $viewModel.showingAlert) {
            Button("OK", role: .cancel) {
                showDeleteProgress = false
            }
        }
        .onReceive(viewModel.$isSuccess, perform: { isSuccess in
            if isSuccess {
                showDeleteProgress.toggle()
                dismiss()
            }
        })
        .overlay(ProgressView(progressText)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .shadow(radius: 10)
            .opacity(showDeleteProgress ? 1 : 0))
        .overlay(ProgressView(progressText, value: progressAmount, total: 200)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .shadow(radius: 10)
            .opacity(showProgress ? 1 : 0)
            .onReceive(progressCount, perform: { _ in
                if progressAmount < 200 && showProgress {
                    progressAmount += 1
                } else {
                    showProgress = false
                }

                if progressAmount == 200 {
                    dismiss()
                }
            }))
    }
}

