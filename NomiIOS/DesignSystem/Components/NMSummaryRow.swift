import SwiftUI

/// Fila etiqueta-valor de los resúmenes de importes. `bold` se usa para el total.
struct NMSummaryRow: View {
    let label: String
    let value: String
    var bold: Bool = false
    var color: Color?

    var body: some View {
        HStack {
            Text(label)
                .font(NMFont.regular(bold ? 17 : 14))
                .fontWeight(bold ? .heavy : .regular)
                .foregroundColor(color ?? NMColors.inkSoft)
            Spacer()
            Text(value)
                .font(NMFont.semibold(bold ? 17 : 14))
                .foregroundColor(color ?? NMColors.ink)
        }
    }
}
