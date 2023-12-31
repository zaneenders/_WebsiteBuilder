struct JSPage: HasContent, HasURL {
    static let url: String = "/script.js"

    var contents: String = jsFileContents(true)

    private static func jsFileContents(_ basic: Bool = true) -> String {
        if basic {
            return """
                console.log("Follow the Types Luke")
                """
        } else {
            // TODO Web Sockets
            return """
                const socket = new WebSocket(`wss://${window.location.host}/messages`, null);
                socket.onopen = function (e) {
                    console.log("[open] Connection established")
                    console.log("Sending to server")
                }
                socket.onmessage = function (event) {
                    console.log(`[message] ${event.data}`)
                    btn.innerHTML = `Button ${event.data}`
                }
                socket.onclose = function (event) {
                    if (event.wasClean) {
                        console.log(`[close] Connection closed cleanly, code=${event.code} reason=${event.reason}`)
                    } else {
                        // server process killed or network down
                        console.log(`[close] Connection died ${event.code}`)
                    }
                }
                socket.onerror = function (error) {
                    console.log(`[error]`)
                }
                console.log("Socket setup")

                console.log("on click handlers")
                const btn = document.querySelector("#button")
                btn.addEventListener(`click`, function (e) {
                    socket.send(`click`)
                })
                """
        }
    }
}
