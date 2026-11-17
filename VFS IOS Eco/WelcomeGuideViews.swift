import SwiftUI

struct StudyPermitView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "Study Permit",
                    accent: "& Visa Guide",
                    accentColor: .pagePurple,
                    detail: "A step-by-step guide for international students."
                )

                step("01", "Letter of Acceptance", "You must include your official Letter of Acceptance (LOA) from VFS.", note: "Required Document")
                step("02", "Gather Documents", "Prepare digital copies of all necessary documents. Ensure your passport is valid for your entire stay.", lines: [
                    "Valid Passport",
                    "Proof of Financial Support",
                ])
                step("03", "Provincial Attestation Letter (PAL)", "As of January 22, 2024, most international students need a Provincial Attestation Letter to apply for a study permit. VFS will provide yours once your enrollment is confirmed.", lines: [
                    "VFS issues your PAL after enrollment confirmation",
                    "Include PAL with your study permit application",
                    "Allow extra time. PAL processing may take a few weeks",
                ], note: "Required for most new study permit applications")
                step("04", "Apply Online", "Submit your application through the Immigration, Refugees and Citizenship Canada (IRCC) secure portal.")

                Button("Go to IRCC Website") {
                    if let url = URL(string: "https://www.canada.ca/en/immigration-refugees-citizenship/services/study-canada.html") {
                        openURL(url)
                    }
                }
                .buttonStyle(CrimsonButtonStyle())
                .accessibilityIdentifier("study-permit-ircc")

                Text("Have questions about the study permit process? Contact your coordinator for personalized assistance.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                NavigationLink(value: WelcomeRoute.coordinator) {
                    Text("Contact your coordinator")
                }
                .tint(Color.welcomeRed)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Processing Times Vary")
                        .font(.headline)
                    Text("Check the current processing times on the IRCC website to plan your arrival.")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    Button("Current processing times") {
                        if let url = URL(string: "https://www.canada.ca/en/immigration-refugees-citizenship/services/application/check-processing-times.html") {
                            openURL(url)
                        }
                    }
                    .tint(Color.welcomeRed)
                }
                .guideCard()
            }
            .padding(20)
        }
        .deskPage(tint: .pagePurple)
        .navigationTitle("Study Permit")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func step(_ number: String, _ title: String, _ body: String, lines: [String] = [], note: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.welcomeRed)
            Text(title)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(Color.stoneInk)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
            ForEach(lines, id: \.self) { line in
                Text(line)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.stoneInk)
            }
            if let note {
                Text(note)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.welcomeRed)
            }
        }
        .guideCard()
        .accessibilityIdentifier("study-permit-\(number)")
    }
}

struct InsuranceView: View {
    @Environment(\.openURL) private var openURL

    private let costs = [
        ("$927", "Emergency Visit"),
        ("$1,000+", "Outpatient/Day"),
        ("$3,495", "Day Surgery"),
        ("$49+", "X-Ray"),
        ("$2,028", "MRI"),
        ("$240", "Ambulance"),
        ("$125", "Lab Test"),
        ("$100-240", "Physician Fees"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "Student",
                    accent: "Medical Insurance",
                    accentColor: .hubBlue,
                    detail: "All VFS students MUST have medical insurance while studying in Canada. Apply for coverage before you arrive. It must cover your first three months in British Columbia."
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Why Insurance is Essential")
                        .font(.headline)
                        .foregroundStyle(Color.welcomeRed)
                    Text("Medical costs in Canada without insurance can be extremely expensive:")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    ForEach(costs, id: \.1) { amount, label in
                        HStack {
                            Text(amount).font(.headline)
                            Text(label).font(.subheadline).foregroundStyle(Color.stoneMuted)
                        }
                    }
                }
                .guideCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("International Students")
                        .font(.system(size: 22, weight: .black))
                    Text("VFS partners with Edvisor to provide StudyInsured coverage for international students at affordable rates.")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    Text("Coverage Cost")
                        .font(.caption)
                        .foregroundStyle(Color.stoneMuted)
                    Text("$3.00 CAD/day")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(Color.welcomeRed)
                        .accessibilityIdentifier("insurance-daily-rate")
                    Text("Coverage Up To $5,000,000")
                        .font(.headline)
                    ForEach([
                        "Coverage starts up to 7 days before arrival",
                        "Extends 1 week after program end date",
                        "Virtual doctor service available 24/7",
                        "Direct-pay clinics near VFS campus",
                    ], id: \.self) { line in
                        Text(line).font(.subheadline)
                    }
                    Text("EMERGENCY ASSISTANCE (24/7)")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.stoneMuted)
                    Button("1.866.883.9787") {
                        if let url = SupportLinks.phone("1.866.883.9787") { openURL(url) }
                    }
                    .tint(Color.welcomeRed)
                    Text("Contact within 48 hours of serious illness/injury for full benefits")
                        .font(.caption)
                        .foregroundStyle(Color.stoneMuted)
                    Button("Visit Edvisor Insurance Portal") {
                        if let url = URL(string: "https://student-portal.edvisor.io/vancouverdfilmschoolinsurance/insurance?ref=eyJvZmZpY2VJZCI6MTM5MTksInVzZXJJZCI6NjM4NzB9") {
                            openURL(url)
                        }
                    }
                    .buttonStyle(CrimsonButtonStyle())
                }
                .guideCard()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Canadian Students")
                        .font(.system(size: 22, weight: .black))
                    Text("Canadian students can remain on their home province's medical plan. You must notify your provincial health provider that you'll be studying at a post-secondary school in BC.")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                    plan("BC", "Medical Services Plan (MSP)", "BC residents maintain existing coverage")
                    plan("AB", "AHCIP Coverage", "Alberta Health Care Insurance Plan")
                    plan("ON", "OHIP Coverage", "Ontario Health Insurance Plan")
                    Text("Moving to BC? You can apply for BC's Medical Services Plan (MSP) as soon as you arrive. Use StudyInsured for your first 3 months, then switch to MSP once approved.")
                        .font(.subheadline)
                    Button("Check MSP Eligibility") {
                        if let url = URL(string: "https://www2.gov.bc.ca/gov/content/health/health-drug-coverage/msp") {
                            openURL(url)
                        }
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.welcomeRed)
                }
                .guideCard()

                Text("Frequently Asked Questions")
                    .font(.system(size: 28, weight: .black))
                faq("When does my coverage start?", "StudyInsured covers you from the time you leave home (up to 7 days prior to arrival) until one week after your program end date.")
                faq("How do I make a claim?", "Visit the Edvisor insurance portal, register, then submit claims securely and track progress online.")
                faq("Can I use other insurance providers?", "Yes. VFS accepts insurance from companies outside of Canada. However, we recommend StudyInsured through Edvisor for comprehensive coverage at affordable rates.")
                faq("What if I have a medical emergency?", "Contact StudyInsured Assistance at 1.866.883.9787 within 48 hours. They're available 24/7 and can help find local medical providers.")

                Text("Student Services can help with insurance queries.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                Button("Contact Student Services") {
                    if let url = URL(string: "mailto:studentservices@vfs.com") { openURL(url) }
                }
                .tint(Color.welcomeRed)
            }
            .padding(20)
        }
        .deskPage(tint: .hubBlue)
        .navigationTitle("Medical Insurance")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func plan(_ code: String, _ title: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(code) · \(title)").font(.subheadline.weight(.semibold))
            Text(detail).font(.caption).foregroundStyle(Color.stoneMuted)
        }
    }

    private func faq(_ question: String, _ answer: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(question).font(.headline)
            Text(answer).font(.subheadline).foregroundStyle(Color.stoneMuted)
        }
        .guideCard()
    }
}

struct StudentStoriesView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "Student",
                    accent: "Stories",
                    accentColor: .pagePurple,
                    detail: "Hear from the creators who walked these halls before you and are now shaping the entertainment industry."
                )
                Button("Watch The VFS Experience") {
                    if let url = URL(string: "https://www.youtube.com/watch?v=8fuwY3h7GOM") {
                        openURL(url)
                    }
                }
                .buttonStyle(CrimsonButtonStyle())
                .accessibilityIdentifier("student-stories-video")

                Text("Alumni Highlights")
                    .font(.system(size: 28, weight: .black))
                Text("Recent success stories from the VFS community")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Stories Coming Soon")
                        .font(.headline)
                    Text("We're gathering inspiring stories from our talented VFS alumni. Check back soon to read about their incredible journeys!")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneMuted)
                }
                .guideCard()
                .accessibilityIdentifier("student-stories-empty")
            }
            .padding(20)
        }
        .deskPage(tint: .pagePurple)
        .navigationTitle("Student Stories")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PrepProgram: Identifiable, Equatable {
    var name: String
    var detail: String
    var slug: String?
    var id: String { name }
    var isReady: Bool { slug != nil }
}

enum AcceptanceCatalog {
    static let steps = [
        ("Confirm Enrollment", "Contact admissions to finalize your seat acceptance."),
        ("Sign Documents", "Complete enrollment agreement and student contracts."),
        ("Confirm Study Permit & PAL", "Ensure your study permit and Provincial Attestation Letter are ready. International students only."),
        ("Housing", "Secure your accommodation in Vancouver early."),
        ("Travel Plans", "Book your flights and plan your arrival date."),
    ]

    static let programs = [
        PrepProgram(name: "3D Animation & VFX", detail: "Orientation guide, software & hardware requirements, campus info", slug: "animation"),
        PrepProgram(name: "Classical Animation", detail: "Orientation guide, software & hardware requirements, campus info", slug: "animation"),
        PrepProgram(name: "Animation Concept Art", detail: "Orientation guide, software & hardware requirements, campus info", slug: "animation"),
        PrepProgram(name: "Acting for Film & TV", detail: "Reading lists, preparation tips & recommended viewing", slug: "acting"),
        PrepProgram(name: "Acting Essentials", detail: "Reading lists, preparation tips & recommended viewing", slug: "acting"),
        PrepProgram(name: "Digital Design", detail: "Software tutorials, design resources & creative tools", slug: "digital-design"),
        PrepProgram(name: "Game Design", detail: "Software, hardware, and instructor-curated resource library", slug: "game-design"),
        PrepProgram(name: "Programming for Games, Web & Mobile", detail: "Prep guide: languages, tools, hardware & external resources", slug: "programming-for-games"),
        PrepProgram(name: "Makeup Design for Film & TV", detail: "Program prep, camera requirements & recommended viewing", slug: "makeup-design"),
        PrepProgram(name: "Sound Design", detail: "Headphone requirements & audio equipment guide", slug: "sound-design"),
        PrepProgram(name: "Film Production", detail: "Preparation resources coming soon"),
        PrepProgram(name: "Writing for Film, TV & Games", detail: "Preparation resources coming soon"),
        PrepProgram(name: "Foundation Visual Art & Design", detail: "Preparation resources coming soon"),
    ]
}

struct AcceptanceView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "Welcome to the",
                    accent: "VFS Family",
                    accentColor: .welcomeRed,
                    detail: "We're thrilled you're here. Everything you need to prepare for arrival and start strong on day one."
                )

                Text("Before You Arrive")
                    .font(.system(size: 28, weight: .black))
                ForEach(Array(AcceptanceCatalog.steps.enumerated()), id: \.offset) { index, step in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(index + 1). \(step.0)")
                            .font(.headline)
                        Text(step.1)
                            .font(.subheadline)
                            .foregroundStyle(Color.stoneMuted)
                    }
                    .guideCard()
                }

                Text("Program Preparation")
                    .font(.system(size: 28, weight: .black))
                Text("Select your program to access preparation resources, recommended reading, software requirements, and equipment guides.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)

                ForEach(AcceptanceCatalog.programs) { program in
                    if let slug = program.slug {
                        NavigationLink(value: WelcomeRoute.programPrep(slug)) {
                            programCard(program, ready: true)
                        }
                        .buttonStyle(.plain)
                    } else {
                        programCard(program, ready: false)
                    }
                }

                Text("Don't see your program? More program prep docs are on the way. Check back soon for updates.")
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneMuted)
                Text("Our admissions team is here to help.")
                    .font(.subheadline)
                Button("Contact Admissions") {
                    if let url = URL(string: "mailto:admissions@vfs.edu") { openURL(url) }
                }
                .tint(Color.welcomeRed)
            }
            .padding(20)
        }
        .deskPage()
        .navigationTitle("Acceptance")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func programCard(_ program: PrepProgram, ready: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ready ? "Ready" : "Coming Soon")
                .font(.caption.weight(.bold))
                .foregroundStyle(ready ? Color.welcomeRed : Color.stoneMuted)
            Text(program.name)
                .font(.headline)
                .foregroundStyle(Color.stoneInk)
            Text(program.detail)
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
        }
        .guideCard()
        .opacity(ready ? 1 : 0.6)
        .accessibilityIdentifier("prep-\(program.name)")
    }
}

struct ProgramPrepView: View {
    @Environment(\.openURL) private var openURL
    var slug: String

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch slug {
                case "acting":
                    acting
                case "sound-design":
                    sound
                default:
                    ExtraPrepView(slug: slug)
                }
            }
            .padding(20)
        }
        .deskPage()
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var title: String {
        switch slug {
        case "acting": "Acting for Film & TV"
        case "sound-design": "Sound Design"
        case "animation": "Animation"
        case "digital-design": "Digital Design"
        case "makeup-design": "Makeup Design for Film & TV"
        case "game-design": "Game Design"
        case "programming-for-games": "Programming for Games, Web & Mobile"
        default: "Program Preparation"
        }
    }

    private var acting: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Acting for Film & TV")
                .font(.system(size: 36, weight: .black))
            Text("Preparation tips, reading lists, and resources for Acting for Film & TV and Acting Essentials students")
                .foregroundStyle(Color.stoneMuted)
            Text("What Can You Do to Prepare?")
                .font(.system(size: 22, weight: .black))
            Text("Our VFS Acting Department has put together some helpful notes and tips for students leading up to their first day of class.")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
            Text("Before Your First Day")
                .font(.system(size: 28, weight: .black))
            tip("Read Books on Acting", "Read at least one or two good books on acting (in English — even if it isn't your first language).")
            tip("Read Plays & Scripts", "Read plays and scripts — read them aloud too! We recommend \"13 by Shanley: Thirteen Plays\" by John Patrick Shanley.")
            tip("Watch Plays & Movies", "Go see plays and movies. Immerse yourself in the craft and study how actors bring characters to life.")
            tip("Watch Actor Interviews", "Watch interviews with actors talking about the craft to gain insight into the industry.")
            tip("Follow Acting Blogs", "Find and follow acting blogs to stay connected with the community and learn from professionals.")
            tip("Dress Comfortably", "Make sure to pack comfortable clothing for class that you can move in — and wear it to orientation!")
            Text("Tip: We recommend minimal makeup during class hours.")
                .font(.subheadline.weight(.medium))
            Text("Actor Interviews & Conversations")
                .font(.headline)
            link("Inside the Actors Studio", "http://www.bravotv.com/inside-the-actors-studio")
            link("Variety: Actors on Actors", "https://variety.com/vcategory/actors-on-actors-tv-2018/")
            link("Hollywood Reporter Roundtables", "https://www.hollywoodreporter.com/topic/roundtables")
            Text("Blogs, Scripts & More")
                .font(.headline)
            link("Daily Actor", "https://www.dailyactor.com/actors-on-acting/")
            link("Off Camera", "https://offcamera.com/")
            link("Free Film & TV Scripts", "http://www.script-o-rama.com/")
            Text("VFS Recommended Reading List")
                .font(.system(size: 28, weight: .black))
            Text("These books will help build a strong foundation for your acting career.")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
            book("A Practical Handbook for the Actor", "Melissa Bruder et al.")
            book("The Intent to Live", "Larry Moss")
            book("Acting in Film", "Michael Caine", note: "Available as book and DVD")
            book("Audition", "Michael Shurtleff")
            book("Acting for the Camera", "Tony Barr")
            book("A Challenge for the Actor", "Uta Hagen")
            book("Improv", "Keith Johnstone")
            book("Respect for Acting", "Uta Hagen")
            book("The Technique of Acting", "Stella Adler")
            book("The Stanislavski System", "Sonia Moore")
        }
    }

    private var sound: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Sound Design")
                .font(.system(size: 36, weight: .black))
            Text("Headphone requirements and audio equipment guide for Sound Design students")
                .foregroundStyle(Color.stoneMuted)
            Text("Headphone Requirements")
                .font(.system(size: 22, weight: .black))
            Text("VFS Sound Design students are required to have a good set of headphones to use in class.")
                .font(.subheadline)
            Text("Many students already own suitable headphones, but these notes are a guide for those who do not. Students should bring their headphones if they already own a set.")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
            Text("The good news is you don't have to spend a lot of money or buy an expensive set. You can find suitable headphones in the $100 range.")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
            Text("Important: Use Wired Headphones")
                .font(.headline)
            Text("We recommend you look for a set that comes with a cord. Bluetooth headphones can sometimes experience a lag, which isn't ideal for sound design work.")
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
            Text("Recommended Brands")
                .font(.system(size: 28, weight: .black))
            brand("Audio Technica", "ATH-M40x Professional Monitor Headphones")
            brand("Sony", "Professional Line")
            brand("Sennheiser", "Professional Line")
            Text("Not Acceptable for Class")
                .font(.system(size: 28, weight: .black))
            brand("Beats by Dre", "Consumer-grade, colored sound profile not suitable for professional audio work")
            brand("Earbud-type headphones", "Insufficient audio isolation and frequency response for sound design")
            Text("Quick Shopping Checklist")
                .font(.headline)
            Text("Over-ear or on-ear headphones (~$100+ range)")
            Text("Wired connection (3.5mm jack or cord included)")
            Text("Professional/Studio monitoring brand (Audio Technica, Sony Pro, Sennheiser Pro)")
            Text("No Beats by Dre or earbud-type headphones")
            Text("Avoid Bluetooth-only headphones (lag issues)")
        }
    }

    private func tip(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.headline)
            Text(body).font(.subheadline).foregroundStyle(Color.stoneMuted)
        }
        .guideCard()
    }

    private func link(_ name: String, _ address: String) -> some View {
        Button(name) {
            if let url = URL(string: address) { openURL(url) }
        }
        .tint(Color.welcomeRed)
    }

    private func book(_ title: String, _ author: String, note: String? = nil) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.headline)
            Text("by \(author)").font(.subheadline).foregroundStyle(Color.stoneMuted)
            if let note {
                Text(note).font(.caption).foregroundStyle(Color.stoneMuted)
            }
        }
        .accessibilityIdentifier("book-\(title)")
    }

    private func brand(_ name: String, _ detail: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name).font(.headline)
            Text(detail).font(.subheadline).foregroundStyle(Color.stoneMuted)
        }
    }
}
