import SwiftUI

/// Pantalla "Próximamente". Hoy no la usa ningún destino.
struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack(spacing: NMSpacing.s2) {
            Text(title).nmStyle(.h2)
            Text("Próximamente").nmStyle(.body)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(NMColors.paper)
        .navigationTitle(title)
    }
}
