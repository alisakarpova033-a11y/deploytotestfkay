import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var hangerScale: CGFloat = 0.5
    @State private var hangerOpacity: Double = 0
    @State private var textOpacity: Double = 0

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(spacing: 40) {
                Spacer()

                VStack(spacing: 24) {
                    Image(systemName: "hanger")
                        .font(.system(size: 80, weight: .ultraLight))
                        .foregroundStyle(.indigo)
                        .scaleEffect(hangerScale)
                        .opacity(hangerOpacity)

                    VStack(spacing: 8) {
                        Text("Your Digital Closet")
                            .font(.system(size: 28, weight: .ultraLight))
                            .tracking(2)

                        Text("Organize. Style. Wear.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .tracking(4)
                            .textCase(.uppercase)
                    }
                    .opacity(textOpacity)
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        hasCompletedOnboarding = true
                    }
                } label: {
                    Text("Open Closet")
                        .font(.subheadline.weight(.medium))
                        .tracking(1)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.indigo)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(PressableButtonStyle())
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                hangerScale = 1.0
                hangerOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                textOpacity = 1.0
            }
        }
    }
}

#Preview {
    OnboardingView()
}
