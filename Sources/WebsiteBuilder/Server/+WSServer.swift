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
        """
        // TODO handle disconnect state
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
            <title>\(domain)</title>
            <style>
            \(styles)
            </style>
            <script>
            \(wsSocket)
            \(js)
            </script>
          </head>
          <body>
          </body>
        </html>
        """
    }
}
