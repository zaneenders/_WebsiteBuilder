import Foundation

struct ServerResult: Codable {
    let html: String
    let javascript: String
}

actor ServerState {
    var connections: [String: Int] = [:]

    func update(_ id: String, _ input: String) -> String {
        // TODO handle logic from input
        let data = try? JSONEncoder().encode(ServerResult(html: body(increment(id)), javascript: btnHandler))
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
        let data = try? JSONEncoder().encode(ServerResult(html: b, javascript: btnHandler))
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
}

func body(_ count: Int = 0) -> String {
    if count <= 0 {
        return """
            <h1>WebSocket Stream</h1>
            <div class="button">Button</div>       
            """
    } else {
        return """
            <h1>WebSocket Stream</h1>
            <div class="button">Button count \(count)</div>     
            """
    }
}

 var btnHandler: String {
        """
        let btn = document.querySelector(".button")
        btn.addEventListener(`click`, function (e) {
            wsconnection.send(`Hello`)
        })
        """
    }

extension WSServer {

    private var msgHandler: String {
        // TODO replace eval with update()
        """
        wsconnection.onmessage = function (msg) {
            let body = document.querySelector("body")
            let result = JSON.parse(msg.data)
            body.innerHTML = result.html
            eval(result.javascript)
        }
        """
    }

    private var js: String {
        """
        \(msgHandler) 
        document.addEventListener("DOMContentLoaded", function(event){
            \(btnHandler)
        })
        """
    }
    private var styles: String {
        """
        * {
            background-color: black;
            color: white;
        }
        """
    }
    private var wsSocket: String {
        #if DEBUG
            return
                "var wsconnection = new WebSocket(`ws://[\(host)]:\(port)/websocket`)"
        #else
            return
                "var wsconnection = new WebSocket(`wss://\(domain)/websocket`)"
        #endif
    }

    var websocketResponse: String {
        """
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="utf-8">
            <title>Zane Enders</title>
            <style>
            \(styles)
            </style>
            <script>
            \(wsSocket)
            \(js)
            </script>
          </head>
          <body>
          \(body())
          </body>
        </html>
        """
    }
}
