actor ServerState {
    var connections: [String: Int] = [:]

    func update(_ id: String, _ input: String) -> String {
        // TODO handle logic from input
        return body(increment(id))
    }

    func view(_ id: String) -> String {
        if connections[id] == nil {
            return body(0)
        } else {
            return body(connections[id]!)
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

extension WSServer {

    private var msgHandler: String {
        """
        wsconnection.onmessage = function (msg) {
            let body = document.querySelector("body")
            body.innerHTML = msg.data
            \(btnHandler)
        }
        """
    }

    private var btnHandler: String {
        """
        let btn = document.querySelector(".button")
        btn.addEventListener(`click`, function (e) {
            wsconnection.send(`Hello`)
        })
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
