public struct ListItem {
    let contents: String

    public var html: String {
        "<li>\(contents)</li>"
    }

    public init(_ contents: String) {
        self.contents = contents
    }
}
