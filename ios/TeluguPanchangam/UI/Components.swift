import SwiftUI

// MARK: - Containers

/// A section title: Telugu leading, English as a small caption beside it.
struct SectionHeader<Trailing: View>: View {
    @Environment(\.ink) private var ink
    let telugu: String
    let english: String
    let trailing: Trailing

    init(_ telugu: String, _ english: String, @ViewBuilder trailing: () -> Trailing) {
        self.telugu = telugu
        self.english = english
        self.trailing = trailing()
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: 0) {
            Text(telugu).font(AppFont.titleLarge).foregroundColor(ink.strong)
            Text("  " + english.uppercased())
                .font(AppFont.labelSmall)
                .tracking(0.4)
                .foregroundColor(ink.faint)
            Spacer(minLength: 0)
            trailing
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 10)
    }
}

extension SectionHeader where Trailing == EmptyView {
    init(_ telugu: String, _ english: String) {
        self.init(telugu, english) { EmptyView() }
    }
}

/// A hairline-bordered card — the main container style in the app.
struct OutlinedBlock<Content: View>: View {
    @Environment(\.ink) private var ink
    var padding: CGFloat = 16
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: content)
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ink.page)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(ink.line, lineWidth: 1))
    }
}

/// A filled, inverted card for the single most important block on a screen.
struct InvertedBlock<Content: View>: View {
    @Environment(\.ink) private var ink
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0, content: content)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ink.cardFill)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 24, style: .continuous).stroke(ink.cardRim, lineWidth: 1))
    }
}

struct ThinDivider: View {
    @Environment(\.ink) private var ink
    var body: some View {
        Rectangle().fill(ink.lineFaint).frame(height: 1).frame(maxWidth: .infinity)
    }
}

/// A small rounded tag. `filled` inverts it for emphasis.
struct Pill: View {
    @Environment(\.ink) private var ink
    let text: String
    var filled: Bool = false

    var body: some View {
        Text(text)
            .font(AppFont.labelSmall)
            .lineLimit(1)
            .foregroundColor(filled ? ink.page : ink.secondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .background(Capsule().fill(filled ? ink.strong : ink.page))
            .overlay(Capsule().stroke(filled ? ink.strong : ink.line, lineWidth: 1))
    }
}

/// A circle filled or hollow, used as a status / quality marker.
struct Dot: View {
    @Environment(\.ink) private var ink
    let size: CGFloat
    let fill: Color
    var rim: Color? = nil

    var body: some View {
        Circle()
            .fill(fill)
            .overlay(Circle().stroke(rim ?? .clear, lineWidth: 1))
            .frame(width: size, height: size)
    }
}

/// A Telugu title with its English caption underneath, used by detail screens.
struct TitleStack: View {
    @Environment(\.ink) private var ink
    let title: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title).font(AppFont.titleLarge).foregroundColor(ink.strong).lineLimit(1)
            Text(caption).font(AppFont.bodySmall).foregroundColor(ink.secondary).lineLimit(1)
        }
    }
}

// MARK: - Provenance

struct StatusBadge: View {
    let status: VerificationStatus
    var body: some View {
        Pill(text: status.englishLabel, filled: status == .verified)
    }
}

/// Renders a `SourceReference` with its verification status spelled out,
/// and a link when the source is online.
struct SourceReferenceCard: View {
    @Environment(\.ink) private var ink
    @Environment(\.openURL) private var openURL
    let source: SourceReference

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 8) {
                VStack(alignment: .leading, spacing: 0) {
                    if let publisher = source.publisher {
                        Text(publisher).font(AppFont.labelMedium).foregroundColor(ink.secondary)
                    }
                    Text(source.title).font(AppFont.titleSmall).foregroundColor(ink.strong)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                StatusBadge(status: source.status)
            }
            if let edition = source.edition {
                Text(edition).font(AppFont.bodySmall).foregroundColor(ink.secondary).padding(.top, 6)
            }
            if let notes = source.notes {
                Text(notes).font(AppFont.bodySmall).foregroundColor(ink.secondary).padding(.top, 6)
            }
            if let url = source.url {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 12))
                        .foregroundColor(ink.secondary)
                    Text(displayURL(url))
                        .font(AppFont.labelMedium)
                        .foregroundColor(ink.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .padding(.top, 8)
            }
        }
        .multilineTextAlignment(.leading)
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(ink.wash))
        .contentShape(Rectangle())
        .onTapGesture {
            if let s = source.url, let url = URL(string: s) { openURL(url) }
        }
    }

    private func displayURL(_ s: String) -> String {
        var out = s
        if out.hasPrefix("https://") { out.removeFirst("https://".count) }
        if out.hasPrefix("www.") { out.removeFirst("www.".count) }
        return out
    }
}

// MARK: - Moon phase

/// The Moon as seen from the northern hemisphere for a Moon−Sun
/// elongation in degrees (0 = new, 180 = full). Drawn in ink only.
struct MoonPhaseView: View {
    @Environment(\.ink) private var ink
    let elongation: Double
    let size: CGFloat
    var lit: Color? = nil
    var dark: Color? = nil
    var rim: Color? = nil

    var body: some View {
        let litColor = lit ?? ink.strong
        let darkColor = dark ?? ink.page
        let rimColor = rim ?? ink.disabled
        let e = (elongation.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        return Canvas { ctx, sz in
            let r = min(sz.width, sz.height) / 2
            let c = CGPoint(x: sz.width / 2, y: sz.height / 2)
            let waxing = e < 180
            let terminator = r * CGFloat(abs(cos(e * .pi / 180)))
            let gibbous = e >= 90 && e <= 270
            let disc = Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: 2 * r, height: 2 * r))

            ctx.fill(disc, with: .color(darkColor))
            var inner = ctx
            inner.clip(to: disc)
            // Waxing: the right half is lit; waning: the left half.
            let half = CGRect(x: waxing ? c.x : c.x - r, y: c.y - r, width: r, height: 2 * r)
            inner.fill(Path(half), with: .color(litColor))
            let oval = CGRect(x: c.x - terminator, y: c.y - r, width: 2 * terminator, height: 2 * r)
            inner.fill(Path(ellipseIn: oval), with: .color(gibbous ? litColor : darkColor))
            ctx.stroke(disc, with: .color(rimColor), lineWidth: 1)
        }
        .frame(width: size, height: size)
        .accessibilityHidden(true)
    }
}

// MARK: - Swipe paging

/// Adds a horizontal swipe that calls `onSwipe(-1)` for a swipe to the
/// right (previous) and `onSwipe(+1)` for a swipe to the left (next),
/// without stealing vertical scrolling.
struct HorizontalSwipe: ViewModifier {
    let onSwipe: (Int) -> Void

    func body(content: Content) -> some View {
        content.simultaneousGesture(
            DragGesture(minimumDistance: 24, coordinateSpace: .local)
                .onEnded { value in
                    let dx = value.translation.width
                    let dy = value.translation.height
                    guard abs(dx) > 60, abs(dx) > abs(dy) * 1.5 else { return }
                    onSwipe(dx < 0 ? 1 : -1)
                }
        )
    }
}

extension View {
    func horizontalSwipe(_ onSwipe: @escaping (Int) -> Void) -> some View {
        modifier(HorizontalSwipe(onSwipe: onSwipe))
    }
}

/// Slide transition whose direction follows the paging direction.
func pageTransition(forward: Bool) -> AnyTransition {
    .asymmetric(
        insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
        removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity)
    )
}
