import SwiftUI

struct AccountMenu: View {
    @Bindable var session: AppSession
    var openWelcome: (() -> Void)?
    var push: ((CreativeRoute) -> Void)?
    @Environment(\.openURL) private var openURL
    @State private var open = false
    @State private var showingCalendar = false
    @State private var events: [CalendarItem] = []
    @State private var calendarMessage: String?
    @State private var calendarLoading = false

    init(session: AppSession, openWelcome: (() -> Void)? = nil, push: ((CreativeRoute) -> Void)? = nil) {
        self.session = session
        self.openWelcome = openWelcome
        self.push = push
    }

    private var showsCalendar: Bool {
        session.account?.showsCreative == true && session.account?.creativeIsIndustry != true
    }

    var body: some View {
        Button {
            showingCalendar = false
            open = true
        } label: {
            HStack(spacing: 4) {
                Text(initial)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 28, height: 28)
                    .background(Color(red: 185 / 255, green: 28 / 255, blue: 28 / 255))
                    .clipShape(Circle())
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(Color.stoneMuted)
                    .rotationEffect(.degrees(open ? 180 : 0))
                    .animation(.easeOut(duration: 0.18), value: open)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("account-menu")
        .accessibilityLabel("Account")
        .background(AccountMenuLayer(open: $open, panel: AnyView(panel)))
    }

    private var panel: some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle().fill(showingCalendar ? Color(red: 219 / 255, green: 39 / 255, blue: 119 / 255) : Color.ecoOrange).frame(height: 3)
            if showingCalendar {
                calendarPanel
            } else {
                accountPanel
            }
        }
        .frame(maxWidth: 320)
        .background(Color.card)
        .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.18), radius: 16, y: 8)
    }

    private var accountPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let user = session.account?.user {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(user.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.stoneInk)
                            .lineLimit(2)
                        Text(user.email)
                            .font(.caption)
                            .foregroundStyle(Color.stoneMuted)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Divider().overlay(Color.stoneLine)
                }
                if showsCalendar {
                    row("Calendar", tint: Color(red: 219 / 255, green: 39 / 255, blue: 119 / 255)) {
                        showingCalendar = true
                        Task { await loadCalendar() }
                    }
                    Divider().overlay(Color.stoneLine).padding(.horizontal, 16)
                }
                if session.account?.showsCreative == true && session.account?.creative == "full" {
                    accountItems
                    Divider().overlay(Color.stoneLine).padding(.horizontal, 16)
                }
                row("Report a Bug / Suggest a Feature", tint: Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255)) {
                    open = false
                    if let url = URL(string: "https://forms.gle/9QXW6pAXUk7WtLjL6") {
                        openURL(url)
                    }
                }
                Divider().overlay(Color.stoneLine).padding(.horizontal, 16)
                row("Sign out", tint: Color(red: 220 / 255, green: 38 / 255, blue: 38 / 255)) {
                    open = false
                    session.signOut()
                }
            }
        }
        .frame(maxHeight: 520)
    }

    private var calendarPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button("Account") { showingCalendar = false }
                    .buttonStyle(.plain)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color(red: 219 / 255, green: 39 / 255, blue: 119 / 255))
                Spacer()
                Text("CALENDAR")
                    .font(.caption.weight(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(Color.stoneMuted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            Divider().overlay(Color.stoneLine)
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if calendarLoading {
                        ProgressView().frame(maxWidth: .infinity).padding(24)
                    } else if let calendarMessage {
                        Text(calendarMessage)
                            .font(.caption)
                            .foregroundStyle(Color.stoneMuted)
                            .padding(16)
                    } else if events.isEmpty {
                        Text("Nothing new on the calendar right now.")
                            .font(.caption)
                            .foregroundStyle(Color.stoneMuted)
                            .frame(maxWidth: .infinity)
                            .padding(24)
                    } else {
                        ForEach(events) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 6) {
                                    if let date = item.dateLabel, !date.isEmpty {
                                        Text(date)
                                            .font(.caption2.weight(.semibold))
                                            .foregroundStyle(Color.stoneMuted)
                                    }
                                    ForEach(item.badges ?? [], id: \.self) { badge in
                                        Text(badge.uppercased())
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundStyle(Color.white)
                                            .padding(.horizontal, 5)
                                            .padding(.vertical, 2)
                                            .background(Color(red: 219 / 255, green: 39 / 255, blue: 119 / 255))
                                    }
                                }
                                Text(item.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.stoneInk)
                                    .fixedSize(horizontal: false, vertical: true)
                                if let when = item.when, !when.isEmpty {
                                    Text(item.location.map { "\(when) · \($0)" } ?? when)
                                        .font(.caption2)
                                        .foregroundStyle(Color.stoneMuted)
                                }
                                if let description = item.description, !description.isEmpty {
                                    Text(description)
                                        .font(.caption)
                                        .foregroundStyle(Color.stoneMuted)
                                        .lineLimit(2)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            Divider().overlay(Color.stoneLine)
                        }
                    }
                }
            }
            .frame(maxHeight: 420)
        }
    }

    @ViewBuilder
    private var accountItems: some View {
        if let slug = session.account?.profile?.slug {
            row("My Profile") { choose(.profile(slug)) }
            row("Manage Portfolio") { choose(.account(.managePortfolio)) }
        } else {
            row("Create Profile") { choose(.setupProfile) }
        }
        row("My Liked") { choose(.account(.liked)) }
        row("Profile Settings") {
            if session.account?.profile == nil {
                choose(.setupProfile)
            } else {
                choose(.account(.profileSettings))
            }
        }
        row("My Showcase") { choose(.account(.showcase)) }
        if session.account?.showsWelcomeHub == true, let openWelcome {
            row("Welcome Hub") {
                open = false
                openWelcome()
            }
        }
        if session.account?.user.role == "alumni" {
            row("Document Requests") { choose(.account(.documentRequests)) }
        }
    }

    private func row(_ title: String, tint: Color = .stoneInk, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(tint)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 11)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func choose(_ route: CreativeRoute) {
        open = false
        push?(route)
    }

    private func loadCalendar() async {
        calendarLoading = true
        calendarMessage = nil
        defer { calendarLoading = false }
        do {
            events = try await APIClient().calendar()
            calendarMessage = nil
        } catch APIError.unauthorized {
            open = false
            session.signOut()
        } catch APIError.message(let text) {
            events = []
            calendarMessage = text
        } catch {
            events = []
            calendarMessage = "The calendar isn't available from the app yet."
        }
    }

    private var initial: String {
        let name = session.account?.user.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return String(name.first ?? "?").uppercased()
    }
}

private struct AccountMenuLayer: UIViewRepresentable {
    @Binding var open: Bool
    var panel: AnyView

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.sync(open: open, panel: panel, anchor: uiView) {
            open = false
        }
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator {
        var dim: UIControl?
        var host: UIHostingController<AnyView>?

        func sync(open: Bool, panel: AnyView, anchor: UIView, close: @escaping () -> Void) {
            guard let window = anchor.window else { return }
            if open {
                show(panel: panel, window: window, close: close)
            } else {
                hide()
            }
        }

        private func show(panel: AnyView, window: UIWindow, close: @escaping () -> Void) {
            let width = min(320, window.bounds.width - 24)
            let top = window.safeAreaInsets.top + 48
            let limit = window.bounds.height - top - 16
            if dim == nil {
                let shade = UIControl(frame: window.bounds)
                shade.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                shade.backgroundColor = UIColor.black.withAlphaComponent(0.28)
                shade.alpha = 0
                shade.addAction(UIAction { _ in close() }, for: .touchUpInside)
                window.addSubview(shade)
                dim = shade

                let controller = UIHostingController(rootView: panel)
                controller.safeAreaRegions = []
                controller.view.backgroundColor = .clear
                controller.view.alpha = 0
                let height = min(controller.sizeThatFits(in: CGSize(width: width, height: limit)).height, limit)
                controller.view.frame = CGRect(x: window.bounds.width - width - 12, y: top, width: width, height: height)
                controller.view.transform = CGAffineTransform(translationX: 0, y: -6)
                window.addSubview(controller.view)
                host = controller
                UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
                    shade.alpha = 1
                    controller.view.alpha = 1
                    controller.view.transform = .identity
                }
            } else if let host {
                host.rootView = panel
                let height = min(host.sizeThatFits(in: CGSize(width: width, height: limit)).height, limit)
                host.view.frame = CGRect(x: window.bounds.width - width - 12, y: top, width: width, height: height)
            }
        }

        private func hide() {
            guard dim != nil || host != nil else { return }
            let shade = dim
            let view = host?.view
            dim = nil
            host = nil
            UIView.animate(withDuration: 0.14, delay: 0, options: .curveEaseIn, animations: {
                shade?.alpha = 0
                view?.alpha = 0
                view?.transform = CGAffineTransform(translationX: 0, y: -6)
            }, completion: { _ in
                view?.removeFromSuperview()
                shade?.removeFromSuperview()
            })
        }
    }
}
