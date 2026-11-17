import SwiftUI

struct ODayView: View {
    @Bindable var session: AppSession
    var client: APIClient = APIClient()

    @State private var schedules: [ODaySchedule] = []
    @State private var phase: LoadPhase = .loading

    private var upcoming: [ODaySchedule] {
        schedules.filter(\.upcoming)
    }

    private enum LoadPhase {
        case loading
        case ready
        case failed(String)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text("Orientation Day")
                    .font(.system(.largeTitle, design: .serif))
                    .foregroundStyle(Color.stoneInk)
                Text("Your first day at VFS. Get ready to meet your tribe and start your creative journey.")
                    .font(.body)
                    .foregroundStyle(Color.stoneLabel)

                switch phase {
                case .loading:
                    ProgressView()
                case .failed(let message):
                    Text(message)
                        .foregroundStyle(Color.stoneInk)
                case .ready:
                    if let next = upcoming.first {
                        nextTicket(next)
                    } else {
                        empty
                    }
                    if upcoming.count > 1 {
                        intakeList
                    }
                    glance
                    tips
                }
            }
            .padding(20)
        }
        .background(Color.stone)
        .navigationTitle("O-Day")
        .navigationBarTitleDisplayMode(.inline)
        .task { await load() }
    }

    private func nextTicket(_ next: ODaySchedule) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let days = WelcomeDates.daysUntil(next.orientationDate, now: .now) {
                Text(daysLabel(days))
                    .font(.system(size: 11, weight: .bold))
                    .tracking(1.2)
                    .foregroundStyle(Color.welcomeRed)
            }
            labeled("Orientation Date", WelcomeDates.longWeekday(next.orientationDate))
            labeled("Start Time", next.time)
            if let notes = next.notes, !notes.isEmpty {
                Text(notes)
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneLabel)
            }
            labeled("Location", next.place)
            if next.place != "TBD", let address = next.address, !address.isEmpty {
                Text(address)
                    .font(.subheadline)
                    .foregroundStyle(Color.stoneLabel)
            }
            Text("Program start: \(WelcomeDates.monthDayYear(next.startDate))")
                .font(.subheadline)
                .foregroundStyle(Color.welcomeRed)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Dates Coming Soon")
                .font(.system(.title3, design: .serif))
            Text("The next orientation schedule is being finalized. Check back soon!")
                .font(.subheadline)
                .foregroundStyle(Color.stoneLabel)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var intakeList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ALL INTAKE DATES")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Color.stoneLabel)
            ForEach(Array(upcoming.enumerated()), id: \.element.id) { index, schedule in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("O-Day")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.2)
                            .foregroundStyle(Color.stoneLabel)
                        Spacer()
                        if index == 0 {
                            Text("NEXT UP")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1.1)
                                .foregroundStyle(Color.welcomeRed)
                        }
                    }
                    Text(WelcomeDates.monthDay(schedule.orientationDate))
                        .font(.system(.title2, design: .serif))
                    Text("\(WelcomeDates.year(schedule.orientationDate)) · \(schedule.time)")
                        .font(.subheadline)
                        .foregroundStyle(Color.stoneLabel)
                    Text("Program starts \(WelcomeDates.monthDayYear(schedule.startDate))")
                        .font(.subheadline)
                    if let notes = schedule.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.footnote)
                            .foregroundStyle(Color.stoneLabel)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }

    private var glance: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Day at a Glance")
                .font(.system(.title3, design: .serif))
            glanceRow("Doors Open", "Arrive early. Doors open approximately 30 minutes before the official start. Grab a spot and start networking.")
            glanceRow("Check-In", "Register at the check-in desk and find your seat.")
            glanceRow("Welcome Presentation", "Introduction to VFS culture, safety protocols, and essential student services from leadership and your program team.")
        }
    }

    private var tips: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PRO TIPS")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.4)
                .foregroundStyle(Color.stoneLabel)
            tip("Introduce Yourself", "Your future classmates and collaborators are in the room. Say hello!")
            tip("Charge Up", "Full phone battery. You'll want to capture the moment and stay connected.")
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.stoneInk)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func labeled(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundStyle(Color.stoneLabel)
            Text(value)
                .font(.body)
                .foregroundStyle(Color.stoneInk)
        }
    }

    private func glanceRow(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(Color.stoneLabel)
        }
    }

    private func tip(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.white)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(Color.stoneLabel)
        }
    }

    private func daysLabel(_ days: Int) -> String {
        if days == 0 { return "TODAY IS O-DAY" }
        if days == 1 { return "1 DAY AWAY" }
        return "\(days) DAYS AWAY"
    }

    private func load() async {
        do {
            schedules = try await client.oday().schedules
            phase = .ready
        } catch APIError.unauthorized {
            session.signOut()
        } catch let error as APIError {
            phase = .failed(error.message)
        } catch {
            phase = .failed("O-Day could not be loaded.")
        }
    }
}

private extension APIError {
    var message: String {
        switch self {
        case .message(let message):
            return message
        case .unauthorized:
            return "Sign in again."
        }
    }
}

private extension WelcomeDates {
    static func year(_ ymd: String) -> String {
        String(ymd.prefix(4))
    }
}
