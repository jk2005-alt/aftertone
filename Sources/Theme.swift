import SwiftUI

enum AuralisTheme {
    static let background = Color(red: 0.018, green: 0.022, blue: 0.035)
    static let cabinet = Color(red: 0.30, green: 0.285, blue: 0.22)
    static let cabinetLight = Color(red: 0.52, green: 0.49, blue: 0.38)
    static let cabinetDark = Color(red: 0.13, green: 0.12, blue: 0.09)
    static let panel = Color(red: 0.07, green: 0.08, blue: 0.12)
    static let ink = Color(red: 0.86, green: 0.88, blue: 0.95)
    static let phosphor = Color(red: 0.80, green: 0.85, blue: 1.0)
    static let phosphorDim = Color(red: 0.44, green: 0.49, blue: 0.65)
    static let amber = Color(red: 0.83, green: 0.30, blue: 0.10)
    static let paper = Color(red: 0.88, green: 0.90, blue: 0.96)
}

extension View {
    func recessedPanel(radius: CGFloat = 10) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: radius)
                    .fill(AuralisTheme.cabinetDark.opacity(0.62))
                    .shadow(color: .white.opacity(0.12), radius: 1, x: 0, y: 1)
                    .shadow(color: .black.opacity(0.85), radius: 5, x: 0, y: 3)
            )
    }
}
