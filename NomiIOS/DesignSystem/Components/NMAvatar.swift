import SwiftUI

/// Avatar circular: imagen remota si hay `uri`, si no las iniciales de las dos primeras palabras
/// de `name`.
struct NMAvatar: View {
    let name: String
    var size: CGFloat = 44
    var uri: URL?

    var body: some View {
        Group {
            if let uri {
                AsyncImage(url: uri) { phase in
                    if case .success(let image) = phase {
                        image.resizable().scaledToFill()
                    } else {
                        initialsView
                    }
                }
            } else {
                initialsView
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initialsView: some View {
        ZStack {
            Circle().fill(NMColors.accent)
            Text(initials)
                .font(NMFont.semibold(max(12, size * 0.36)))
                .foregroundColor(NMColors.onAccent)
        }
    }

    private var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first.map(String.init) }
            .joined()
            .uppercased()
    }
}
