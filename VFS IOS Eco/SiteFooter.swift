import SwiftUI
import UIKit

struct SiteFooter: View {
    @Bindable var session: AppSession
    var push: ((CreativeRoute) -> Void)?
    @Environment(\.colorScheme) private var colorScheme
    @State private var showTerms = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 10) {
                if let logo = UIImage(named: "vfs-logo") {
                    logoMark(logo)
                }
                Text("© \(Calendar.current.component(.year, from: Date())) Vancouver Film School")
                    .font(.footnote)
                    .foregroundStyle(Color.stoneMuted)
            }
            Text("Created by Gavin Etmanski")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.stoneLabel)
            HStack(spacing: 16) {
                if session.account?.user.role == "alumni" {
                    Button("Document Requests") {
                        push?(.account(.documentRequests))
                    }
                    .buttonStyle(.plain)
                    .font(.caption.weight(.bold))
                    .textCase(.uppercase)
                    .tracking(1)
                    .foregroundStyle(Color.stoneInk)
                }
                Button("Terms & Privacy") {
                    showTerms = true
                }
                .buttonStyle(.plain)
                .font(.caption.weight(.bold))
                .textCase(.uppercase)
                .tracking(1)
                .foregroundStyle(Color.stoneInk)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.stone)
        .overlay(alignment: .top) { Rectangle().fill(Color.stoneLine).frame(height: 1) }
        .sheet(isPresented: $showTerms) {
            NavigationStack {
                AccountAreaView(area: .terms)
                    .toolbar {
                        Button("Done") { showTerms = false }
                    }
            }
        }
    }

    @ViewBuilder
    private func logoMark(_ logo: UIImage) -> some View {
        let image = Image(uiImage: logo)
            .resizable()
            .scaledToFit()
            .frame(height: 18)
        if colorScheme == .light {
            image.colorInvert()
        } else {
            image
        }
    }
}
