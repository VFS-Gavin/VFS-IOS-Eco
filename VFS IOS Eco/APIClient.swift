import Foundation

nonisolated enum APIError: Error, Equatable {
    case message(String)
    case unauthorized
}

nonisolated struct APIClient {
    private static let transport: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = false
        return URLSession(configuration: configuration)
    }()

    var session: URLSession = APIClient.transport
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
        return try account(from: response)
    }

    func devSignIn(role: String) async throws -> Account {
        let response = try await send(
            path: "/api/auth/dev-login",
            method: "POST",
            body: ["role": role],
            authorize: false
        )
        if response.status == 404 {
            throw APIError.message("Dev sign-in is not available.")
        }
        return try account(from: response)
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

    func oday() async throws -> ODayFeed {
        let response = try await send(path: "/api/welcome/o-day", method: "GET", body: nil, authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(ODayFeed.self, from: response.data)
    }

    func survey() async throws -> SurveyForm {
        let response = try await send(path: "/api/welcome/survey", method: "GET", body: nil, authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(SurveyForm.self, from: response.data)
    }

    func submitJSON(path: String, body: [String: Any]) async throws -> String {
        let data = try JSONSerialization.data(withJSONObject: body)
        return try await submit(path: path, body: data, contentType: "application/json")
    }

    func submitMultipart(path: String, fields: [String: String], files: [FormAttachment]) async throws -> String {
        let boundary = "vfs-\(UUID().uuidString)"
        return try await submit(
            path: path,
            body: multipart(fields: fields, files: files, boundary: boundary),
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
    }

    func instructors() async throws -> InstructorDirectory {
        let response = try await send(path: "/api/welcome/instructors", method: "GET", body: nil, authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(InstructorDirectory.self, from: response.data)
    }

    func portfolio(search: String, professional: Bool, page: Int) async throws -> PortfolioFeed {
        var query = [URLQueryItem(name: "page", value: String(page))]
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            query.append(URLQueryItem(name: "search", value: trimmed))
        }
        if professional {
            query.append(URLQueryItem(name: "professional", value: "1"))
        }
        let response = try await send(path: "/api/creative/portfolio", method: "GET", body: nil, authorize: true, query: query)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(PortfolioFeed.self, from: response.data)
    }

    func welcomeAnnouncements() async throws -> WelcomeAnnouncements {
        try await authorized(WelcomeAnnouncements.self, path: "/api/welcome/announcements")
    }

    func creativeAnnouncements() async throws -> CreativeAnnouncements {
        try await authorized(CreativeAnnouncements.self, path: "/api/creative/announcements")
    }

    func project(id: Int) async throws -> ProjectDetail {
        try await authorized(ProjectDetailResponse.self, path: "/api/creative/projects/\(id)").project
    }

    func profile(slug: String) async throws -> CreativeProfileDetail {
        let safe = slug.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? slug
        return try await authorized(ProfileResponse.self, path: "/api/creative/profiles/\(safe)").profile
    }

    func collabs(search: String, page: Int) async throws -> CollabBoard {
        try await authorized(CollabBoard.self, path: "/api/creative/collabs", query: pageQuery(search: search, page: page))
    }

    func collab(id: Int) async throws -> CollabCard {
        try await authorized(CollabDetailResponse.self, path: "/api/creative/collabs/\(id)").collab
    }

    func jobs(search: String, page: Int, partnerPage: Int) async throws -> JobsBoard {
        var query = pageQuery(search: search, page: page)
        query.append(URLQueryItem(name: "partner_page", value: String(partnerPage)))
        return try await authorized(JobsBoard.self, path: "/api/creative/jobs", query: query)
    }

    func job(id: Int) async throws -> JobCard {
        try await authorized(JobDetailResponse.self, path: "/api/creative/jobs/\(id)").job
    }

    private func pageQuery(search: String, page: Int) -> [URLQueryItem] {
        var query = [URLQueryItem(name: "page", value: String(page))]
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            query.append(URLQueryItem(name: "search", value: trimmed))
        }
        return query
    }

    private func authorized<T: Decodable>(_ type: T.Type, path: String, query: [URLQueryItem] = []) async throws -> T {
        let response = try await send(path: path, method: "GET", body: nil, authorize: true, query: query)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(type, from: response.data)
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

    private func send(path: String, method: String, body: [String: String]?, authorize: Bool, query: [URLQueryItem] = []) async throws -> RawResponse {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = path
        if !query.isEmpty {
            components?.queryItems = query
        }
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

    private func submit(path: String, body: Data, contentType: String) async throws -> String {
        let response = try await sendData(path: path, method: "POST", body: body, contentType: contentType, authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        guard let message = message(in: response.data), !message.isEmpty else {
            throw APIError.message("Something went wrong.")
        }
        return message
    }

    private func sendData(path: String, method: String, body: Data?, contentType: String?, authorize: Bool) async throws -> RawResponse {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)
        components?.path = path
        guard let url = components?.url else {
            throw APIError.message("The app is missing its server address.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let contentType {
            request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        request.httpBody = body
        if authorize, let token = token() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await session.data(for: request)
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        return RawResponse(status: status, data: data)
    }

    private func multipart(fields: [String: String], files: [FormAttachment], boundary: String) -> Data {
        var data = Data()
        for (key, value) in fields {
            data.append(Data("--\(boundary)\r\n".utf8))
            data.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            data.append(Data(value.utf8))
            data.append(Data("\r\n".utf8))
        }
        for file in files {
            data.append(Data("--\(boundary)\r\n".utf8))
            data.append(Data("Content-Disposition: form-data; name=\"supporting_documents[]\"; filename=\"\(file.filename)\"\r\n".utf8))
            data.append(Data("Content-Type: \(file.mimeType)\r\n\r\n".utf8))
            data.append(file.data)
            data.append(Data("\r\n".utf8))
        }
        data.append(Data("--\(boundary)--\r\n".utf8))
        return data
    }

    private func account(from response: RawResponse) throws -> Account {
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

    private func throwIfNeeded(_ response: RawResponse, allowSuccess: Bool) throws {
        guard (200..<300).contains(response.status) else {
            throw APIError.message(message(in: response.data) ?? "Something went wrong.")
        }
    }

    private func message(in data: Data) -> String? {
        jsonString(data, key: "message") ?? jsonString(data, key: "error")
    }

    private func jsonString(_ data: Data, key: String) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return object[key] as? String
    }
}
