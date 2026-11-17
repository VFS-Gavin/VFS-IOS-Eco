import SwiftUI

struct TermsGateView: View {
    @Bindable var session: AppSession
    @State private var document = TermsCatalog.document
    @State private var reachedBottom = false
    @State private var agreed = false

    private var mandatory: Bool { session.account?.terms?.hardBlocked == true }
    private var dismissesLeft: Int { session.account?.terms?.dismissesLeft ?? 0 }

    var body: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(mandatory ? "One Last Step" : "Updated Terms and Conditions")
                        .font(.system(size: mandatory ? 32 : 24, weight: .black))
                        .foregroundStyle(Color.stoneInk)
                        .multilineTextAlignment(.center)
                    Text(mandatory
                        ? "Please review and accept the Terms of Use to continue."
                        : "Please review and accept our updated Terms and Conditions to continue using the platform.")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 16)

                termsScroll
                    .frame(maxHeight: .infinity)

                VStack(spacing: 12) {
                    if !reachedBottom {
                        Text("Scroll to read all terms before accepting")
                            .font(.footnote)
                            .foregroundStyle(Color.stoneMuted)
                    } else {
                        Toggle(isOn: $agreed) {
                            Text("I have read and agree to the Terms and Conditions")
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneInk)
                        }
                        .tint(Color.welcomeRed)
                    }

                    if let message = session.statusMessage, !message.isEmpty {
                        Text(message)
                            .font(.footnote)
                            .foregroundStyle(Color.welcomeRed)
                            .multilineTextAlignment(.center)
                    }

                    Button(actionTitle) {
                        Task { await session.acceptTerms() }
                    }
                    .buttonStyle(TermsAcceptButtonStyle(mandatory: mandatory))
                    .disabled(!reachedBottom || !agreed || session.isBusy)
                    .opacity((!reachedBottom || !agreed || session.isBusy) ? 0.4 : 1)
                    .accessibilityIdentifier("terms-accept")

                    if mandatory {
                        Button("Sign out instead") { session.signOut() }
                            .font(.subheadline)
                            .foregroundStyle(Color.stoneMuted)
                    } else {
                        Button {
                            Task { await session.dismissTerms() }
                        } label: {
                            Text("Maybe Later (\(dismissesLeft) remaining)")
                                .font(.subheadline)
                                .foregroundStyle(Color.stoneMuted)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.stoneLine, lineWidth: 1))
                        }
                        .buttonStyle(.plain)
                        .disabled(session.isBusy)
                        .accessibilityIdentifier("terms-later")
                    }
                }
                .padding(20)
            }
            .background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Color.stoneLine, lineWidth: 1))
            .padding(16)
        }
        .accessibilityIdentifier("terms-gate")
        .task { await loadDocument() }
    }

    private var actionTitle: String {
        if session.isBusy { return "Continuing..." }
        return reachedBottom ? (mandatory ? "Agree & Continue" : "I Accept") : "Read the full terms to continue"
    }

    private var termsScroll: some View {
        GeometryReader { viewport in
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(document.intro)
                        .foregroundStyle(Color.stoneInk)
                    ForEach(document.sections) { section in
                        Text(section.title)
                            .font(.headline)
                            .foregroundStyle(Color.stoneInk)
                        ForEach(section.paragraphs, id: \.self) { paragraph in
                            Text(paragraph)
                        }
                    }
                }
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
                .padding(20)
                .background {
                    GeometryReader { content in
                        Color.clear
                            .onAppear { markIfShort(content: content.size.height, viewport: viewport.size.height) }
                            .onChange(of: content.frame(in: .named("termsScroll")).maxY) { _, maxY in
                                if maxY <= viewport.size.height + 24 {
                                    reachedBottom = true
                                }
                            }
                    }
                }
            }
            .coordinateSpace(name: "termsScroll")
        }
    }

    private func markIfShort(content: CGFloat, viewport: CGFloat) {
        if content <= viewport + 24 {
            reachedBottom = true
        }
    }

    private func loadDocument() async {
        if let remote = try? await APIClient().termsDocument() {
            document = remote
            reachedBottom = false
            agreed = false
        }
    }
}

private struct TermsAcceptButtonStyle: ButtonStyle {
    var mandatory: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.bold))
            .foregroundStyle(mandatory ? Color.white : Color.stone)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(mandatory ? Color.welcomeRed : Color.stoneInk)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
