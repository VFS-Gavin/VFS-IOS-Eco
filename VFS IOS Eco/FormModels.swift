import Foundation

nonisolated struct SurveyForm: Codable, Equatable {
    var alreadySubmitted: Bool
    var questions: [SurveyQuestion]

    enum CodingKeys: String, CodingKey {
        case alreadySubmitted = "already_submitted"
        case questions
    }
}

nonisolated struct SurveyQuestion: Codable, Equatable, Identifiable {
    var id: String
    var prompt: String
    var hint: String?
    var kind: String
    var min: Int?
    var max: Int?
    var required: Bool
    var options: [SurveyOption]?

    enum CodingKeys: String, CodingKey {
        case id, prompt, hint, kind, min, max, required, options
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        prompt = try container.decode(String.self, forKey: .prompt)
        hint = try container.decodeIfPresent(String.self, forKey: .hint)
        kind = try container.decode(String.self, forKey: .kind)
        min = try container.decodeIfPresent(Int.self, forKey: .min)
        max = try container.decodeIfPresent(Int.self, forKey: .max)
        required = try container.decodeIfPresent(Bool.self, forKey: .required) ?? false
        options = try container.decodeIfPresent([SurveyOption].self, forKey: .options)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(prompt, forKey: .prompt)
        try container.encodeIfPresent(hint, forKey: .hint)
        try container.encode(kind, forKey: .kind)
        try container.encodeIfPresent(min, forKey: .min)
        try container.encodeIfPresent(max, forKey: .max)
        try container.encode(required, forKey: .required)
        try container.encodeIfPresent(options, forKey: .options)
    }
}

nonisolated struct SurveyOption: Codable, Equatable, Identifiable {
    var key: String
    var label: String
    var detail: String?

    var id: String { key }

    enum CodingKeys: String, CodingKey {
        case key, label
        case detail = "description"
    }
}

nonisolated struct FormAttachment: Equatable {
    var filename: String
    var mimeType: String
    var data: Data
}

nonisolated struct QuestionnaireDraft: Equatable {
    var selections: [String: [String]] = [:]
    var text: [String: String] = [:]
    var single: [String: String] = [:]
    var scales: [String: Int] = [:]
    var ranks: [String: String] = [:]
    var agreements: [String: Int] = [:]

    func payload() -> [String: Any] {
        var body: [String: Any] = [:]
        for (key, values) in selections where !values.isEmpty {
            body[key] = values
        }
        for (key, value) in text {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.isEmpty {
                body[key] = trimmed
            }
        }
        for (key, value) in single where !value.isEmpty {
            body[key] = value
        }
        for (key, value) in scales {
            body[key] = value
        }
        if let first = ranks["1"], !first.isEmpty,
           let second = ranks["2"], !second.isEmpty,
           let third = ranks["3"], !third.isEmpty {
            body["q6_success_factors"] = ["1": first, "2": second, "3": third]
        }
        if !agreements.isEmpty {
            body["q17_agreement_rankings"] = agreements
        }
        return body
    }
}

nonisolated enum FormDrafts {
    static let provinces = [
        "Alberta", "British Columbia", "Manitoba", "New Brunswick",
        "Newfoundland and Labrador", "Northwest Territories", "Nova Scotia",
        "Nunavut", "Ontario", "Prince Edward Island", "Quebec", "Saskatchewan", "Yukon",
    ]

    static let relationships = [
        "Parent", "Guardian", "Spouse", "Sibling", "Other Family", "Friend", "Other",
    ]

    static func parentConsent(
        person1Name: String,
        person1Relationship: String,
        person1Phone: String,
        person1Email: String,
        person2Name: String,
        person2Relationship: String,
        person2Phone: String,
        person2Email: String,
        studentName: String,
        studentSignature: String,
        date: String,
        consent: Bool
    ) -> [String: Any] {
        var body: [String: Any] = [
            "student_name": studentName,
            "student_signature": studentSignature,
            "date": date,
            "consent_acknowledged": consent,
        ]
        fill(&body, "person1_name", person1Name)
        fill(&body, "person1_relationship", person1Relationship)
        fill(&body, "person1_phone", person1Phone)
        fill(&body, "person1_email", person1Email)
        fill(&body, "person2_name", person2Name)
        fill(&body, "person2_relationship", person2Relationship)
        fill(&body, "person2_phone", person2Phone)
        fill(&body, "person2_email", person2Email)
        return body
    }

    static func contactUpdate(
        fullName: String,
        preferredName: String,
        studentId: String,
        classId: String,
        dateOfBirth: String,
        newEmail: String,
        newPhone: String,
        newMobile: String,
        street: String,
        city: String,
        province: String,
        postalCode: String,
        country: String,
        emergencyName: String,
        emergencyRelationship: String,
        emergencyPhone: String,
        emergencyEmail: String
    ) -> [String: Any] {
        var body: [String: Any] = [
            "full_name": fullName,
            "date_of_birth": dateOfBirth,
        ]
        fill(&body, "preferred_name", preferredName)
        fill(&body, "student_id", studentId)
        fill(&body, "class_id", classId)
        fill(&body, "new_email", newEmail)
        fill(&body, "new_phone", newPhone)
        fill(&body, "new_mobile", newMobile)
        fill(&body, "new_street_address", street)
        fill(&body, "new_city", city)
        fill(&body, "new_province", province)
        fill(&body, "new_postal_code", postalCode)
        fill(&body, "new_country", country)
        fill(&body, "emergency_contact_name", emergencyName)
        fill(&body, "emergency_contact_relationship", emergencyRelationship)
        fill(&body, "emergency_contact_phone", emergencyPhone)
        fill(&body, "emergency_contact_email", emergencyEmail)
        return body
    }

    static func day(_ date: Date, calendar: Calendar = .current) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }

    private static func fill(_ body: inout [String: Any], _ key: String, _ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            body[key] = trimmed
        }
    }
}

nonisolated enum WelcomeFormLink: Hashable {
    case survey
    case parentConsent
    case contact
    case confidential
    case t2202
}

nonisolated struct WelcomeFormItem: Identifiable, Equatable {
    var id: String
    var title: String
    var subtitle: String
    var description: String
    var link: WelcomeFormLink?
    var downloadPath: String?
}

nonisolated struct WelcomeFormGroup: Identifiable, Equatable {
    var id: String { label }
    var label: String
    var description: String
    var items: [WelcomeFormItem]
}

nonisolated enum WelcomeFormCatalog {
    static let groups: [WelcomeFormGroup] = [
        WelcomeFormGroup(
            label: "Onboarding Forms",
            description: "Complete these before your first day",
            items: [
                WelcomeFormItem(id: "survey", title: "Welcome Questionnaire", subtitle: "Onboarding", description: "Tell us about yourself. Your goals, creative style, and how we can best support you.", link: .survey),
                WelcomeFormItem(id: "parent-consent", title: "Parent Consent", subtitle: "Optional", description: "Authorize communication with your parent or guardian. Not required. Only submit if applicable.", link: .parentConsent),
            ]
        ),
        WelcomeFormGroup(
            label: "Personal Information",
            description: "Keep your records up to date",
            items: [
                WelcomeFormItem(id: "update-contact", title: "Update Contact", subtitle: "Personal Details", description: "Update your address, phone, email, and emergency contacts.", link: .contact),
                WelcomeFormItem(id: "confidential-form", title: "Confidential Info", subtitle: "Health & Accommodations", description: "Submit confidential student information and accommodation requests.", link: .confidential),
            ]
        ),
        WelcomeFormGroup(
            label: "Tax & Document Requests",
            description: "Official requests for tax and academic documents",
            items: [
                WelcomeFormItem(id: "t2202", title: "T2202 Tax Form Request", subtitle: "Tuition Tax Receipt", description: "Request your official tuition tax receipt for Canadian income tax purposes.", link: .t2202),
            ]
        ),
        WelcomeFormGroup(
            label: "Documents & Downloads",
            description: "Reference materials and campus resources",
            items: [
                WelcomeFormItem(id: "student-handbook", title: "Student Handbook", subtitle: "Download", description: "Complete guide covering campus locations, policies, academic requirements, student services, and all essential information.", downloadPath: "/documents/student_handbook.pdf"),
                WelcomeFormItem(id: "campus-map", title: "Campus Map", subtitle: "Download", description: "Detailed map showing all VFS campus locations in downtown Vancouver.", downloadPath: "/documents/campus_map.pdf"),
            ]
        ),
    ]

    static func downloadURL(path: String, base: URL) -> URL? {
        var components = URLComponents(url: base, resolvingAgainstBaseURL: false)
        components?.path = path
        return components?.url
    }
}
