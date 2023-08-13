public protocol WebsiteProtocol {
    var name: String { get }
    @WebsiteBuilder var pages: [Page] { get }

    init()
}

struct Website {
    // TODO This should be a tree of Pages to reflect how websites are actually
    // structured. To do this add some nested structure to the WebsiteBuilder
    let pages: [Page]
    let name: String

    init(name: String, _ pages: [Page]) {
        self.name = name
        self.pages = pages
    }
}

extension WebsiteProtocol {
    public static func main() async throws {
        let website = self.init()
        #if os(Linux)
            let server = Server(
                severing: Website(name: website.name, website.pages),
                logging: false)
            await server.start(at: "0.0.0.0", on: 8080)
        #else
            print("only linux supported right now")
        #endif
    }
}
