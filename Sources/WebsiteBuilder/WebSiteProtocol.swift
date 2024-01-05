/*
We could surface sever settings and configurations here with sane defaults
already set.
*/
public protocol WebSite {
    var root: any RootPage { get }
    init()
}

extension WebSite {
    public static func main() async {
        setup()
        await run()
    }

    static func setup() {
        let ws = self.init()
        Routes.indexHome(ws.root)
    }

    static func run() async {
        let s = Server(Routes.pages)
        do {
            let host = "::"
            let port = 8080
            //try await s.run()
            try await WSServer(
                host: host,
                port: port,
                eventLoopGroup: .singleton
            )
            .run()
        } catch {
            print("Server Error: \(error)")
        }
    }
}
