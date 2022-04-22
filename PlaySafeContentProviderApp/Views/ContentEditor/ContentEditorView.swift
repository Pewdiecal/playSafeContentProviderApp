import SwiftUI

struct ContentEditorView: View {
    @State private var contentName = ""
    @State private var rawMediaFile = ""
    @State private var coverArtFile = ""
    @State private var contentDescription = ""
    @State private var availableRegion: CountryCode
    @State private var genre: Genre
    @State private var premiumRes: StreamingResolution
    @State private var standardRes: StreamingResolution
    @State private var basicRes: StreamingResolution
    @State private var budgetRes: StreamingResolution
    @State private var premiumTrialRes: StreamingResolution
    @State private var encryptMedia = true
    @State private var isLoading = false
    @State private var progressAmount = 0.0
    @State private var showProgress = false
    @State private var showAlert = false
    @State private var showCircularProgress = false
    @State private var progressText = ""
    @StateObject private var viewModel: ContentEditorViewModel
    @Environment(\.dismiss) var dismiss
    let progressCount = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    init(mediaContent: MediaContent? = nil, networkRequestService: NetworkRequestService) {
        self._viewModel = StateObject(wrappedValue: ContentEditorViewModel(mediaContent: mediaContent,
                                                                           networkRequestService: networkRequestService))
        self._availableRegion = State(initialValue: mediaContent?.availableRegions ?? .MY)
        self._genre = State(initialValue: mediaContent?.genre ?? .kpop)
        self._premiumRes = State(initialValue: mediaContent?.maxQualityPremium ?? .fullHD_1080)
        self._standardRes = State(initialValue: mediaContent?.maxQualityStandard ?? .HD_720)
        self._basicRes = State(initialValue: mediaContent?.maxQualityBasic ?? .SD_480)
        self._budgetRes = State(initialValue: mediaContent?.maxQualityBudget ?? .SD_144)
        self._premiumTrialRes = State(initialValue: mediaContent?.maxQualityPremiumTrial ?? .fullHD_1080)
    }

    var body: some View {
        VStack {
            Form {
                TextField("Content Name", text: $contentName)
                TextField("Content Description", text: $contentDescription)

                Picker(selection: $availableRegion, label: Text("Select available streaming region")) {
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

                if viewModel.mediaContent == nil {
                    Toggle("Enable encryption", isOn: $encryptMedia)
                        .toggleStyle(.checkbox)
                }
            }

            if viewModel.mediaContent == nil {
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
            }

            HStack {
                Button("Confirm") {
                    if (contentName == "" || rawMediaFile == "" || coverArtFile == "" || contentDescription == "")
                        && viewModel.mediaContent == nil {
                        showAlert = true
                    } else {
                        if var content = viewModel.mediaContent {
                            if contentName != "" || contentDescription != "" {
                                content.contentName = self.contentName
                                content.contentDescription = self.contentDescription
                                content.availableRegions = self.availableRegion
                                content.maxQualityPremium = self.premiumRes
                                content.maxQualityStandard = self.standardRes
                                content.maxQualityBasic = self.basicRes
                                content.maxQualityBudget = self.budgetRes
                                content.maxQualityPremiumTrial = self.premiumTrialRes
                                content.genre = self.genre
                                viewModel.mediaContent = content
                                progressText = "Updating data..."
                                showCircularProgress.toggle()
                                viewModel.editContentMetadata()
                            } else {
                                showAlert = true
                            }
                        } else {
                            progressText = "Uploading to server please wait..."
                            showProgress.toggle()
                        }
                    }
                }

                Button("Cancel") {
                    dismiss()
                }

                if viewModel.mediaContent != nil {
                    Button("Delete content from server", role: .destructive) {
                        progressText = "Deleting content from server...."
                        showCircularProgress.toggle()
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
                showCircularProgress = false
            }
        }
        .onReceive(viewModel.$isSuccess, perform: { isSuccess in
            if isSuccess {
                showCircularProgress.toggle()
                dismiss()
            }
        })
        .overlay(ProgressView(progressText)
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .shadow(radius: 10)
            .opacity(showCircularProgress ? 1 : 0))
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

