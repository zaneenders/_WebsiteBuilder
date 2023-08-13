enum Style {
    var id: Int {
        switch self {
        case .background(_):
            return 0
        case .alignment(_):
            return 1
        case .foreground(_):
            return 2
        }
    }
    case background(Color)
    case foreground(Color)
    case alignment(Alignment)
}

extension Style: Hashable, Comparable {
    static func == (lhs: Style, rhs: Style) -> Bool {
        let eq: Bool
        switch (lhs, rhs) {
        case let (.alignment(l), .alignment(r)):
            eq = l == r
        case let (.foreground(l), .foreground(r)):
            eq = l == r
        case let (.background(l), .background(r)):
            eq = l == r
        case (.background(_), .foreground(_)):
            eq = false
        case (.background(_), .alignment(_)):
            eq = false
        case (.foreground(_), .background(_)):
            eq = false
        case (.foreground(_), .alignment(_)):
            eq = false
        case (.alignment(_), .background(_)):
            eq = false
        case (.alignment(_), .foreground(_)):
            eq = false
        }
        return lhs.id == rhs.id && eq
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
