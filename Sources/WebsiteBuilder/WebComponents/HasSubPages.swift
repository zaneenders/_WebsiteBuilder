public protocol HasSubPages {
    @SubPageBuilder var subPages: [any WebPage.Type] { get }
}

extension HasSubPages {
    public var subPages: [any WebPage.Type] {
        let empty: [any WebPage.Type] = []
        return empty
    }
}
