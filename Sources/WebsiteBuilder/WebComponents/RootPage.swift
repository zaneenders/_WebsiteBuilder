public protocol RootPage: WebPage, HasURL, HasContent, HasSubPages {
    init()
}

extension RootPage {
    public static var url: String {
        "/"
    }
}
