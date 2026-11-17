import Foundation

struct SupportResource: Identifiable, Equatable {
    var name: String
    var detail: String
    var phone: String?
    var phoneLabel: String?
    var secondPhone: String?
    var secondPhoneLabel: String?
    var site: String?
    var siteLabel: String?
    var hours: String?
    var note: String?
    var recommended = false
    var opensCoordinator = false
    var tag: String?

    var id: String { name }

    var phoneURL: URL? { SupportLinks.phone(phone) }
    var secondPhoneURL: URL? { SupportLinks.phone(secondPhone) }
    var siteURL: URL? { site.flatMap { URL(string: $0) } }
}

struct SupportSection: Identifiable, Equatable {
    var id: String
    var title: String
    var subtitle: String
    var resources: [SupportResource]
}

enum SupportLinks {
    static func phone(_ raw: String?) -> URL? {
        guard let raw else { return nil }
        let digits = raw.filter { $0.isNumber || $0 == "+" }
        guard !digits.isEmpty else { return nil }
        return URL(string: "tel:\(digits)")
    }
}

enum MentalHealthCatalog {
    static let intro = "A curated list of crisis lines, counselling services, and wellness tools available to you as a VFS student in Vancouver."
    static let startHere = "All resources listed are free or low-cost. If you're not sure where to start, Here2Talk is the best first step — it's free, confidential, and available 24/7 specifically for BC post-secondary students."
    static let crisisBanner = "If you or someone else is in immediate danger, call 911 first. For mental health crises, the fastest options are 988 (call or text) or 310-6789 (no area code needed)."
    static let disclaimerTitle = "A note on this page"
    static let disclaimer = "This resource list is maintained by VFS student services and is updated periodically. Phone numbers and hours can change — always verify on the service's official website if you're unsure. VFS is not affiliated with any external organization listed here. If you notice an outdated resource, please let your coordinator know."

    static let crisis = SupportSection(
        id: "crisis",
        title: "If You're in Crisis Right Now",
        subtitle: "Immediate support — call, text, or chat. Free and confidential.",
        resources: [
            SupportResource(
                name: "988 Suicide & Crisis Helpline",
                detail: "Canada's national suicide and crisis helpline. Call or text 988 — free, 24/7, available in English and French.",
                phone: "988",
                phoneLabel: "Call or Text 988",
                site: "https://988.ca",
                siteLabel: "988.ca",
                hours: "24/7"
            ),
            SupportResource(
                name: "BC Mental Health Support Line",
                detail: "Connects you to a BC crisis responder — no area code, no busy signal. Emotional support, mental health information, and referrals.",
                phone: "310-6789",
                phoneLabel: "Call 310-6789 (no area code)",
                site: "https://www.crisiscentre.bc.ca/get-support/crisis-lines/",
                siteLabel: "crisiscentre.bc.ca",
                hours: "24/7"
            ),
            SupportResource(
                name: "1-800-SUICIDE",
                detail: "BC-wide suicide prevention and intervention line. Also accessible as a distress line if you just need to talk.",
                phone: "1-800-784-2433",
                phoneLabel: "Call 1-800-784-2433",
                site: "https://www.crisiscentre.bc.ca/get-support/crisis-lines/",
                siteLabel: "crisiscentre.bc.ca",
                hours: "24/7"
            ),
            SupportResource(
                name: "Vancouver Distress Line",
                detail: "Greater Vancouver Coastal regional distress line. Also toll-free: 1-866-661-3311. TTY: 1-866-872-0113.",
                phone: "604-872-3311",
                phoneLabel: "Call 604-872-3311",
                site: "https://www.crisiscentre.bc.ca/get-support/crisis-lines/",
                siteLabel: "crisiscentre.bc.ca",
                hours: "24/7"
            ),
            SupportResource(
                name: "Crisis Centre — Online Chat",
                detail: "Chat live with a trained crisis responder. Youth can also use youthinbc.com.",
                site: "https://www.crisiscentrechat.ca",
                siteLabel: "crisiscentrechat.ca",
                hours: "Noon–1 AM daily"
            ),
            SupportResource(
                name: "Emergency Services",
                detail: "For any immediate threat to life — police, fire, or ambulance.",
                phone: "911",
                phoneLabel: "Call 911",
                hours: "24/7"
            ),
        ]
    )

    static let students = SupportSection(
        id: "students",
        title: "For VFS Students",
        subtitle: "Resources specifically available to you as a BC post-secondary student.",
        resources: [
            SupportResource(
                name: "Here2Talk",
                detail: "Free, confidential counselling for ALL BC post-secondary students — domestic and international. No appointment needed. Available by phone, online chat, or app.",
                phone: "1-877-857-3397",
                phoneLabel: "1-877-857-3397 (Toll-Free)",
                secondPhone: "604-642-5212",
                secondPhoneLabel: "604-642-5212 (Direct)",
                site: "https://here2talk.ca",
                siteLabel: "here2talk.ca",
                hours: "24/7 — Phone, Chat, App",
                note: "Free for all registered BC post-secondary students including VFS",
                recommended: true
            ),
            SupportResource(
                name: "Talk to Your Coordinator",
                detail: "Your VFS coordinator is your first point of contact for any personal or academic concerns. They can connect you with the right support.",
                siteLabel: "Contact Your Coordinator",
                hours: "Business hours",
                opensCoordinator: true
            ),
        ]
    )

    static let vancouver = SupportSection(
        id: "vancouver",
        title: "Professional Support in Vancouver",
        subtitle: "Local clinical services, health lines, and community referrals.",
        resources: [
            SupportResource(
                name: "VCH Mental Health Intake Line",
                detail: "Vancouver Coastal Health's single point of entry for mental health screening, assessment, and referrals to programs in the region.",
                phone: "604-675-3700",
                phoneLabel: "Call 604-675-3700",
                site: "https://www.vch.ca/en/health-topics/vancouver-mental-health-and-substance-use-services",
                siteLabel: "vch.ca",
                hours: "Daily 7:30 AM – 10 PM"
            ),
            SupportResource(
                name: "HealthLink BC",
                detail: "Speak to a registered nurse any time, day or night. Health advice, information, and referrals. Free. TTY: 7-1-1.",
                phone: "8-1-1",
                phoneLabel: "Call 8-1-1",
                site: "https://www.healthlinkbc.ca",
                siteLabel: "healthlinkbc.ca",
                hours: "24/7"
            ),
            SupportResource(
                name: "BC211 — Information & Referral",
                detail: "Connects you with community, social, and government services across BC. Great for finding the right resource — not a crisis line.",
                phone: "2-1-1",
                phoneLabel: "Dial or Text 2-1-1",
                site: "https://www.bc211.ca",
                siteLabel: "bc211.ca",
                hours: "24/7"
            ),
            SupportResource(
                name: "Vancouver Access & Assessment Centre (AAC)",
                detail: "Walk-in or call for non-life-threatening mental health or addiction concerns. Assessment, triage, and referrals for Vancouver residents aged 17+.",
                phone: "604-675-3700",
                phoneLabel: "Call 604-675-3700",
                site: "https://www.vch.ca/en/health-topics/vancouver-mental-health-and-substance-use-services",
                siteLabel: "vch.ca",
                hours: "Daily 7:30 AM – 11 PM"
            ),
            SupportResource(
                name: "BC Bereavement Helpline",
                detail: "Free grief-specific support for those dealing with loss. Trained volunteers and referrals to local bereavement groups. Also at 604-738-9950 (Vancouver).",
                phone: "1-877-779-2223",
                phoneLabel: "Call 1-877-779-2223",
                site: "https://bcbh.ca",
                siteLabel: "bcbh.ca",
                hours: "Mon–Fri 9 AM – 5 PM"
            ),
            SupportResource(
                name: "Seniors Distress Line",
                detail: "Support line for seniors and anyone concerned about an older adult facing crisis, loneliness, or distress.",
                phone: "604-872-1234",
                phoneLabel: "Call 604-872-1234",
                site: "https://www.crisiscentre.bc.ca/get-support/crisis-lines/",
                siteLabel: "crisiscentre.bc.ca",
                hours: "24/7"
            ),
        ]
    )

    static let apps = SupportSection(
        id: "apps",
        title: "Self-Help Apps & Online Tools",
        subtitle: "Free and evidence-based tools you can use anytime, on your own schedule.",
        resources: [
            SupportResource(name: "Here2Talk App", detail: "Free counselling app for BC post-secondary students. Connect instantly with a registered counsellor.", site: "https://here2talk.ca", siteLabel: "Download at here2talk.ca", tag: "Free · BC Students"),
            SupportResource(name: "MindShift CBT", detail: "Free app from Anxiety Canada using Cognitive Behavioural Therapy (CBT) to help manage anxiety, stress, panic, and worry. Made in Vancouver.", site: "https://mindshiftcbt.com", siteLabel: "mindshiftcbt.com", tag: "Free · Anxiety & Stress"),
            SupportResource(name: "Wellness Together Canada", detail: "Government-funded mental wellness and substance use support platform. Self-guided modules, peer support, and free counselling sessions.", site: "https://www.wellnesstogether.ca", siteLabel: "wellnesstogether.ca", tag: "Free · All Canadians"),
            SupportResource(name: "BounceBack", detail: "Free skill-building program for adults with mild-to-moderate anxiety or depression. Guided workbooks and phone coaching from CMHA BC.", site: "https://bouncebackbc.ca", siteLabel: "bouncebackbc.ca", tag: "Free · Anxiety & Depression"),
            SupportResource(name: "Headspace", detail: "Guided meditation, sleep, and mindfulness exercises. Proven to reduce stress. Free trial available; discounted for students.", site: "https://www.headspace.com", siteLabel: "headspace.com", tag: "Free Trial · Meditation"),
            SupportResource(name: "Woebot", detail: "AI-powered mental health chatbot using CBT and mindfulness techniques. Available anytime to help you check in and work through thoughts.", site: "https://woebothealth.com", siteLabel: "woebothealth.com", tag: "Free · CBT Chatbot"),
        ]
    )

    static let international = SupportSection(
        id: "international",
        title: "International Students",
        subtitle: "Multilingual and newcomer-specific support.",
        resources: [
            SupportResource(
                name: "S.U.C.C.E.S.S. Multilingual Helpline",
                detail: "Crisis and support in Mandarin, Cantonese, Korean, Farsi/Dari, and Ukrainian for BC residents.",
                phone: "1-888-721-0596 ext. 102",
                phoneLabel: "Call 1-888-721-0596",
                site: "https://www.successbc.ca",
                siteLabel: "successbc.ca",
                hours: "Business hours"
            ),
            SupportResource(
                name: "MOSAIC — Newcomer Support",
                detail: "Mental health and settlement support for immigrants and newcomers in Vancouver. Counselling, interpretation, and referrals.",
                phone: "604-254-9626",
                phoneLabel: "Call 604-254-9626",
                site: "https://www.mosaicbc.org",
                siteLabel: "mosaicbc.org",
                hours: "Business hours"
            ),
            SupportResource(
                name: "ISSBC — Immigrant Services Society",
                detail: "Comprehensive support for newcomers including mental health counselling, settlement, and integration services.",
                phone: "604-684-2561",
                phoneLabel: "Call 604-684-2561",
                site: "https://issbc.org",
                siteLabel: "issbc.org",
                hours: "Business hours"
            ),
            SupportResource(
                name: "Here2Talk (International Students)",
                detail: "Here2Talk is available globally — international students studying in BC can call from outside Canada.",
                phone: "+1-604-642-5212",
                phoneLabel: "Call from Abroad",
                site: "https://here2talk.ca",
                siteLabel: "here2talk.ca",
                hours: "24/7",
                note: "International calling charges may apply"
            ),
        ]
    )

    static let indigenous = SupportSection(
        id: "indigenous",
        title: "Indigenous Students",
        subtitle: "Culturally safe, Indigenous-led crisis and wellness support.",
        resources: [
            SupportResource(
                name: "KUU-US Indigenous Crisis Line",
                detail: "Culturally safe crisis support for Indigenous peoples across BC. Adults/Elders: 250-723-4050. Child/Youth: 250-723-2040. Métis Line: 1-833-638-4722. Text/Chat also available.",
                phone: "1-800-588-8717",
                phoneLabel: "Call Toll-Free 1-800-588-8717",
                site: "https://www.kuu-uscrisisline.com",
                siteLabel: "kuu-uscrisisline.com",
                hours: "24/7"
            ),
            SupportResource(
                name: "Hope for Wellness Help Line",
                detail: "National helpline offering immediate mental wellness counselling and crisis intervention for First Nations and Inuit people.",
                phone: "1-855-242-3310",
                phoneLabel: "Call 1-855-242-3310",
                site: "https://www.hopeforwellness.ca",
                siteLabel: "hopeforwellness.ca",
                hours: "24/7 — Phone & Chat"
            ),
        ]
    )

    static let lgbtq = SupportSection(
        id: "lgbtq",
        title: "2SLGBTQIA+ Support",
        subtitle: "Affirming, identity-safe resources and peer support.",
        resources: [
            SupportResource(
                name: "QMUNITY — 2SLGBTQIA+ Counselling",
                detail: "Free and low-cost ($60–$120) affirming counselling for 2SLGBTQIA+ and gender-diverse people. Up to 10 sessions. Join the waitlist online.",
                phone: "604-684-5307",
                phoneLabel: "Call 604-684-5307",
                site: "https://www.qmunity.ca/counselling",
                siteLabel: "qmunity.ca/counselling",
                hours: "Business hours — waitlist"
            ),
            SupportResource(
                name: "QChat — 2SLGBTQIA+ Peer Support",
                detail: "Free peer support line for 2SLGBTQIA+ youth across BC. Call, text, or chat online.",
                phone: "1-855-956-1777",
                phoneLabel: "Call 1-855-956-1777",
                site: "https://www.qchat.ca",
                siteLabel: "qchat.ca",
                hours: "Sat–Thu 6–9 PM",
                note: "Text: 250-800-9036"
            ),
            SupportResource(
                name: "Trans Lifeline Canada",
                detail: "A trans-led crisis hotline staffed entirely by trans people, for trans people. Peer support and community connection.",
                phone: "877-330-6366",
                phoneLabel: "Call 877-330-6366",
                site: "https://translifeline.org",
                siteLabel: "translifeline.org",
                hours: "Check website for hours"
            ),
            SupportResource(
                name: "The Trevor Project",
                detail: "Crisis support for LGBTQ+ young people. Call, text (START to 678-678), or chat online.",
                phone: "1-866-488-7386",
                phoneLabel: "Call 1-866-488-7386",
                site: "https://www.thetrevorproject.org",
                siteLabel: "thetrevorproject.org",
                hours: "24/7"
            ),
        ]
    )

    static let substance = SupportSection(
        id: "substance",
        title: "Substance Use Support",
        subtitle: "Non-judgmental support for you or someone you care about.",
        resources: [
            SupportResource(
                name: "BC Alcohol & Drug Information Referral Service",
                detail: "Free, confidential, multilingual information and referrals for any substance use concern — for yourself or someone you care about. Lower Mainland: 604-660-9382.",
                phone: "1-800-663-1441",
                phoneLabel: "Call 1-800-663-1441",
                site: "https://www.healthlinkbc.ca/mental-health-substance-use/resources/alcohol-drug-information-referral-service",
                siteLabel: "healthlinkbc.ca",
                hours: "24/7"
            ),
            SupportResource(
                name: "Wellness Together Canada",
                detail: "Free mental wellness and substance use support including self-guided programs, peer support, and counselling sessions.",
                site: "https://www.wellnesstogether.ca",
                siteLabel: "wellnesstogether.ca",
                hours: "24/7 online"
            ),
        ]
    )

    static let safety = SupportSection(
        id: "safety",
        title: "Sexual Violence & Safety",
        subtitle: "Confidential support for anyone impacted by violence or abuse.",
        resources: [
            SupportResource(
                name: "Salal Sexual Violence Support Centre",
                detail: "Free, confidential 24-hour crisis support for survivors of sexualized violence. Text/chat also available (604-245-2425). Toll-free: 1-877-392-7583.",
                phone: "604-255-6344",
                phoneLabel: "Call 604-255-6344",
                site: "https://www.salalsvsc.ca",
                siteLabel: "salalsvsc.ca",
                hours: "24/7"
            ),
            SupportResource(
                name: "Battered Women's Support Services",
                detail: "Free, confidential support for survivors of gender-based violence — safety planning, advocacy, counselling, and crisis intervention. Toll-free: 1-855-687-1868.",
                phone: "604-687-1867",
                phoneLabel: "Call 604-687-1867",
                site: "https://www.bwss.org",
                siteLabel: "bwss.org",
                hours: "24/7",
                note: "Text: 604-652-1867"
            ),
            SupportResource(
                name: "VictimLink BC",
                detail: "Confidential support and referrals for victims of crime and their immediate family members. Available in multiple languages. Call or text.",
                phone: "1-800-563-0808",
                phoneLabel: "Call or Text 1-800-563-0808",
                site: "https://www.victimlinkbc.ca",
                siteLabel: "victimlinkbc.ca",
                hours: "24/7"
            ),
        ]
    )

    static let sections = [crisis, students, vancouver, apps, international, indigenous, lgbtq, substance, safety]
}
