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

    func acceptTerms() async throws -> Account {
        let body = try JSONSerialization.data(withJSONObject: ["scrolled": true, "agreed": true])
        let response = try await sendData(
            path: "/api/terms/accept",
            method: "POST",
            body: body,
            contentType: "application/json",
            authorize: true
        )
        if response.status == 404 {
            throw APIError.message("Terms can't be saved from the app yet.")
        }
        return try account(from: response)
    }

    func dismissTerms() async throws -> TermsDismissResult {
        let response = try await sendData(
            path: "/api/terms/dismiss",
            method: "POST",
            body: Data("{}".utf8),
            contentType: "application/json",
            authorize: true
        )
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        if response.status == 404 {
            throw APIError.message("Terms can't be saved from the app yet.")
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(TermsDismissResult.self, from: response.data)
    }

    func termsDocument() async throws -> TermsDocument {
        let response = try await send(path: "/api/terms", method: "GET", body: nil, authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(TermsDocument.self, from: response.data)
    }

    func saveProfile(_ draft: ProfileDraft) async throws -> Account {
        let response = try await sendData(
            path: "/api/creative/profile",
            method: "POST",
            body: try JSONSerialization.data(withJSONObject: draft.payload()),
            contentType: "application/json",
            authorize: true
        )
        if response.status == 404 {
            throw APIError.message("Profile setup isn't available from the app yet.")
        }
        return try account(from: response)
    }

    func logout() async {
        _ = try? await send(path: "/api/auth/logout", method: "POST", body: [:], authorize: true)
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

    func submitJSON(path: String, method: String = "POST", body: [String: Any]) async throws -> String {
        let data = try JSONSerialization.data(withJSONObject: body)
        return try await submit(path: path, method: method, body: data, contentType: "application/json")
    }

    func saveProfile(_ body: [String: Any]) async throws -> String {
        try await submitJSON(path: "/api/creative/profile", method: "PUT", body: body)
    }

    func createProject(_ body: [String: Any], cover: Data? = nil, coverName: String = "cover.jpg", media: [Data] = []) async throws -> String {
        try await sendProject(path: "/api/creative/projects", method: "POST", body: body, cover: cover, coverName: coverName, media: media)
    }

    func projectEditor(id: Int) async throws -> ProjectEditor {
        try await catalog(ProjectEditorResponse.self, path: "/api/creative/projects/\(id)/edit", missing: "This project can't be edited from the app yet.").project
    }

    func updateProject(id: Int, body: [String: Any], cover: Data? = nil, media: [Data] = []) async throws -> String {
        let method = (cover != nil || !media.isEmpty) ? "POST" : "PUT"
        return try await sendProject(path: "/api/creative/projects/\(id)", method: method, body: body, cover: cover, coverName: "cover.jpg", media: media)
    }

    func updateProfileSlug(_ slug: String) async throws -> String {
        try await submitJSON(path: "/api/creative/profile/slug", method: "PUT", body: ["slug": slug])
    }

    func uploadProfileFile(path: String, field: String, filename: String, mime: String, data: Data) async throws -> String {
        let file = FormAttachment(filename: filename, mimeType: mime, data: data)
        return try await submitMultipart(path: path, fields: [:], files: [file], fileField: field)
    }

    func deleteProfileFile(path: String) async throws -> String {
        try await submitJSON(path: path, method: "DELETE", body: [:])
    }

    func likeProject(id: Int) async throws -> LikeResult {
        try await postJSON(LikeResult.self, path: "/api/creative/projects/\(id)/like")
    }

    func commentOnProject(id: Int, body: String) async throws -> ProjectComment {
        try await postJSON(CommentEnvelope.self, path: "/api/creative/projects/\(id)/comments", body: ["body": body]).comment
    }

    func deleteComment(id: Int) async throws -> String {
        try await submitJSON(path: "/api/creative/comments/\(id)", method: "DELETE", body: [:])
    }

    func applyToJob(id: Int, coverLetter: String) async throws -> String {
        var body: [String: Any] = [:]
        let letter = coverLetter.trimmingCharacters(in: .whitespacesAndNewlines)
        if !letter.isEmpty { body["cover_letter"] = letter }
        return try await submitJSON(path: "/api/creative/jobs/\(id)/apply", body: body)
    }

    func bookFacility(id: Int, start: Date, purpose: String, name: String, attendees: Int, guests: Bool) async throws -> String {
        try await submitJSON(path: "/api/creative/facilities/\(id)/book", body: [
            "start_time": ISO8601DateFormatter().string(from: start),
            "purpose": purpose,
            "booker_name": name,
            "attendee_count": attendees,
            "non_vfs_attendees": guests,
        ])
    }

    func ambassadors(search: String) async throws -> [AmbassadorCard] {
        var query: [URLQueryItem] = []
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.count >= 2 {
            query.append(URLQueryItem(name: "search", value: trimmed))
        }
        return try await authorized(AmbassadorDirectory.self, path: "/api/welcome/ambassadors", query: query).ambassadors
    }

    func ambassador(id: Int) async throws -> AmbassadorCard {
        try await authorized(AmbassadorPage.self, path: "/api/welcome/ambassadors/\(id)").ambassador
    }

    func startConversation(ambassadorID: Int) async throws -> Int {
        try await postJSON(ConversationStart.self, path: "/api/welcome/conversations/start", body: ["ambassador_id": ambassadorID]).conversationID
    }

    func conversations() async throws -> [ChatThread] {
        try await authorized(ChatIndex.self, path: "/api/welcome/conversations").conversations
    }

    func conversationMessages(id: Int) async throws -> [ChatLine] {
        try await authorized(ChatIndex.self, path: "/api/welcome/conversations/\(id)/messages").messages
    }

    func sendChat(id: Int, body: String) async throws -> ChatLine {
        try await postJSON(ChatSend.self, path: "/api/welcome/conversations/\(id)/messages", body: ["body": body]).message
    }

    func tasteBoard() async throws -> OwnTaste {
        try await authorized(OwnTaste.self, path: "/api/creative/taste")
    }

    func searchTaste(type: String, query: String) async throws -> [TasteHit] {
        let safe = type.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? type
        return try await authorized(TasteSearchPage.self, path: "/api/creative/taste/search/\(safe)", query: [URLQueryItem(name: "q", value: query)]).items
    }

    func addTasteItem(_ item: TasteHit) async throws {
        _ = try await postJSON(OkFlag.self, path: "/api/creative/taste/items", body: item.favoriteBody(highlighted: false, note: nil))
    }

    func saveHighlights(_ items: [TasteItem]) async throws {
        let ids = items.filter(\.highlighted).map(\.id)
        var notes: [String: String] = [:]
        for item in items where item.highlighted {
            let note = item.note?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if !note.isEmpty { notes[String(item.id)] = note }
        }
        _ = try await postJSON(OkFlag.self, path: "/api/creative/taste/highlights", method: "PUT", body: [
            "highlighted_ids": ids,
            "notes": notes,
        ])
    }

    func markSeen(_ item: TasteHit, seen: Bool) async throws {
        var body = item.favoriteBody(highlighted: false, note: nil)
        body["seen"] = seen
        _ = try await postJSON(OkFlag.self, path: "/api/creative/taste/seen", body: body)
    }

    func discoveryTitle(type: String, externalID: String) async throws -> DiscoveryTitlePage {
        let safeType = type.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? type
        let safeID = externalID.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? externalID
        return try await authorized(DiscoveryTitlePage.self, path: "/api/creative/discovery/\(safeType)/\(safeID)")
    }

    func saveReview(type: String, externalID: String, title: String, poster: String?, year: String?, rating: Double, review: String) async throws -> String {
        var body: [String: Any] = [
            "media_type": type,
            "external_id": externalID,
            "title": title,
            "rating": rating,
        ]
        if let poster, !poster.isEmpty { body["poster_url"] = poster }
        if let year, let number = Int(year) { body["release_year"] = number }
        let text = review.trimmingCharacters(in: .whitespacesAndNewlines)
        if !text.isEmpty { body["review"] = text }
        return try await submitJSON(path: "/api/creative/discovery/reviews", body: body)
    }

    func deleteReview(id: Int) async throws -> String {
        try await submitJSON(path: "/api/creative/discovery/reviews/\(id)", method: "DELETE", body: [:])
    }

    func saveChallengeResponse(id: Int, body: String) async throws {
        _ = try await postJSON(OkFlag.self, path: "/api/creative/discovery/challenges/\(id)/response", body: ["body": body])
    }

    func createCollab(_ body: [String: Any]) async throws -> String {
        try await submitJSON(path: "/api/creative/collabs", body: body)
    }

    func sendCollabInquiry(id: Int, body: [String: Any]) async throws {
        _ = try await postJSON(OkFlag.self, path: "/api/creative/collabs/\(id)/inquiries", body: body)
    }

    func applyForGrant(_ body: [String: Any]) async throws -> String {
        try await submitJSON(path: "/api/creative/funding/apply", body: body)
    }

    func savePitches(_ pitches: [[String: Any]]) async throws {
        _ = try await postJSON(OkFlag.self, path: "/api/creative/profile/pitches", body: ["pitches": pitches])
    }

    private func sendProject(path: String, method: String, body: [String: Any], cover: Data?, coverName: String, media: [Data]) async throws -> String {
        guard cover != nil || !media.isEmpty else {
            return try await submitJSON(path: path, method: method, body: body)
        }
        let boundary = "vfs-\(UUID().uuidString)"
        return try await submit(
            path: path,
            method: method,
            body: projectForm(body, cover: cover, coverName: coverName, media: media, boundary: boundary),
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
    }

    func toggleProjectPublish(id: Int) async throws -> String {
        try await submitJSON(path: "/api/creative/projects/\(id)/toggle-publish", body: [:])
    }

    func deleteProject(id: Int) async throws -> String {
        try await submitJSON(path: "/api/creative/projects/\(id)", method: "DELETE", body: [:])
    }

    func toggleCollabHidden(id: Int) async throws -> Bool {
        let data = try JSONSerialization.data(withJSONObject: [:])
        let response = try await sendData(path: "/api/creative/collaborations/\(id)/toggle-hide", method: "POST", body: data, contentType: "application/json", authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        guard let object = try? JSONSerialization.jsonObject(with: response.data) as? [String: Any],
              let visible = object["visible"] as? Bool else {
            throw APIError.message("Something went wrong.")
        }
        return !visible
    }

    func submitMultipart(path: String, fields: [String: String], files: [FormAttachment], fileField: String = "supporting_documents[]") async throws -> String {
        let boundary = "vfs-\(UUID().uuidString)"
        return try await submit(
            path: path,
            body: multipart(fields: fields, files: files, fileField: fileField, boundary: boundary),
            contentType: "multipart/form-data; boundary=\(boundary)"
        )
    }

    func housingProperties(bedrooms: String = "", furnished: String = "", pets: String = "", maxRent: String = "") async throws -> [HousingListing] {
        var query: [URLQueryItem] = []
        if !bedrooms.isEmpty { query.append(URLQueryItem(name: "bedrooms", value: bedrooms)) }
        if !furnished.isEmpty { query.append(URLQueryItem(name: "furnished", value: furnished)) }
        if !pets.isEmpty { query.append(URLQueryItem(name: "pets", value: pets)) }
        if !maxRent.isEmpty { query.append(URLQueryItem(name: "max_rent", value: maxRent)) }
        return try await authorized(HousingPropertiesPage.self, path: "/api/welcome/housing/properties", query: query).listings
    }

    func housingStudent(id: Int) async throws -> RoommateProfile {
        try await authorized(RoommatePage.self, path: "/api/welcome/housing/students/\(id)").student
    }

    func removeTasteItem(id: Int) async throws {
        _ = try await postJSON(OkFlag.self, path: "/api/creative/taste/items/\(id)", method: "DELETE")
    }

    func housingProperty(id: Int) async throws -> HousingListing {
        try await catalog(HousingPropertyPage.self, path: "/api/welcome/housing/properties/\(id)", missing: "This listing isn't available from the app yet.").listing
    }

    func housingStudents() async throws -> [HousingSeeker] {
        try await catalog(HousingStudentsPage.self, path: "/api/welcome/housing/students", missing: "Roommate profiles aren't available from the app yet.").students
    }

    func submitHousingSeeking(_ body: [String: Any]) async throws -> String {
        try await submitJSON(path: "/api/welcome/housing/student-seeking", body: body)
    }

    func submitLandlordListing(_ fields: [String: String], photos: [Data]) async throws -> String {
        let files = photos.enumerated().map {
            FormAttachment(filename: "photo-\($0.offset).jpg", mimeType: "image/jpeg", data: $0.element)
        }
        return try await submitMultipart(path: "/api/welcome/housing/landlord-application", fields: fields, files: files, fileField: "photos[]")
    }

    func registerForHousing(propertyID: Int, body: [String: Any]) async throws -> String {
        try await submitJSON(path: "/api/welcome/housing/properties/\(propertyID)/register", body: body)
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

    func collabs(search: String, page: Int, type: String = "", role: String = "", paidOnly: Bool = false, roleType: String = "", board: String = "active") async throws -> CollabBoard {
        var query = pageQuery(search: search, page: page)
        if !type.isEmpty { query.append(URLQueryItem(name: "type", value: type)) }
        if !role.isEmpty { query.append(URLQueryItem(name: "role", value: role)) }
        if paidOnly { query.append(URLQueryItem(name: "paid_only", value: "1")) }
        if !roleType.isEmpty { query.append(URLQueryItem(name: "role_type", value: roleType)) }
        if board == "archived" { query.append(URLQueryItem(name: "board", value: "archived")) }
        return try await authorized(CollabBoard.self, path: "/api/creative/collabs", query: query)
    }

    func managePortfolio() async throws -> ManageBoard {
        try await catalog(ManageBoard.self, path: "/api/creative/manage", missing: "Manage Portfolio isn't available from the app yet.")
    }

    func ownProfile() async throws -> OwnSettings {
        try await catalog(OwnSettings.self, path: "/api/creative/profile", missing: "Profile Settings isn't available from the app yet.")
    }

    func funding() async throws -> FundingBoard {
        try await catalog(FundingBoard.self, path: "/api/creative/funding", missing: "The funding list isn't available from the app yet.")
    }

    func workshopCategory(_ slug: String) async throws -> WorkshopCategoryPage {
        let safe = slug.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? slug
        return try await catalog(WorkshopCategoryPage.self, path: "/api/creative/workshops/\(safe)", missing: "This workshop list isn't available from the app yet.")
    }

    func discoveryList(path: String) async throws -> DiscoveryListResponse {
        try await catalog(DiscoveryListResponse.self, path: path, missing: "This Creative Engine list isn't available from the app yet.")
    }

    func calendar() async throws -> [CalendarItem] {
        let response = try await send(path: "/api/creative/calendar", method: "GET", body: nil, authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        if response.status == 404 {
            throw APIError.message("The calendar isn't available from the app yet.")
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(CalendarFeed.self, from: response.data).calendar
    }

    func collab(id: Int) async throws -> CollabCard {
        try await authorized(CollabDetailResponse.self, path: "/api/creative/collabs/\(id)").collab
    }

    func jobs(search: String, page: Int, partnerPage: Int, type: String = "", remote: Bool = false, level: String = "", sort: String = "", program: String = "", company: String = "", city: String = "") async throws -> JobsBoard {
        var query = pageQuery(search: search, page: page)
        query.append(URLQueryItem(name: "partner_page", value: String(partnerPage)))
        if !type.isEmpty { query.append(URLQueryItem(name: "type", value: type)) }
        if remote { query.append(URLQueryItem(name: "remote", value: "1")) }
        if !level.isEmpty { query.append(URLQueryItem(name: "level", value: level)) }
        if !sort.isEmpty { query.append(URLQueryItem(name: "sort", value: sort)) }
        if !program.isEmpty { query.append(URLQueryItem(name: "program", value: program)) }
        if !company.isEmpty { query.append(URLQueryItem(name: "company", value: company)) }
        if !city.isEmpty { query.append(URLQueryItem(name: "city", value: city)) }
        return try await authorized(JobsBoard.self, path: "/api/creative/jobs", query: query)
    }

    func discoverySearch(query: String, type: String) async throws -> [DiscoveryHit] {
        var items = [URLQueryItem(name: "q", value: query)]
        if !type.isEmpty { items.append(URLQueryItem(name: "type", value: type)) }
        let response = try await send(path: "/api/creative/discovery/search", method: "GET", body: nil, authorize: true, query: items)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        if response.status == 404 {
            throw APIError.message("Search isn't available from the app yet.")
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(DiscoverySearchResponse.self, from: response.data).results
    }

    func facilities() async throws -> [FacilityItem] {
        let response = try await send(path: "/api/creative/facilities", method: "GET", body: nil, authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        if response.status == 404 {
            throw APIError.message("The booking list isn't available from the app yet.")
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(FacilitiesResponse.self, from: response.data).facilities
    }

    func job(id: Int) async throws -> JobCard {
        try await authorized(JobDetailResponse.self, path: "/api/creative/jobs/\(id)").job
    }

    private func catalog<T: Decodable>(_ type: T.Type, path: String, missing: String) async throws -> T {
        let response = try await send(path: path, method: "GET", body: nil, authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        if response.status == 404 {
            throw APIError.message(missing)
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(T.self, from: response.data)
    }

    private func pageQuery(search: String, page: Int) -> [URLQueryItem] {
        var query = [URLQueryItem(name: "page", value: String(page))]
        let trimmed = search.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            query.append(URLQueryItem(name: "search", value: trimmed))
        }
        return query
    }

    private func postJSON<T: Decodable>(_ type: T.Type, path: String, method: String = "POST", body: [String: Any] = [:]) async throws -> T {
        let data = try JSONSerialization.data(withJSONObject: body)
        let response = try await sendData(path: path, method: method, body: data, contentType: "application/json", authorize: true)
        if response.status == 401 {
            KeychainStore.clearToken()
            throw APIError.unauthorized
        }
        try throwIfNeeded(response, allowSuccess: true)
        return try JSONDecoder().decode(type, from: response.data)
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

    private func submit(path: String, method: String = "POST", body: Data, contentType: String) async throws -> String {
        let response = try await sendData(path: path, method: method, body: body, contentType: contentType, authorize: true)
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

    private func projectForm(_ body: [String: Any], cover: Data?, coverName: String, media: [Data], boundary: String) -> Data {
        var data = Data()
        func part(_ name: String, _ value: String) {
            data.append(Data("--\(boundary)\r\n".utf8))
            data.append(Data("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".utf8))
            data.append(Data(value.utf8))
            data.append(Data("\r\n".utf8))
        }
        for (key, value) in body {
            if let flag = value as? Bool {
                part(key, flag ? "1" : "0")
            } else if let text = value as? String {
                part(key, text)
            } else if let list = value as? [String] {
                for item in list { part("\(key)[]", item) }
            } else if let numbers = value as? [Int] {
                for number in numbers { part("\(key)[]", String(number)) }
            } else if let rows = value as? [[String: String]] {
                for (index, row) in rows.enumerated() {
                    for (field, text) in row { part("\(key)[\(index)][\(field)]", text) }
                }
            }
        }
        if let cover {
            data.append(Data("--\(boundary)\r\n".utf8))
            data.append(Data("Content-Disposition: form-data; name=\"cover_image\"; filename=\"\(coverName)\"\r\n".utf8))
            data.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
            data.append(cover)
            data.append(Data("\r\n".utf8))
        }
        for (index, file) in media.enumerated() {
            data.append(Data("--\(boundary)\r\n".utf8))
            data.append(Data("Content-Disposition: form-data; name=\"media_files[]\"; filename=\"media-\(index).jpg\"\r\n".utf8))
            data.append(Data("Content-Type: image/jpeg\r\n\r\n".utf8))
            data.append(file)
            data.append(Data("\r\n".utf8))
        }
        data.append(Data("--\(boundary)--\r\n".utf8))
        return data
    }

    private func multipart(fields: [String: String], files: [FormAttachment], fileField: String = "supporting_documents[]", boundary: String) -> Data {
        var data = Data()
        for (key, value) in fields {
            data.append(Data("--\(boundary)\r\n".utf8))
            data.append(Data("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".utf8))
            data.append(Data(value.utf8))
            data.append(Data("\r\n".utf8))
        }
        for file in files {
            data.append(Data("--\(boundary)\r\n".utf8))
            data.append(Data("Content-Disposition: form-data; name=\"\(fileField)\"; filename=\"\(file.filename)\"\r\n".utf8))
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
        if let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let errors = object["errors"] as? [String: Any] {
            for value in errors.values {
                if let list = value as? [String], let first = list.first, !first.isEmpty { return first }
                if let text = value as? String, !text.isEmpty { return text }
            }
        }
        return jsonString(data, key: "message") ?? jsonString(data, key: "error")
    }

    private func jsonString(_ data: Data, key: String) -> String? {
        guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return object[key] as? String
    }
}
