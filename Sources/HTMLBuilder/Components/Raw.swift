@available(*, deprecated, message: "This is temporary Type hole!")
public struct RawHTML: BodyComponent {

    let rawHtml: String

    public var html: String {
        rawHtml
    }

    public init(_ rawHtml: String) {
        self.rawHtml = rawHtml
    }
}
