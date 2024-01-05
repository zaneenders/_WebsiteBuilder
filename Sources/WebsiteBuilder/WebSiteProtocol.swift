/*
We could surface sever settings and configurations here with sane defaults
already set.
*/

public struct ServerConfig {
    let domain: String
    let host: String
    let port: Int

    public init(_ domain: String, host: String = "::", port: Int = 8080) {
        self.domain = domain
        self.host = host
        self.port = port
    }
}
public protocol WebSite {
    var config: ServerConfig { get }
    var root: any RootPage { get }
    init()
}

extension WebSite {
    public static func main() async {
        await run()
    }

    static func run() async {
        do {
            let site = self.init()
            Routes.indexHome(site.root)
            //try await s.run()
            try await WSServer(
                domain: site.config.domain,
                host: site.config.host,
                port: site.config.port,
                eventLoopGroup: .singleton
            )
            .run()
        } catch {
            print("Server Error: \(error)")
        }
    }
}
