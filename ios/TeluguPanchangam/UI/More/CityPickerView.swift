import SwiftUI

private struct CityRegion: Identifiable {
    let region: String
    let cities: [City]

    var id: String { region }
}

/// Searchable list of the built-in cities, grouped by region.
struct CityPickerView: View {
    @Environment(\.ink) private var ink
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var settings: AppSettings

    @State private var query = ""

    private var regions: [CityRegion] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let matches = City.all.filter {
            q.isEmpty || $0.name.lowercased().contains(q) || $0.telugu.contains(q) || $0.region.lowercased().contains(q)
        }
        var order: [String] = []
        var byRegion: [String: [City]] = [:]
        for city in matches {
            if byRegion[city.region] == nil { order.append(city.region) }
            byRegion[city.region, default: []].append(city)
        }
        return order.map { CityRegion(region: $0, cities: byRegion[$0] ?? []) }
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundColor(ink.secondary)
                    TextField("వెతకండి · Search", text: $query)
                        .font(AppFont.bodyLarge)
                        .foregroundColor(ink.strong)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(ink.line, lineWidth: 1))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)

                ForEach(regions) { group in
                    Text(group.region.uppercased())
                        .font(AppFont.labelSmall)
                        .foregroundColor(ink.faint)
                        .padding(.leading, 20)
                        .padding(.top, 18)
                        .padding(.bottom, 4)
                    ForEach(Array(group.cities.enumerated()), id: \.element.id) { i, city in
                        if i > 0 { ThinDivider().padding(.leading, 20) }
                        Button {
                            settings.cityId = city.id
                            dismiss()
                        } label: {
                            CityRow(city: city, selected: city.id == settings.cityId)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .background(ink.page.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                TitleStack(title: "ప్రదేశం ఎంచుకోండి", caption: "Choose a city")
            }
        }
        .toolbarBackground(ink.page, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .tint(ink.strong)
    }
}

private struct CityRow: View {
    @Environment(\.ink) private var ink
    let city: City
    let selected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(city.telugu).font(AppFont.titleMedium).foregroundColor(ink.strong)
                Text(city.name).font(AppFont.bodySmall).foregroundColor(ink.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            if selected {
                Image(systemName: "checkmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(ink.strong)
                    .accessibilityLabel("Selected")
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }
}
