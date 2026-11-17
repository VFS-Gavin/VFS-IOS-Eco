import Foundation
import SwiftData

@Model
final class CachedAccount {
    var userId: Int
    var name: String
    var email: String
    var role: String
    var home: String
    var welcomeHub: Bool

    init(account: Account) {
        userId = account.user.id
        name = account.user.name
        email = account.user.email
        role = account.user.role
        home = account.home
        welcomeHub = account.welcomeHub
    }
}

@MainActor
@Observable
final class AppSession {
    var phase: Phase = .signedOut
    var email = ""
    var statusMessage: String?
    var account: Account?
    var welcome: WelcomeHome?
    var isBusy = false

    enum Phase {
        case signedOut
        case checkEmail
        case signedIn
    }

    private let client: APIClient
    private let context: ModelContext

    init(client: APIClient = APIClient(), context: ModelContext) {
        self.client = client
        self.context = context
    }

    func restore() async {
        guard KeychainStore.readToken() != nil else {
            phase = .signedOut
            return
        }
        await loadAccount()
    }

    func sendLink() async {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        isBusy = true
        statusMessage = nil
        do {
            try await client.sendMagicLink(email: trimmed)
            phase = .checkEmail
            statusMessage = "Check your email"
        } catch let error as APIError {
            statusMessage = text(for: error)
        } catch {
            statusMessage = "The sign-in link could not be sent."
        }
        isBusy = false
    }

    func open(url: URL) async {
        guard let token = SignInLink.token(from: url) else { return }
        isBusy = true
        statusMessage = nil
        do {
            account = try await client.exchange(token: token)
            cache(account)
            phase = .signedIn
            await loadWelcomeIfNeeded()
        } catch let error as APIError {
            KeychainStore.clearToken()
            phase = .signedOut
            statusMessage = text(for: error)
        } catch {
            statusMessage = "This sign-in link is invalid or expired."
        }
        isBusy = false
    }

    func devSignIn(role: String) async {
        isBusy = true
        statusMessage = nil
        do {
            account = try await client.devSignIn(role: role)
            cache(account)
            phase = .signedIn
            await loadWelcomeIfNeeded()
        } catch let error as APIError {
            KeychainStore.clearToken()
            phase = .signedOut
            statusMessage = text(for: error)
        } catch {
            statusMessage = "Dev sign-in is not available."
        }
        isBusy = false
    }

    func signOut() {
        KeychainStore.clearToken()
        account = nil
        welcome = nil
        phase = .signedOut
        statusMessage = nil
        for cached in (try? context.fetch(FetchDescriptor<CachedAccount>())) ?? [] {
            context.delete(cached)
        }
    }

    private func loadAccount() async {
        isBusy = true
        do {
            account = try await client.me()
            cache(account)
            phase = .signedIn
            await loadWelcomeIfNeeded()
        } catch {
            KeychainStore.clearToken()
            account = nil
            phase = .signedOut
        }
        isBusy = false
    }

    private func loadWelcomeIfNeeded() async {
        guard account?.welcomeHub == true else {
            welcome = nil
            return
        }
        welcome = try? await client.welcome()
    }

    private func cache(_ account: Account?) {
        guard let account else { return }
        for cached in (try? context.fetch(FetchDescriptor<CachedAccount>())) ?? [] {
            context.delete(cached)
        }
        context.insert(CachedAccount(account: account))
    }

    private func text(for error: APIError) -> String {
        switch error {
        case .message(let message):
            return message
        case .unauthorized:
            return "Sign in again."
        }
    }
}
