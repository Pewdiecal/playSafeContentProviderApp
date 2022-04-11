import SwiftUI

struct MediaCatalogueCellView: View {
    var imageUrl: String
    var title: String
    var genre: String

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: imageUrl)) { image in
                image
                    .resizable()
                    .frame(width: 200, height: 200)
            } placeholder: {
                ProgressView()
            }

            HStack {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, 2)
                Spacer()
            }
            .padding(.leading, 10)

            HStack {
                Text(genre)
                    .font(.subheadline)
                    .foregroundColor(Color.gray)
                    .padding(.top, 0.5)
                Spacer()
            }
            .padding(.leading, 10)
            Spacer()
        }
        .frame(width: 200, height: 280)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}
