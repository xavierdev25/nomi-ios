import SwiftUI

/// Línea divisoria de 1 pt.
struct NMDivider: View {
    var body: some View {
        Rectangle()
            .fill(NMColors.line)
            .frame(height: 1)
    }
}
