public enum Color {
    case blue
    case red
    case green
    case yellow
    case hex(String)
}

extension Color: Comparable {
    var id: Int {
        switch self {
        case .blue:
            return 0
        case .green:
            return 0
        case .red:
            return 0
        case .yellow:
            return 0
        case .hex(let v):
            if v.count == 3 {
                guard let n = Int(v.dropFirst(3), radix: 16) else {
                    return 0
                }
                return n
            } else if v.count == 6 {
                guard let n = Int(v.dropFirst(6), radix: 16) else {
                    return 0
                }
                return n
            } else {
                return 0
            }
        }
    }
}

extension Color: CustomStringConvertible {
    public var description: String {
        switch self {
        case .blue:
            return "blue"
        case .green:
            return "green"
        case .red:
            return "red"
        case .yellow:
            return "yellow"
        case .hex(let v):
            return "#\(v)"
        }
    }
}
