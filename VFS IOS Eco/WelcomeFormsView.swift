import SwiftUI
import UniformTypeIdentifiers
import UIKit

struct WelcomeFormsView: View {
    @Bindable var session: AppSession
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                GuideHero(
                    lead: "Forms, Documents, &",
                    accent: "Requests",
                    accentColor: .pageSlate,
                    detail: "Submit official requests and keep your student record up to date from anywhere."
                )

                ForEach(WelcomeFormCatalog.groups) { group in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(group.label.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.4)
                            .foregroundStyle(Color.stoneMuted)
                        Text(group.description)
                            .font(.subheadline)
                            .foregroundStyle(Color.stoneMuted)
                        ForEach(group.items) { item in
                            if let link = item.link {
                                NavigationLink(value: link) {
                                    formCard(item)
                                }
                                .buttonStyle(.plain)
                            } else if let path = item.downloadPath,
                                      let url = WelcomeFormCatalog.downloadURL(path: path, base: APIConfiguration.baseURL) {
                                Button {
                                    openURL(url)
                                } label: {
                                    formCard(item)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .deskPage(tint: .pageSlate)
        .navigationTitle("Forms")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: WelcomeFormLink.self) { link in
            switch link {
            case .survey:
                QuestionnaireFormView(session: session)
            case .parentConsent:
                ParentConsentFormView(session: session)
            case .contact:
                ContactUpdateFormView(session: session)
            case .confidential:
                ConfidentialFormView(session: session)
            case .t2202:
                T2202FormView(session: session)
            }
        }
    }

    private func formCard(_ item: WelcomeFormItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.subtitle.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Color.welcomeRed)
            Text(item.title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(Color.stoneInk)
            Text(item.description)
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
        }
        .guideCard()
    }
}

struct ParentConsentFormView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()

    @State private var person1Name = ""
    @State private var person1Relationship = ""
    @State private var person1Phone = ""
    @State private var person1Email = ""
    @State private var person2Name = ""
    @State private var person2Relationship = ""
    @State private var person2Phone = ""
    @State private var person2Email = ""
    @State private var studentName = ""
    @State private var studentSignature = ""
    @State private var date = Date()
    @State private var consent = false
    @State private var confirmation: String?
    @State private var status: String?
    @State private var isBusy = false

    var body: some View {
        formShell(title: "Parent Consent", confirmation: confirmation, status: status) {
            Text("Admissions Office")
                .font(.system(size: 22, weight: .black))
            Text("198 W. Hastings St, Vancouver, BC, Canada V6B1H2")
            Text("E: reception198@vfs.com")
            Text("T: 604 685 5808")
            Text("Instructions")
                .font(.headline)
            Text("1. Complete this consent form and add your signature")
            Text("2. Click Submit to send the form to your VFS Advisor/Coordinator")
            Text("This form is for students who wish to give consent for VFS to communicate with their parent or guardian regarding tuition payments, grades, attendance, and other matters related to enrollment at VFS.")
            Text("THIS FORM IS OPTIONAL AND SHOULD BE COMPLETED ONLY IF APPLICABLE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.1)

            section("Person 1: Authorized 3rd Party Contact Information (Optional)") {
                field("Person 1 Full Name", text: $person1Name, prompt: "Enter full name")
                field("Person 1 Relationship with Student", text: $person1Relationship, prompt: "e.g., Parent, Guardian")
                field("Phone", text: $person1Phone, prompt: "(123) 456-7890")
                field("Email", text: $person1Email, prompt: "email@example.com")
            }
            section("Person 2: Authorized 3rd Party Contact Information (Optional)") {
                field("Person 2 Full Name", text: $person2Name, prompt: "Enter full name")
                field("Person 2 Relationship with Student", text: $person2Relationship, prompt: "e.g., Parent, Guardian")
                field("Phone", text: $person2Phone, prompt: "(123) 456-7890")
                field("Email", text: $person2Email, prompt: "email@example.com")
            }
            section("Student Declaration") {
                Text("Signing this declaration permits Vancouver Film School to request and/or confirm any information necessary to support my enrollment.")
                Text("I hereby authorize Vancouver Film School to release application information, admission status, admission correspondence and tuition payment information to the 3rd Party representative(s) identified on this authorization form for the duration of my program.")
                field("Student Name", text: $studentName, prompt: "Enter your full name")
                field("Student Signature", text: $studentSignature, prompt: "Type your name as signature")
                Text("By typing your name, you are providing a legal electronic signature")
                    .font(.footnote)
                DatePicker("Date", selection: $date, displayedComponents: .date)
                Toggle("I acknowledge that I have read and understood the declaration above, and I consent to VFS communicating with the authorized representatives listed on this form.", isOn: $consent)
            }
            submitButton("Submit Consent Form", enabled: !studentName.isEmpty && !studentSignature.isEmpty && consent && !isBusy) {
                await send()
            }
        }
        .navigationTitle("Parent Consent")
    }

    private func send() async {
        await post {
            try await client.submitJSON(
                path: "/api/welcome/parent-consent",
                body: FormDrafts.parentConsent(
                    person1Name: person1Name,
                    person1Relationship: person1Relationship,
                    person1Phone: person1Phone,
                    person1Email: person1Email,
                    person2Name: person2Name,
                    person2Relationship: person2Relationship,
                    person2Phone: person2Phone,
                    person2Email: person2Email,
                    studentName: studentName,
                    studentSignature: studentSignature,
                    date: FormDrafts.day(date),
                    consent: true
                )
            )
        }
    }
}

struct ContactUpdateFormView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()

    @State private var fullName = ""
    @State private var preferredName = ""
    @State private var studentId = ""
    @State private var classId = ""
    @State private var dateOfBirth = Date()
    @State private var newEmail = ""
    @State private var newPhone = ""
    @State private var newMobile = ""
    @State private var street = ""
    @State private var city = ""
    @State private var province = ""
    @State private var postalCode = ""
    @State private var country = "Canada"
    @State private var emergencyName = ""
    @State private var emergencyRelationship = ""
    @State private var emergencyPhone = ""
    @State private var emergencyEmail = ""
    @State private var confirmation: String?
    @State private var status: String?
    @State private var isBusy = false

    var body: some View {
        formShell(title: "Update Contact", confirmation: confirmation, status: status) {
            section("Student Identification") {
                field("Full Legal Name", text: $fullName)
                field("Preferred Name", text: $preferredName, prompt: "The name you prefer to go by (if different from legal name)")
                field("Student ID", text: $studentId)
                field("Class ID", text: $classId)
                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
            }
            section("New Contact Information") {
                Text("Only fill in the fields you wish to update.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                field("New Email", text: $newEmail)
                field("New Phone", text: $newPhone)
                field("New Mobile", text: $newMobile)
            }
            section("New Address") {
                field("Street Address", text: $street)
                field("City", text: $city)
                Picker("Province", selection: $province) {
                    Text("Select Province").tag("")
                    ForEach(FormDrafts.provinces, id: \.self) { Text($0).tag($0) }
                }
                field("Postal Code", text: $postalCode)
                field("Country", text: $country)
            }
            section("Emergency Contact") {
                field("Contact Name", text: $emergencyName)
                Picker("Relationship", selection: $emergencyRelationship) {
                    Text("Select Relationship").tag("")
                    ForEach(FormDrafts.relationships, id: \.self) { Text($0).tag($0) }
                }
                field("Contact Phone", text: $emergencyPhone)
                field("Contact Email", text: $emergencyEmail)
            }
            submitButton("Submit Update", enabled: !fullName.trimmingCharacters(in: .whitespaces).isEmpty && !isBusy) {
                await send()
            }
        }
        .navigationTitle("Update Contact")
    }

    private func send() async {
        await post {
            try await client.submitJSON(
                path: "/api/welcome/update-contact",
                body: FormDrafts.contactUpdate(
                    fullName: fullName,
                    preferredName: preferredName,
                    studentId: studentId,
                    classId: classId,
                    dateOfBirth: FormDrafts.day(dateOfBirth),
                    newEmail: newEmail,
                    newPhone: newPhone,
                    newMobile: newMobile,
                    street: street,
                    city: city,
                    province: province,
                    postalCode: postalCode,
                    country: country,
                    emergencyName: emergencyName,
                    emergencyRelationship: emergencyRelationship,
                    emergencyPhone: emergencyPhone,
                    emergencyEmail: emergencyEmail
                )
            )
        }
    }
}

struct T2202FormView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()
    var submitPath = "/api/welcome/t2202-request"
    var prefill = false

    @State private var fullName = ""
    @State private var studentId = ""
    @State private var classId = ""
    @State private var dateOfBirth = Date()
    @State private var street = ""
    @State private var city = ""
    @State private var province = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var taxYears = ""
    @State private var delivery = "email"
    @State private var signature = false
    @State private var confirmation: String?
    @State private var status: String?
    @State private var isBusy = false

    var body: some View {
        formShell(title: "T2202 Tax Form Request", confirmation: confirmation, status: status) {
            section("Student Identification") {
                field("Full Name", text: $fullName, prompt: "Legal Name")
                field("Student ID", text: $studentId, prompt: "123456")
                field("Class ID", text: $classId, prompt: "e.g. CA87")
                DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
            }
            section("Contact Details") {
                field("Current Address", text: $street, prompt: "Street Address")
                field("City", text: $city, prompt: "City")
                Picker("Province", selection: $province) {
                    Text("Select Province").tag("")
                    ForEach(FormDrafts.provinces, id: \.self) { Text($0).tag($0) }
                }
                field("Email", text: $email)
                field("Phone", text: $phone)
            }
            section("Request Details") {
                field("Tax Year(s) Required", text: $taxYears, prompt: "e.g., 2023, 2024")
                Picker("Delivery Method", selection: $delivery) {
                    Text("Email").tag("email")
                    Text("Mail").tag("mail")
                    Text("Pick Up").tag("pickup")
                }
                .pickerStyle(.segmented)
                Toggle("I certify that I am the student named above and authorize VFS to process this request.", isOn: $signature)
            }
            submitButton("Submit Request", enabled: ready && !isBusy) {
                await send()
            }
        }
        .navigationTitle("T2202 Request")
        .onAppear {
            guard prefill, let user = session.account?.user else { return }
            if fullName.isEmpty { fullName = user.name }
            if email.isEmpty { email = user.email }
        }
    }

    private var ready: Bool {
        !fullName.isEmpty && !studentId.isEmpty && !classId.isEmpty && !street.isEmpty && !city.isEmpty && !email.isEmpty && !phone.isEmpty && !taxYears.isEmpty && signature
    }

    private func send() async {
        var body: [String: Any] = [
            "full_name": fullName,
            "student_id": studentId,
            "class_id": classId,
            "street_address": street,
            "city": city,
            "phone_number": phone,
            "date_of_birth": FormDrafts.day(dateOfBirth),
            "email": email,
            "tax_years_required": taxYears,
            "delivery_method": delivery,
            "signature_confirmed": true,
        ]
        if !province.isEmpty { body["province"] = province }
        await post {
            try await client.submitJSON(path: submitPath, body: body)
        }
    }
}

struct ConfidentialFormView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()

    @State private var name = ""
    @State private var details = ""
    @State private var acknowledgment = false
    @State private var files: [FormAttachment] = []
    @State private var picking = false
    @State private var confirmation: String?
    @State private var status: String?
    @State private var isBusy = false

    var body: some View {
        formShell(title: "Confidential Student Information Form", confirmation: confirmation, status: status) {
            Text("VFS continually strives to offer an inclusive and diverse learning environment. We are committed to supporting the successful learning of all students and VFS recognizes the importance of providing additional supports particularly for those students with health challenges, learning difficulties and specific educational requirements. In order for VFS to offer appropriate, sufficient and reasonable support it is necessary that students fully disclose any specific educational requirements they may have for which they will require academic consideration or accommodation. The primary purpose of gathering this information is to provide support and will remain confidential to relevant parties.")
            Text("Please consider the following questions and provide examples in the text box below if any of these apply to you.")
                .font(.headline)
            Text("Do you have a physical or health condition that may affect your education that VFS should be aware of in case of emergency?")
            Text("Do you have mental health challenges that may affect your education that VFS should be aware of?")
            Text("Have you had previous academic accommodations to support a learning or mental health difficulty? If so, will you require academic accommodations while attending VFS?")
            field("First and Last Name", text: $name, prompt: "Enter your full name")
            VStack(alignment: .leading, spacing: 6) {
                Text("Additional information")
                    .font(.subheadline.weight(.semibold))
                TextField("Please provide detailed information addressing the questions above...", text: $details, axis: .vertical)
                    .lineLimit(5...10)
                    .padding()
                    .background(Color.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Text("Please provide as much detail as possible to help us support you effectively.")
                    .font(.footnote)
                    .foregroundStyle(Color.stoneMuted)
            }
            section("Attach Supporting Documents (Optional)") {
                Text("You may attach supporting documents such as medical documentation, accommodation letters, or previous assessment reports. Maximum 10MB per file.")
                    .font(.footnote)
                    .foregroundStyle(Color.stoneMuted)
                Button("Choose files") { picking = true }
                    .tint(Color.welcomeRed)
                Text("Supported formats: PDF, JPG, PNG, DOC, DOCX")
                    .font(.footnote)
                    .foregroundStyle(Color.stoneMuted)
                ForEach(Array(files.enumerated()), id: \.offset) { index, file in
                    HStack {
                        Text(file.filename)
                            .font(.subheadline)
                        Spacer()
                        Button("Remove") { files.remove(at: index) }
                            .tint(Color.welcomeRed)
                    }
                }
            }
            Text("PERSONAL PRIVACY POLICY")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
            Text("The information collected on this form will be used for educational accommodation purposes and other fundamental activities related to attending course of instruction at VFS. VFS will protect and safeguard personal information and only provide access to authorized employees. The VFS Student Handbook contains the full VFS policy, which is in compliance with British Columbia's Personal Information Protection Act.")
                .font(.footnote)
            Toggle("I have read and understood the Personal Privacy Policy above, and I consent to VFS using this information for educational accommodation purposes.", isOn: $acknowledgment)
            submitButton("Submit Confidential Form", enabled: !name.isEmpty && !details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && acknowledgment && !isBusy) {
                await send()
            }
        }
        .navigationTitle("Confidential Info")
        .fileImporter(
            isPresented: $picking,
            allowedContentTypes: [.pdf, .jpeg, .png, .heic, UTType("com.microsoft.word.doc") ?? .data, UTType("org.openxmlformats.wordprocessingml.document") ?? .data],
            allowsMultipleSelection: true
        ) { result in
            importFiles(result)
        }
    }

    private func importFiles(_ result: Result<[URL], Error>) {
        guard case .success(let urls) = result else {
            status = "Upload a PDF, JPEG, PNG, or Word document."
            return
        }
        for url in urls {
            guard files.count < 5 else { break }
            let started = url.startAccessingSecurityScopedResource()
            defer { if started { url.stopAccessingSecurityScopedResource() } }
            guard let data = try? Data(contentsOf: url), data.count <= 10 * 1024 * 1024 else {
                status = "Maximum 10MB per file."
                continue
            }
            if let attachment = FormAttachment.make(url: url, data: data) {
                files.append(attachment)
            } else {
                status = "Upload a PDF, JPEG, PNG, or Word document."
            }
        }
    }

    private func send() async {
        await post {
            try await client.submitMultipart(
                path: "/api/welcome/confidential-form",
                fields: [
                    "first_last_name": name,
                    "additional_information": details,
                    "acknowledgment": "1",
                ],
                files: files
            )
        }
    }
}

struct QuestionnaireFormView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()

    @State private var form: SurveyForm?
    @State private var draft = QuestionnaireDraft()
    @State private var confirmation: String?
    @State private var status: String?
    @State private var isBusy = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "Tell Us About",
                    accent: "You",
                    accentColor: .welcomeRed,
                    detail: "Help us understand your goals, creative style, and how we can best support you during your time at VFS."
                )
                if let confirmation {
                    Text(confirmation)
                        .font(.system(size: 22, weight: .black))
                } else if form?.alreadySubmitted == true {
                    Text("You have already submitted this questionnaire.")
                } else if let form {
                    Text("Your responses are confidential and will only be used to improve your experience at VFS.")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    ForEach(form.questions) { question in
                        questionView(question)
                    }
                    if let status {
                        Text(status)
                            .font(.subheadline)
                    }
                    Button(isBusy ? "Submitting..." : "Submit Questionnaire") {
                        Task { await send(form) }
                    }
                    .buttonStyle(CrimsonButtonStyle())
                    .disabled(isBusy)
                } else if let status {
                    Text(status)
                } else {
                    ProgressView()
                }
            }
            .padding(20)
        }
        .deskPage()
        .navigationTitle("Questionnaire")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    @ViewBuilder
    private func questionView(_ question: SurveyQuestion) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(question.prompt)
                .font(.headline)
            if let hint = question.hint {
                Text(hint)
                    .font(.footnote)
                    .foregroundStyle(Color.stoneMuted)
            }
            switch question.kind {
            case "text":
                TextField("", text: textBinding(question.id), axis: .vertical)
                    .lineLimit(3...8)
                    .padding()
                    .background(Color.card)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            case "multi":
                ForEach(question.options ?? []) { option in
                    Toggle(option.label, isOn: multiBinding(question, option.key))
                }
            case "single":
                Picker(question.prompt, selection: singleBinding(question.id)) {
                    Text("Choose").tag("")
                    ForEach(question.options ?? []) { option in
                        Text(option.label).tag(option.key)
                    }
                }
            case "scale":
                Picker(question.prompt, selection: scaleBinding(question.id)) {
                    Text("Choose").tag(0)
                    ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                }
                .pickerStyle(.segmented)
            case "rank3":
                ForEach(["1", "2", "3"], id: \.self) { rank in
                    Picker("Rank \(rank)", selection: rankBinding(rank)) {
                        Text("Choose").tag("")
                        ForEach(question.options ?? []) { option in
                            Text(option.label).tag(option.key)
                        }
                    }
                }
            case "scales":
                ForEach(question.options ?? []) { option in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(option.label)
                            .font(.subheadline)
                        Picker(option.label, selection: agreementBinding(option.key)) {
                            Text("Choose").tag(0)
                            ForEach(1...5, id: \.self) { Text("\($0)").tag($0) }
                        }
                        .pickerStyle(.segmented)
                    }
                }
            default:
                EmptyView()
            }
        }
        .guideCard()
    }

    private func load() async {
        do {
            form = try await client.survey()
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            status = error.text
        } catch {
            status = "The questionnaire could not be loaded."
        }
    }

    private func send(_ form: SurveyForm) async {
        isBusy = true
        status = nil
        do {
            confirmation = try await client.submitJSON(path: "/api/welcome/survey", body: draft.payload())
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            status = error.text
        } catch {
            status = "The questionnaire could not be submitted."
        }
        isBusy = false
    }

    private func textBinding(_ id: String) -> Binding<String> {
        Binding(get: { draft.text[id] ?? "" }, set: { draft.text[id] = $0 })
    }

    private func singleBinding(_ id: String) -> Binding<String> {
        Binding(get: { draft.single[id] ?? "" }, set: { draft.single[id] = $0 })
    }

    private func scaleBinding(_ id: String) -> Binding<Int> {
        Binding(get: { draft.scales[id] ?? 0 }, set: { if $0 > 0 { draft.scales[id] = $0 } })
    }

    private func rankBinding(_ rank: String) -> Binding<String> {
        Binding(get: { draft.ranks[rank] ?? "" }, set: { draft.ranks[rank] = $0 })
    }

    private func agreementBinding(_ key: String) -> Binding<Int> {
        Binding(get: { draft.agreements[key] ?? 0 }, set: { if $0 > 0 { draft.agreements[key] = $0 } })
    }

    private func multiBinding(_ question: SurveyQuestion, _ key: String) -> Binding<Bool> {
        Binding(
            get: { draft.selections[question.id]?.contains(key) == true },
            set: { selected in
                var values = draft.selections[question.id] ?? []
                if selected {
                    if let max = question.max, values.count >= max { return }
                    if !values.contains(key) { values.append(key) }
                } else {
                    values.removeAll { $0 == key }
                }
                draft.selections[question.id] = values
            }
        )
    }
}

private extension ParentConsentFormView {
    func post(_ work: () async throws -> String) async { await runPost(work) }
}

private extension ContactUpdateFormView {
    func post(_ work: () async throws -> String) async { await runPost(work) }
}

private extension T2202FormView {
    func post(_ work: () async throws -> String) async { await runPost(work) }
}

private extension ConfidentialFormView {
    func post(_ work: () async throws -> String) async { await runPost(work) }
}

private extension ParentConsentFormView {
    func runPost(_ work: () async throws -> String) async {
        isBusy = true
        status = nil
        do {
            confirmation = try await work()
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            status = error.text
        } catch {
            status = "The form could not be submitted."
        }
        isBusy = false
    }
}

private extension ContactUpdateFormView {
    func runPost(_ work: () async throws -> String) async {
        isBusy = true
        status = nil
        do {
            confirmation = try await work()
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            status = error.text
        } catch {
            status = "The form could not be submitted."
        }
        isBusy = false
    }
}

private extension T2202FormView {
    func runPost(_ work: () async throws -> String) async {
        isBusy = true
        status = nil
        do {
            confirmation = try await work()
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            status = error.text
        } catch {
            status = "The form could not be submitted."
        }
        isBusy = false
    }
}

private extension ConfidentialFormView {
    func runPost(_ work: () async throws -> String) async {
        isBusy = true
        status = nil
        do {
            confirmation = try await work()
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            status = error.text
        } catch {
            status = "The form could not be submitted."
        }
        isBusy = false
    }
}

extension FormAttachment {
    @MainActor
    static func make(url: URL, data: Data) -> FormAttachment? {
        let name = url.lastPathComponent
        let ext = url.pathExtension.lowercased()
        if ext == "heic" || ext == "heif" {
            guard let image = UIImage(data: data), let jpeg = image.jpegData(compressionQuality: 0.9) else { return nil }
            let base = (name as NSString).deletingPathExtension
            return FormAttachment(filename: "\(base).jpg", mimeType: "image/jpeg", data: jpeg)
        }
        let mime: String
        switch ext {
        case "pdf": mime = "application/pdf"
        case "jpg", "jpeg": mime = "image/jpeg"
        case "png": mime = "image/png"
        case "doc": mime = "application/msword"
        case "docx": mime = "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        default: return nil
        }
        return FormAttachment(filename: name, mimeType: mime, data: data)
    }
}

private extension APIError {
    var text: String {
        switch self {
        case .message(let message): return message
        case .unauthorized: return "Sign in again."
        }
    }
}

@ViewBuilder
private func formShell<Content: View>(title: String, confirmation: String?, status: String?, @ViewBuilder content: () -> Content) -> some View {
    ScrollView {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(Color.stoneInk)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
            if let confirmation {
                Text(confirmation)
                    .font(.body)
            } else {
                content()
                if let status {
                    Text(status)
                        .font(.subheadline)
                }
            }
        }
        .padding(20)
    }
    .deskPage()
    .navigationBarTitleDisplayMode(.inline)
}

@ViewBuilder
private func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
    VStack(alignment: .leading, spacing: 10) {
        Text(title)
            .font(.system(size: 22, weight: .black))
        content()
    }
    .guideCard()
}

private func field(_ title: String, text: Binding<String>, prompt: String = "") -> some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title)
            .font(.subheadline.weight(.semibold))
        TextField(prompt, text: text)
            .textInputAutocapitalization(.never)
            .padding()
            .background(Color.card)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private func submitButton(_ title: String, enabled: Bool, action: @escaping () async -> Void) -> some View {
    Button(title) { Task { await action() } }
        .buttonStyle(CrimsonButtonStyle())
        .disabled(!enabled)
}
