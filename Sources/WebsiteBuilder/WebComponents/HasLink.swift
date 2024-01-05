public protocol HasURL {
    static var url: String { get }
}

public func makeLink(_ page: any HasURL.Type) -> String {
    aTag("\(page.self)", to: page.url)
}

public func makeLinks(_ pages: [any HasURL.Type]) -> [String] {
    pages.map({ makeLink($0) })
}
