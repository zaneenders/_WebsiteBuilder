import NIOCore
import NIOPosix

actor Server {
    /*
    TODO fix this race condition.
    Nothing bad is happening right now because the pages are computed once and
    never change but we should fix this error and either right the pages to
    disk or save the strings some where else?

    When doing this it might be time to refactor all of the NIO code and do a public release.

    Though a lot of these errors we might be stuck with till NIO updates its
    side.
    */
    private(set) static var pages: [RouteString: any HasContent] = [:]

    init(_ pages: [RouteString: any HasContent]) {
        Server.pages = pages
    }

    func run(_ host: String, _ port: Int) throws {
        // creates a thread pool for File IO
        let fileIO = NonBlockingFileIO(threadPool: .singleton)
        // Boot straps a thread pool for the actual server
        let socketBootstrap = ServerBootstrap(
            group: MultiThreadedEventLoopGroup.singleton
        )
        .serverChannelOption(ChannelOptions.backlog, value: 256)
        // do I need this twice?
        .serverChannelOption(
            ChannelOptions.socketOption(.so_reuseaddr), value: 1
        )

        // Difference between serverChannel and child Channel?
        .childChannelInitializer { channel in
            return channel.pipeline.configureHTTPServerPipeline(
                withErrorHandling: true
            )
            .flatMap {
                channel.pipeline.addHandler(HTTPHandler(fileIO))
            }
        }
        // do I need this twice?
        .childChannelOption(
            ChannelOptions.socketOption(.so_reuseaddr), value: 1
        )
        .childChannelOption(ChannelOptions.maxMessagesPerRead, value: 1)
        // What is this?
        .childChannelOption(ChannelOptions.allowRemoteHalfClosure, value: true)

        // Binds the configuration to the given host and port
        let channel: any Channel = try socketBootstrap.bind(
            host: host, port: port
        )
        .wait()

        print("Server started and listening on \(channel.localAddress!)")

        // Server is now running
        try channel.closeFuture.wait()
        // Maybe use the service package to shutdown the server properly?
        // https://github.com/swift-server/swift-service-lifecycle
        // Pretty sure im not closing down the server right as I have never
        // seen this print statement haha.
        print("Server closed")
    }
}
