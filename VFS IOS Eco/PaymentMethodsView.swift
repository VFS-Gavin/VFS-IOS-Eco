import SwiftUI

enum PaymentCatalog {
    static let provinces: [(name: String, url: String)] = [
        ("Alberta", "http://studentaid.alberta.ca/"),
        ("British Columbia", "https://studentaidbc.ca/apply"),
        ("Manitoba", "http://www.gov.mb.ca/educate/sfa/pages/sfaFrontDoor_en.html"),
        ("New Brunswick", "http://www.studentaid.gnb.ca/"),
        ("Newfoundland and Labrador", "https://www.gov.nl.ca/education/studentaid"),
        ("Northwest Territories", "https://www.ece.gov.nt.ca/en/services/student-financial-assistance"),
        ("Nova Scotia", "http://www.studentloans.ednet.ns.ca/"),
        ("Nunavut", "https://www.gov.nu.ca/en/education-and-schools/financial-assistance-nunavut-students-fans"),
        ("Ontario", "http://osap.gov.on.ca/"),
        ("Prince Edward Island", "https://www.princeedwardisland.ca/en/topic/student-loans-bursaries-grants-and-awards"),
        ("Quebec", "http://www.afe.gouv.qc.ca/en/index.asp"),
        ("Saskatchewan", "http://www.saskatchewan.ca/residents/education-and-learning/student-loans"),
        ("Yukon", "https://yukon.ca/en/education-and-schools/financial-support-for-students"),
    ]

    static let preauthForm = "https://vfs.edu/sites/vfs.edu/files/vfs_pre-authorization-form_05142024.pdf"
    static let receivables = "receivables@vfs.com"
    static let reception = "+1 604-685-5808"
    static let swift = "BOFMCAM2"
    static let accountNumber = "1823-417"
    static let transit = "00040"
    static let institution = "001"
    static let cardFee = "3.5% convenience fee applies to all credit card payments."
}

struct PaymentMethodsView: View {
    @Environment(\.openURL) private var openURL
    @State private var tab: Tab = .domestic
    @State private var showProvinces = false

    private enum Tab: String, CaseIterable, Identifiable {
        case domestic = "Domestic"
        case international = "International"
        case financial = "Financial Aid"
        var id: String { rawValue }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GuideHero(
                    lead: "Payment",
                    accent: "Methods",
                    accentColor: .pageEmerald,
                    detail: "Secure, flexible options to manage your education investment. Choose the method that works best for you."
                )

                GuidePills(options: Array(Tab.allCases), title: { $0.rawValue }, selection: $tab)
                    .accessibilityIdentifier("payment-tabs")

                switch tab {
                case .domestic:
                    domestic
                case .international:
                    international
                case .financial:
                    financial
                }
            }
            .padding(20)
        }
        .deskPage(tint: .pageEmerald)
        .navigationTitle("Payment Methods")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var domestic: some View {
        VStack(alignment: .leading, spacing: 16) {
            card("Online Banking") {
                Text("This payment method is only available for students with a Canadian bank account. Students can transfer funds to Vancouver Film School by setting up one-time or automatic monthly online bill payments.")
                Text("How to set up online banking:").font(.subheadline.weight(.semibold))
                Text("1. Sign in to your online banking account")
                Text("2. Add \"Vancouver Film School\" as a payee (sometimes will show up as \"Vancouver Film School Ltd.\")")
                Text("3. Enter your 5-digit student ID number as your account number (found on your student ID or at the top of your invoice)")
                note("If you have difficulty adding Vancouver Film School to your bill payments, please contact your bank directly for assistance.")
            }
            card("Interac e-Transfer") {
                labeled("Send To", PaymentCatalog.receivables)
                Text("Send your payment to \(PaymentCatalog.receivables) and include your full name and 5-digit student ID number.")
                Text("Limits are based on the cardholder's policy. You can notify us by email if you need to split your payment.")
                    .italic()
            }
            creditCard
        }
    }

    private var international: some View {
        VStack(alignment: .leading, spacing: 16) {
            card("Pay with Flywire") {
                Text("Recommended Method").font(.caption.weight(.bold)).foregroundStyle(Color.welcomeRed)
                Text("VFS has partnered with Flywire to provide an easy, secure method for international payments. Track your transfer in real-time and save on bank fees.")
                Text("Best Price Guarantee")
                Text("Track payments online")
                Text("24/7 multilingual support")
                Text("Local payment options")
                open("Make a Payment", "https://www.flywire.com/pay/vfs")
                open("How to Pay Video", "https://youtu.be/NMFMrYkAaAc")
            }
            card("Flywire Customer Support") {
                Text("Available 24/7 via live chat, email, or phone")
                open("support@flywire.com", "mailto:support@flywire.com")
                open("Help Center", "https://help.flywire.com")
            }
            card("Wire Transfer") {
                Text("Direct bank transfer to VFS account").foregroundStyle(Color.stoneMuted)
                labeled("Bank Name", "Bank of Montreal (BMO)")
                labeled("Bank Address", "595 Burrard Street, Vancouver, BC V7X 1L7, Canada")
                labeled("Swift Code", PaymentCatalog.swift)
                labeled("Account Name", "Vancouver Film School Limited")
                labeled("Account Address", "200 - 198 West Hastings Street, Vancouver, BC V6B 1H2, Canada")
                labeled("Account #", PaymentCatalog.accountNumber)
                labeled("Transit #", PaymentCatalog.transit)
                labeled("FI", PaymentCatalog.institution)
                note("Please provide the student's name, program name, and program start date in the wire instructions. An additional processing fee of up to $35 will be charged by BMO for all wire transactions. Your bank may also charge an additional processing fee.")
            }
            creditCard
        }
    }

    private var financial: some View {
        VStack(alignment: .leading, spacing: 16) {
            card("For Canadian Citizens, Permanent Residents, or Protected Persons") {
                Text("Canada and Provincial Student Loans").font(.headline)
                Text("Available to Canadian citizens, Permanent Residents, or Protected Persons enrolled in a full-time program at VFS. Funding is based on tuition, fees, books, supplies, living expenses, income and available resources.")
                open("General Information: Canada Student Loans", "https://www.canada.ca/en/services/benefits/education/student-aid.html")
                Button(showProvinces ? "Hide provinces" : "Apply by Province or Territory") {
                    showProvinces.toggle()
                }
                .tint(Color.welcomeRed)
                .accessibilityIdentifier("payment-provinces")
                if showProvinces {
                    ForEach(PaymentCatalog.provinces, id: \.name) { province in
                        open(province.name, province.url)
                    }
                }
                Text("Lifelong Learning Plan (LLP)").font(.headline)
                Text("Allows Canadian residents to withdraw up to $10,000/year (max $20,000) from RRSPs without penalty to fund education. You have up to 10 years to repay.")
                open("Detailed Info", "https://www.canada.ca/en/revenue-agency/services/tax/individuals/topics/rrsps-related-plans/lifelong-learning-plan.html")
                open("Withdrawal Form", "https://www.canada.ca/en/revenue-agency/services/forms-publications/forms/rc96.html")
                Text("Registered Education Savings Plan (RESP)").font(.headline)
                Text("A tax-deferred savings vehicle for post-secondary education. Contributions may be eligible for Canada Education Savings Grant (CESG). Your RESP provider will require an enrollment letter from VFS. Your Admissions Advisor can help with these documents.")
                open("Detailed Info", "https://www.canada.ca/en/revenue-agency/services/tax/individuals/topics/registered-education-savings-plans-resps.html")
                Text("Student Lines of Credit").font(.headline)
                Text("A great option when other financial aid is not enough. Take money out only as you need it and pay interest only on what you withdraw while in school. Co-signer with good credit usually required.")
                Text("Bank of Montreal (595 Burrard Street, Vancouver, BC): Credit limit based on need and ability to repay. Co-signer required in most cases.")
                open("BMO Student Line of Credit", "https://www.bmo.com/main/personal/loans-line-of-credit/student-line-of-credit/")
                open("TD", "https://www.td.com/ca/en/personal-banking/products/borrowing/lines-of-credit/student-line-of-credit")
                open("CIBC", "https://www.cibc.com/en/personal-banking/loans-and-lines-of-credit/lines-of-credit/education-line-of-credit.html")
                open("RBC", "https://www.rbc.com/personal-banking/loans/student-line-of-credit/")
                Text("Windmill Microloans for Landed Immigrants").font(.headline)
                Text("Windmill offers affordable loans of up to $15,000 to help foreign-trained immigrants and refugees pay for the costs of Canadian accreditation, training and career development. No co-signer required.")
                open("Windmill Microlending", "https://windmillmicrolending.org/")
            }
            card("For US Students") {
                Text("Sallie Mae Loans").font(.headline)
                Text("Smart Option Student Loan. Cosigner can help qualify for better rates and can be released after 12 on-time payments.")
                open("Apply at Sallie Mae", "https://www.salliemae.com/student-loans/smart-option-student-loan/")
                Text("529 Plans").font(.headline)
                Text("Can be used for VFS tuition. Note: May be considered non-qualified withdrawal with tax penalties. Contact your plan administrator.")
                Text("Some students also use home equity lines of credit or 401k loans. Contact your financial institution for details.")
            }
            card("For International Students") {
                Text("Swedish CSN").font(.headline)
                Text("Student grants and loans for Swedish nationals studying abroad.")
                open("Apply at CSN", "https://www.csn.se/languages/english.html")
                Text("Icelandic LÍN").font(.headline)
                Text("Icelandic Student Loan Fund for nationals studying outside Iceland.")
                open("Apply at LÍN", "https://www.lin.is/english/")
                Text("Other Countries: Contact your government's post-secondary education agency or financial institutions to explore loan options from your home country. Your Admissions Advisor can help with VFS payment plans.")
            }
            note("The financial options listed have no affiliation with VFS and are for information only. Please read the full terms of any contract before signing. VFS is not responsible for third-party service terms.")
        }
    }

    private var creditCard: some View {
        card("Credit Card") {
            Text("2 options available").foregroundStyle(Color.stoneMuted)
            Text("Option 1").font(.headline)
            Text("Complete and email the CC Pre-Authorization Form to set up automatic payments")
            open("Download Form", PaymentCatalog.preauthForm)
            open("Email Form to Admissions", "mailto:admissions@vfs.com?subject=Credit%20Card%20Pre-Authorization%20Form")
            Text("Option 2").font(.headline)
            Text("Pay by phone")
            labeled("Call Reception", PaymentCatalog.reception)
            Text("Press 3 after calling")
            if let url = SupportLinks.phone(PaymentCatalog.reception) {
                Button(PaymentCatalog.reception) { openURL(url) }
                    .tint(Color.welcomeRed)
            }
            note(PaymentCatalog.cardFee)
        }
    }

    private func card(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .black))
                .foregroundStyle(Color.stoneInk)
            content()
                .font(.subheadline)
                .foregroundStyle(Color.stoneMuted)
        }
        .guideCard()
    }

    private func labeled(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.1)
                .foregroundStyle(Color.stoneMuted)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.stoneInk)
        }
    }

    private func note(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(Color.stoneInk)
    }

    private func open(_ title: String, _ address: String) -> some View {
        Button(title) {
            if let url = URL(string: address) { openURL(url) }
        }
        .font(.subheadline.weight(.semibold))
        .tint(Color.welcomeRed)
    }
}
