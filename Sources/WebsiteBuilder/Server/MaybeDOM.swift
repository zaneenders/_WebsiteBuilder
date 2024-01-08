import Foundation

func textDiv(_ text: Text) -> DivInfo {
    let buttonID = "\(UUID())"
    func rebuild(_ txt: String) -> String {
        return "<div id=\(buttonID)>\(txt)</div>"
    }
    return DivInfo(id: buttonID, rebuild: rebuild)
}

enum ElementType {
    case div
    case btn
}

protocol HTMLElement {
    var type: ElementType { get }
    var id: String { get }
}

struct DivInfo: HTMLElement {
    let type: ElementType = .div
    let id: String
    let rebuild: (String) -> String
}

struct ButtonInfo: HTMLElement {
    let type: ElementType = .btn
    let id: String
    let rebuild: (String) -> String
    let action: () -> Void
}

func setupButton(_ btn: Button) -> ButtonInfo {
    let buttonID = "\(UUID())"
    func buildDiv(_ label: String) -> String {
        return """
            <div id=\(buttonID) class="button" >\(label)</div>
            """
    }
    return ButtonInfo(id: buttonID, rebuild: buildDiv, action: btn.action)
}
