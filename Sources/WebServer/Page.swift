import HTMLBuilder

/// Declare a web Page
public struct Page {
    let html: HTML
    let fileName: String

    public init(_ fileName: String, _ html: HTML) {
        self.fileName = fileName
        self.html = html
    }
}

extension Page: CustomStringConvertible {
    public var description: String {
        self.html.description
    }
}
