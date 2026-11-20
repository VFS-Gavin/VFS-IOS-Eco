import SwiftUI

struct DocumentRequestsView: View {
    private let gold = Color(red: 202 / 255, green: 138 / 255, blue: 4 / 255)
    private let bronze = Color(red: 180 / 255, green: 83 / 255, blue: 9 / 255)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                Text("Document")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Requests")
                    .font(.system(size: 40, weight: .bold, design: .serif))
                    .foregroundStyle(gold)
                    .padding(.top, -16)
                Text("Request official tax receipts, transcripts, and diplomas from your time at VFS.")
                    .font(.body)
                    .foregroundStyle(Color.stoneMuted)
                requestCard(
                    route: .account(.t2202Request),
                    eyebrow: "Tax Documents",
                    title: "T2202 Tax Receipt",
                    detail: "Request your official tuition tax receipt for Canadian income tax purposes.",
                    action: "Request Form",
                    tint: gold
                )
                requestCard(
                    route: .account(.transcriptRequest),
                    eyebrow: "Official Documents",
                    title: "Transcript & Diploma Request",
                    detail: "Request official copies of your transcripts, certificates, or diplomas.",
                    action: "View Instructions",
                    tint: bronze
                )
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.stone)
        .navigationTitle("Document Requests")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func requestCard(route: CreativeRoute, eyebrow: String, title: String, detail: String, action: String, tint: Color) -> some View {
        CreativeLink(route: route) {
            VStack(alignment: .leading, spacing: 12) {
                Rectangle().fill(tint).frame(height: 3)
                VStack(alignment: .leading, spacing: 8) {
                    Text(eyebrow.uppercased())
                        .font(.caption2.weight(.bold))
                        .tracking(1.4)
                        .foregroundStyle(tint)
                    Text(title)
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    Text(detail)
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    Text(action)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(tint)
                        .padding(.top, 8)
                }
                .padding(18)
            }
            .background(Color.card)
            .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

struct TranscriptRequestView: View {
    @Environment(\.openURL) private var openURL
    private let bronze = Color(red: 180 / 255, green: 83 / 255, blue: 9 / 255)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("Transcript &")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Diploma Request")
                    .font(.system(size: 36, weight: .bold, design: .serif))
                    .foregroundStyle(bronze)
                    .padding(.top, -12)
                Text("Request official copies of your transcripts, certificates, or diplomas.")
                    .font(.body)
                    .foregroundStyle(Color.stoneMuted)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Current Students")
                        .font(.headline)
                        .foregroundStyle(Color(red: 6 / 255, green: 95 / 255, blue: 70 / 255))
                    Text("If you are a current VFS student, you can download your confirmation of enrollment letter and official transcript directly at MyVFS.com.")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneInk)
                    Button("MyVFS.com") {
                        if let url = URL(string: "https://www.myvfs.com") { openURL(url) }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(bronze)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 236 / 255, green: 253 / 255, blue: 245 / 255))
                .overlay(Rectangle().stroke(Color(red: 167 / 255, green: 243 / 255, blue: 208 / 255), lineWidth: 1))

                VStack(alignment: .leading, spacing: 14) {
                    Text("For Graduates")
                        .font(.system(size: 22, weight: .bold, design: .serif))
                        .foregroundStyle(Color.stoneInk)
                    Text("Request printed copies of your official documents")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    Text("To request a printed copy of your transcript, certificate, or diploma, please download and complete the request form below, then email it to the appropriate department.")
                        .font(.body)
                        .foregroundStyle(Color.stoneInk)
                    step(1, "Download the Request Form", "Click the button below to download the official Transcript/Diploma/Certificate Request Form (PDF).")
                    step(2, "Complete the Form", "Fill out all required information including your name, student number, program, graduation year, and the documents you need. Sign the form as required by the Freedom of Information and Privacy Protection Act.")
                    step(3, "Submit the Completed Form", "Email your completed and signed form to edadmin@vfs.com")
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Important Information:")
                            .font(.subheadline.weight(.bold))
                        Text("Digital documents are FREE")
                        Text("Physical transcripts: $10 each")
                        Text("Physical certificates/diplomas: $25 each")
                        Text("Documents cannot be issued if you have outstanding tuition fees")
                        Text("VFS alumni who graduated within a year receive free physical documents")
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                    Button("Download Request Form (PDF)") {
                        if let url = formURL { openURL(url) }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(bronze)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.card)
                .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))

                VStack(alignment: .leading, spacing: 10) {
                    Text("Need Help?")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                    Text("If you have any questions about document requests, or wish to request a letter, please contact:")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    Button("edadmin@vfs.com") {
                        if let url = URL(string: "mailto:edadmin@vfs.com") { openURL(url) }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(bronze)
                    Button("VFS Alumni Services") {
                        if let url = URL(string: "https://vfs.edu/alumni-services") { openURL(url) }
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(bronze)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.card)
                .overlay(Rectangle().stroke(Color.stoneLine, lineWidth: 1))
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("Transcript & Diploma")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var formURL: URL? {
        APIConfiguration.baseURL.appending(path: "documents/transcript_request_form.pdf")
    }

    private func step(_ number: Int, _ title: String, _ detail: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.white)
                .frame(width: 28, height: 28)
                .background(bronze)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.subheadline.weight(.bold)).foregroundStyle(Color.stoneInk)
                Text(detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
            }
        }
    }
}
