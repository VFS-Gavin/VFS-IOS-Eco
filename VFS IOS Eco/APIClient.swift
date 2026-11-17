import Foundation

nonisolated enum APIError: Error, Equatable {
    case message(String)
    case unauthorized
}

nonisolated struct APIClient {
    var session: URLSession = .shared
    var baseURL: URL = APIConfiguration.baseURL
    var token: () -> String? = { KeychainStore.readToken() }

    func sendMagicLink(email: String) async throws {
        let response = try await send(
            path: "/api/auth/magic-link",
            method: "POST",
            body: ["email": email],
            authorize: false
        )
        try throwIfNeeded(response, allowSuccess: true)
    }

    func exchange(token: String) async throws -> Account {
        let response = try await send(
            path: "/api/auth/magic-link/exchange",
            method: "POST",
            body: ["token": token],
            authorize: false
        )
        if response.status == 401 || response.status == 403 {
            throw APIError.message(message(in: response.data) ?? "Sign in on the website.")
        }
        try throwIfNeeded(response, allowSuccess: true)
        let account = try JSONDecoder().decode(Account.self, from: response.data)
        if let token = jsonString(response.data, key: "token") {
            KeychainStore.saveToken(token)
        }
        return account
    }

    func me() async throws -> Account {
        let response = try await send(path: "/api/me", method: "GET", body: nil, authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(Account.self, from: response.data)
    }

    func welcome() async throws -> WelcomeHome {
        let response = try await send(path: "/api/welcome", method: "GET", body: nil, authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(WelcomeHome.self, from: response.data)
    }

    private struct RawResponse {
        var status: Int
        var data: Data
    }

    private func send(path: String, method: String, body: [String: String]?, authorize: Bool) async throws -> RawResponse {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = path
        guard let url = components?.url else {
            throw APIError.message("The app is missing its server address.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        if authorize, let token = token() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        return RawResponse(status: status, data: data)
    }

    private func throwIfNeeded(_ response: RawResponse, allowSuccess: Bool) throws {
        guard (200..<300).contains(response.status) else {
            throw APIError.message(message(in: response.data) ?? "Something went wrong.")
        }
    }

    private func message(in data: Data) -> String? {
        jsonString(data, key: "message")
    }

    private func jsonString(_ data: Data, key: String) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return object[key] as? String
    }
}
