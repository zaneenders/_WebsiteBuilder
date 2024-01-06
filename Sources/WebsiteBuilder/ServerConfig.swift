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
