import Foundation

struct ServerResult: Codable {
    let html: String
    let javascript: String
}

actor ServerState {
    let content: String
    init(_ root: some Block) {
        self.content = "\(root)"
    }
    var connections: [String: Int] = [:]

    func update(_ id: String, _ input: String) -> String {
        // TODO handle logic from input
        let data = try? JSONEncoder().encode(
            ServerResult(html: body(increment(id)), javascript: serverJS))
        if data != nil {
            return String(data: data!, encoding: .utf8)!
        } else {
            return "server error"
        }
    }

    func view(_ id: String) -> String {
        var b = ""
        if connections[id] == nil {
            b = body(0)
        } else {
            b = body(connections[id]!)
        }
        let data = try? JSONEncoder().encode(
            ServerResult(html: b, javascript: serverJS))
        if data != nil {
            return String(data: data!, encoding: .utf8)!
        } else {
            return "server error"
        }
    }

    func increment(_ id: String) -> Int {
        if connections[id] == nil {
            connections[id] = 1
            return 1
        } else {
            let r = connections[id]! + 1
            connections[id] = r
            return r
        }
    }

    func body(_ count: Int = 0) -> String {
        if count <= 0 {
            return """
                <h1>WebSocket Stream</h1>
                <div class="button">Button</div>       
                <div>\(content)</div>
                """
        } else {
            return """
                <h1>WebSocket Stream</h1>
                <div class="button">Button count \(count)</div>     
                <div>\(content)</div>
                """
        }
    }

    var serverJS: String {
        """
        document.title = "Zane Enders"
        let btn = document.querySelector(".button")
        btn.addEventListener(`click`, function (e) {
            wsconnection.send(`Hello`)
        })
        """
    }
}
