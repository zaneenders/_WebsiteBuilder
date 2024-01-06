/*
We could surface sever settings and configurations here with sane defaults
already set.
*/

public protocol WebSite {
    var config: ServerConfig { get }
    var root: any Block { get }
    init()
}

extension WebSite {
    public static func main() async {
        do {
            let site = self.init()
            try await WSServer(
                block: site.root,
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
