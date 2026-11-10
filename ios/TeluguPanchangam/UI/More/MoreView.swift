import SwiftUI

/// Settings, methodology, sources and privacy.
struct MoreView: View {
    @Environment(\.ink) private var ink
    @EnvironmentObject private var settings: AppSettings

    private var versionName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("మరిన్ని").font(AppFont.headlineMedium).foregroundColor(ink.strong)
                    Text("Settings, method & sources").font(AppFont.bodySmall).foregroundColor(ink.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                SectionHeader("ప్రదేశం", "Location")
                NavigationLink(value: Route.cities) {
                    LocationCard(city: settings.city)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 16)

                SectionHeader("రూపం", "Appearance")
                AppearanceCard().padding(.horizontal, 16)

                SectionHeader("గణన విధానం", "How it is calculated")
                InfoCard(
                    title: "Computed on your phone, for your city",
                    text: "Tithi, nakshatra, yoga, karana, the lunar month, sunrise, sunset, moonrise and moonset are computed " +
                        "astronomically for the chosen city, for any date: Sun and Moon positions from Jean Meeus's " +
                        "Astronomical Algorithms, the Lahiri (Chitrapaksha) ayanamsa used by Indian national Panchangams, " +
                        "and amanta months with adhika-masa detection. Results were checked against the Swiss Ephemeris " +
                        "for every day of 2026–27: all transition times agree to about a minute."
                )
                InfoCard(
                    title: "Conventions",
                    text: "The day runs from sunrise to sunrise and is named by the tithi at sunrise. Sunrise is the upper " +
                        "limb on the horizon with standard refraction. Rahu Kalam, Yamagandam and Gulika divide daylight " +
                        "into eight parts by weekday; Abhijit is the 8th of 15 day muhurtas; Brahma Muhurtam is the 14th " +
                        "of 15 night muhurtas; Choghadiya divides day and night into eight each. Local almanacs may differ " +
                        "by a minute or two through their choice of sunrise definition."
                )
                InfoCard(
                    title: "Not included",
                    text: "Varjyam, Amrita Kalam and Durmuhurtam are not shown: their tables vary between almanacs and were not " +
                        "verified for this release. Mantra text and step-by-step ritual are withheld without a cited " +
                        "traditional source."
                )

                SectionHeader("పండుగ తేదీలు", "Festival dates")
                InfoCard(
                    title: "Where festival dates come from",
                    text: "Festival dates for Parabhava Samvatsara (\(FestivalData.ugadiStart.description) – " +
                        "\(FestivalData.nextUgadi.description)) are " +
                        "taken first from Sri Sringeri Sharada Peetham's own announcements, then from the Andhra Pradesh " +
                        "and Telangana government holiday orders, then from the Drik Panchang 2026 calendar — and each was " +
                        "re-checked against the computed tithi. Each festival shows its sources and a status: Verified, " +
                        "Varies by tradition, Computed, or Pending verification. Festival dates follow the Telugu-state " +
                        "observance; outside India, local temples may observe some festivals a day earlier or later."
                )
                ForEach(Array(FestivalData.allSources.enumerated()), id: \.offset) { _, source in
                    SourceReferenceCard(source: source)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                }

                SectionHeader("గోప్యత", "Privacy")
                InfoCard(
                    title: "Nothing leaves your phone",
                    text: "No account, no analytics, no network requests. Your city and display preferences are stored only on " +
                        "this device."
                )

                Text("Telugu Panchangam \(versionName) · ఈ యాప్ సమాచారం కోసం మాత్రమే — ముఖ్యమైన కార్యాలకు మీ పురోహితులను సంప్రదించండి.")
                    .font(AppFont.labelSmall)
                    .foregroundColor(ink.faint)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
            }
            .padding(.bottom, 40)
        }
        .background(ink.page.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct LocationCard: View {
    @Environment(\.ink) private var ink
    let city: City

    var body: some View {
        OutlinedBlock {
            HStack(alignment: .center, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(city.telugu).font(AppFont.titleMedium).foregroundColor(ink.strong)
                    Text("\(city.name), \(city.region) · \(city.zoneId)")
                        .font(AppFont.bodySmall)
                        .foregroundColor(ink.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .foregroundColor(ink.secondary)
                    .accessibilityLabel("Change city")
            }
        }
        .contentShape(Rectangle())
    }
}

private struct AppearanceCard: View {
    @Environment(\.ink) private var ink
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        OutlinedBlock(padding: 6) {
            ThemeRow(mode: .system, telugu: "సిస్టమ్ ప్రకారం", english: "Follow system")
            ThemeRow(mode: .light, telugu: "తెలుపు", english: "Light")
            ThemeRow(mode: .dark, telugu: "నలుపు", english: "Dark")
            ThinDivider().padding(.vertical, 4)
            Toggle(isOn: $settings.use24Hour) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("24 గంటల సమయం").font(AppFont.bodyLarge).foregroundColor(ink.strong)
                    Text("24-hour clock").font(AppFont.bodySmall).foregroundColor(ink.secondary)
                }
            }
            .tint(ink.isDark ? ink.faint : ink.strong)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
    }
}

private struct ThemeRow: View {
    @Environment(\.ink) private var ink
    @EnvironmentObject private var settings: AppSettings
    let mode: ThemeMode
    let telugu: String
    let english: String

    var body: some View {
        let selected = settings.theme == mode
        Button {
            settings.theme = mode
        } label: {
            HStack(spacing: 0) {
                Image(systemName: selected ? "largecircle.fill.circle" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(selected ? ink.strong : ink.faint)
                    .frame(width: 44, height: 44)
                Text(telugu).font(AppFont.bodyLarge).foregroundColor(ink.strong)
                Text("  \(english)").font(AppFont.bodySmall).foregroundColor(ink.secondary)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct InfoCard: View {
    @Environment(\.ink) private var ink
    let title: String
    let text: String

    var body: some View {
        OutlinedBlock {
            Text(title).font(AppFont.titleMedium).foregroundColor(ink.strong)
            Text(text).font(AppFont.bodyMedium).foregroundColor(ink.body).padding(.top, 6)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 10)
    }
}
