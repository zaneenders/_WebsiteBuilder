//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
// TODO replace Apple's code
import NIOCore
import NIOHTTP1
import NIOPosix
import NIOWebSocket

actor ServerState {
    var connections: [String: Int] = [:]

    func update(_ id: String, _ input: String) -> String {
        // TODO handle logic from input
        "Button Count \(increment(id))"
    }

    func view(_ id: String) -> String {
        if connections[id] == nil {
            return "Button"
        } else {
            return "Button Count \(connections[id]!)"
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

extension WSServer {

    private var msgHandler: String {
        """
        wsconnection.onmessage = function (msg) {
            console.log(msg.data)
            let btn = document.querySelector(".button")
            btn.innerHTML = msg.data
        }
        """
    }

    private var btnHandler: String {
        """
        btn.addEventListener(`click`, function (e) {
            wsconnection.send(`Hello`)
        })
        """
    }

    private var js: String {
        """
        var wsconnection = new WebSocket("ws://[\(host)]:\(port)/websocket")
        \(msgHandler) 
        document.addEventListener("DOMContentLoaded", function(event){
            const btn = document.querySelector(".button")
            \(btnHandler)
        })
        """
    }

    private var body: String {
        """
        <h1>WebSocket Stream</h1>
        <div class="button">Button</div>       
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
    private var websocketResponse: String {
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
            \(js)
            </script>
          </head>
          <body>
          \(body)
          </body>
        </html>
        """
    }
}

struct WSServer {

    let storage = ServerState()

    public init(
        host: String, port: Int, eventLoopGroup: MultiThreadedEventLoopGroup
    ) {
        self.host = host
        self.port = port
        self.eventLoopGroup = eventLoopGroup
    }

    private let host: String
    private let port: Int
    private let eventLoopGroup: MultiThreadedEventLoopGroup

    enum UpgradeResult {
        case websocket(NIOAsyncChannel<WebSocketFrame, WebSocketFrame>)
        case notUpgraded(
            NIOAsyncChannel<
                HTTPServerRequestPart,
                HTTPPart<HTTPResponseHead, ByteBuffer>
            >)
    }

    /// This method starts the server and handles incoming connections.
    func run() async throws {
        let channel: NIOAsyncChannel<EventLoopFuture<UpgradeResult>, Never> =
            try await ServerBootstrap(group: self.eventLoopGroup)
            .serverChannelOption(
                ChannelOptions.socketOption(.so_reuseaddr), value: 1
            )
            .bind(host: self.host, port: self.port) { channel in
                channel.eventLoop.makeCompletedFuture {
                    let upgrader = NIOTypedWebSocketServerUpgrader<
                        UpgradeResult
                    >(
                        shouldUpgrade: { (channel, head) in
                            channel.eventLoop.makeSucceededFuture(
                                HTTPHeaders())
                        },
                        upgradePipelineHandler: { (channel, _) in
                            channel.eventLoop.makeCompletedFuture {
                                let asyncChannel = try NIOAsyncChannel<
                                    WebSocketFrame, WebSocketFrame
                                >(wrappingChannelSynchronously: channel)
                                return UpgradeResult.websocket(
                                    asyncChannel)
                            }
                        }
                    )

                    let serverUpgradeConfiguration =
                        NIOTypedHTTPServerUpgradeConfiguration(
                            upgraders: [upgrader],
                            notUpgradingCompletionHandler: { channel in
                                channel.eventLoop.makeCompletedFuture {
                                    try channel.pipeline.syncOperations
                                        .addHandler(
                                            HTTPByteBufferResponsePartHandler()
                                        )
                                    let asyncChannel = try NIOAsyncChannel<
                                        HTTPServerRequestPart,
                                        HTTPPart<
                                            HTTPResponseHead,
                                            ByteBuffer
                                        >
                                    >(
                                        wrappingChannelSynchronously:
                                            channel)
                                    return UpgradeResult.notUpgraded(
                                        asyncChannel)
                                }
                            }
                        )

                    let negotiationResultFuture = try channel.pipeline
                        .syncOperations
                        .configureUpgradableHTTPServerPipeline(
                            configuration: .init(
                                upgradeConfiguration:
                                    serverUpgradeConfiguration)
                        )

                    return negotiationResultFuture
                }
            }

        // We are handling each incoming connection in a separate child task. It is important
        // to use a discarding task group here which automatically discards finished child tasks.
        // A normal task group retains all child tasks and their outputs in memory until they are
        // consumed by iterating the group or by exiting the group. Since, we are never consuming
        // the results of the group we need the group to automatically discard them; otherwise, this
        // would result in a memory leak over time.
        try await withThrowingDiscardingTaskGroup { group in
            try await channel.executeThenClose { inbound in
                for try await upgradeResult in inbound {
                    group.addTask {
                        await self.handleUpgradeResult(upgradeResult)
                    }
                }
            }
        }
    }

    /// This method handles a single connection by echoing back all inbound data.
    private func handleUpgradeResult(
        _ upgradeResult: EventLoopFuture<UpgradeResult>
    ) async {
        // Note that this method is non-throwing and we are catching any error.
        // We do this since we don't want to tear down the whole server when a single connection
        // encounters an error.
        do {
            switch try await upgradeResult.get() {
            case .websocket(let websocketChannel):
                print("Handling websocket connection")
                try await self.handleWebsocketChannel(websocketChannel)
                print("Done handling websocket connection")
            case .notUpgraded(let httpChannel):
                print("Handling HTTP connection")
                try await self.handleHTTPChannel(httpChannel)
                print("Done handling HTTP connection")
            }
        } catch {
            print("Hit error: \(error)")
        }
    }

    private func handleWebsocketChannel(
        _ channel: NIOAsyncChannel<WebSocketFrame, WebSocketFrame>
    ) async throws {
        let id = "\(channel.channel.remoteAddress!)"
        try await channel.executeThenClose { inbound, outbound in
            try await withThrowingTaskGroup(of: Void.self) { group in
                group.addTask {
                    for try await frame in inbound {
                        switch frame.opcode {
                        case .ping:
                            print("Received ping")
                            var frameData = frame.data
                            let maskingKey = frame.maskKey

                            if let maskingKey = maskingKey {
                                frameData.webSocketUnmask(maskingKey)
                            }

                            let responseFrame = WebSocketFrame(
                                fin: true, opcode: .pong, data: frameData)
                            try await outbound.write(responseFrame)

                        case .connectionClose:
                            // This is an unsolicited close. We're going to send a response frame and
                            // then, when we've sent it, close up shop. We should send back the close code the remote
                            // peer sent us, unless they didn't send one at all.
                            print("Received close")
                            var data = frame.unmaskedData
                            let closeDataCode =
                                data.readSlice(length: 2) ?? ByteBuffer()
                            let closeFrame = WebSocketFrame(
                                fin: true, opcode: .connectionClose,
                                data: closeDataCode)
                            try await outbound.write(closeFrame)
                            return
                        case .binary, .continuation, .pong:
                            // We ignore these frames.
                            break
                        case .text:
                            let input = frame.unmaskedData.getString(
                                at: 0, length: frame.data.readableBytes)
                            guard input != nil else {
                                print("un able to read input for: \(id)")
                                return
                            }
                            let response = await storage.update(id, input!)
                            let buffer = channel.channel.allocator.buffer(
                                string: response)  // rspString size
                            let frame = WebSocketFrame(
                                fin: true, opcode: .text, data: buffer)
                            try await outbound.write(frame)
                            break  // keep connection alive
                        default:
                            // Unknown frames are errors.
                            return
                        }
                    }
                }

                group.addTask {
                    // TODO not really sure what to do here but this sorta acts as our heartbeat

                    // This is our main business logic where we are just sending the current time
                    // every second.
                    while true {
                        // We can't really check for error here, but it's also not the purpose of the
                        // example so let's not worry about it.
                        let response = await storage.view(id)
                        let buffer = channel.channel.allocator.buffer(
                            string: response)
                        let frame = WebSocketFrame(
                            fin: true, opcode: .text, data: buffer)
                        try await outbound.write(frame)
                        try await Task.sleep(for: .seconds(1))
                    }
                }

                // What does .next() do?
                try await group.next()
                group.cancelAll()
            }
        }
    }

    private func handleHTTPChannel(
        _ channel: NIOAsyncChannel<
            HTTPServerRequestPart, HTTPPart<HTTPResponseHead, ByteBuffer>
        >
    ) async throws {
        try await channel.executeThenClose { inbound, outbound in
            for try await requestPart in inbound {
                // We're not interested in request bodies here: we're just serving up GET responses
                // to get the client to initiate a websocket request.
                guard case .head(let head) = requestPart else {
                    return
                }

                // GETs only.
                guard case .GET = head.method else {
                    try await self.respond405(writer: outbound)
                    return
                }

                var headers = HTTPHeaders()
                headers.add(name: "Content-Type", value: "text/html")
                headers.add(
                    name: "Content-Length",
                    value: String(
                        ByteBuffer(string: websocketResponse)
                            .readableBytes))
                headers.add(name: "Connection", value: "close")
                let responseHead = HTTPResponseHead(
                    version: .init(major: 1, minor: 1),
                    status: .ok,
                    headers: headers
                )

                try await outbound.write(
                    contentsOf: [
                        .head(responseHead),
                        .body(
                            ByteBuffer(string: websocketResponse)
                        ),
                        .end(nil),
                    ]
                )
            }
        }
    }

    private func respond405(
        writer: NIOAsyncChannelOutboundWriter<
            HTTPPart<HTTPResponseHead, ByteBuffer>
        >
    ) async throws {
        var headers = HTTPHeaders()
        headers.add(name: "Connection", value: "close")
        headers.add(name: "Content-Length", value: "0")
        let head = HTTPResponseHead(
            version: .http1_1,
            status: .methodNotAllowed,
            headers: headers
        )

        try await writer.write(
            contentsOf: [
                .head(head),
                .end(nil),
            ]
        )
    }
}

final class HTTPByteBufferResponsePartHandler: ChannelOutboundHandler {
    typealias OutboundIn = HTTPPart<HTTPResponseHead, ByteBuffer>
    typealias OutboundOut = HTTPServerResponsePart

    func write(
        context: ChannelHandlerContext, data: NIOAny,
        promise: EventLoopPromise<Void>?
    ) {
        let part = self.unwrapOutboundIn(data)
        switch part {
        case .head(let head):
            context.write(
                self.wrapOutboundOut(.head(head)), promise: promise)
        case .body(let buffer):
            context.write(
                self.wrapOutboundOut(.body(.byteBuffer(buffer))),
                promise: promise)
        case .end(let trailers):
            context.write(
                self.wrapOutboundOut(.end(trailers)), promise: promise)
        }
    }
}
