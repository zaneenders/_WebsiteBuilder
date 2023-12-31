//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2017-2021 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
// I copied pretty much this entire file to get a working NIO server.
// TODO delete Apple's code so I don't need this License

import NIOCore
import NIOHTTP1  // Understand what this does.
import NIOPosix

// Maybe try your own crappy version of it?
// How does HTTP2/3 work?

extension Server {
    // TODO read how Channels work. Do we want a fileIO for every channel handler?
    // How does HTTP2 differ?
    final class HTTPHandler: ChannelInboundHandler {

        let fileIO: NonBlockingFileIO

        init(_ fileIO: NonBlockingFileIO) {
            self.fileIO = fileIO
        }

        public typealias InboundIn = HTTPServerRequestPart
        public typealias OutboundOut = HTTPServerResponsePart

        // States for which the Channel can be in
        enum State {
            case idle
            case waitingForRequestBody
            case sendingResponse

            mutating func requestReceived() {
                precondition(
                    self == .idle,
                    "Invalid state for request received: \(self)")
                self = .waitingForRequestBody
            }

            mutating func requestComplete() {
                precondition(
                    self == .waitingForRequestBody,
                    "Invalid state for request complete: \(self)")
                self = .sendingResponse
            }

            mutating func responseComplete() {
                precondition(
                    self == .sendingResponse,
                    "Invalid state for response complete: \(self)")
                self = .idle
            }
        }

        var buffer: ByteBuffer! = nil
        var keepAlive = false
        var state = State.idle

        // Why this? An optional void function? Maybe to close over some state?
        var handler: ((ChannelHandlerContext, HTTPServerRequestPart) -> Void)?

        func channelReadComplete(context: ChannelHandlerContext) {
            context.flush()
        }

        func handlerAdded(context: ChannelHandlerContext) {
            self.buffer = context.channel.allocator.buffer(capacity: 0)
        }

        func userInboundEventTriggered(
            context: ChannelHandlerContext, event: Any
        ) {
            switch event {
            case let evt as ChannelEvent where evt == ChannelEvent.inputClosed:
                // The remote peer half-closed the channel. At this time, any
                // outstanding response will now get the channel closed, and
                // if we are idle or waiting for a request body to finish we
                // will close the channel immediately.
                switch self.state {
                case .idle, .waitingForRequestBody:
                    context.close(promise: nil)
                case .sendingResponse:
                    self.keepAlive = false
                }
            default:
                context.fireUserInboundEventTriggered(event)
            }
        }
    }
}

func httpResponseHead(
    request: HTTPRequestHead, status: HTTPResponseStatus,
    headers: HTTPHeaders = HTTPHeaders()
) -> HTTPResponseHead {

    var head = HTTPResponseHead(
        version: request.version, status: status, headers: headers)
    let connectionHeaders: [String] = head.headers[canonicalForm: "connection"]
        .map { $0.lowercased() }

    if !connectionHeaders.contains("keep-alive")
        && !connectionHeaders.contains("close")
    {
        // the user hasn't pre-set either 'keep-alive' or 'close', so we might need to add headers

        switch (
            request.isKeepAlive, request.version.major, request.version.minor
        ) {
        case (true, 1, 0):
            // HTTP/1.0 and the request has 'Connection: keep-alive', we should mirror that
            head.headers.add(name: "Connection", value: "keep-alive")
        case (false, 1, let n) where n >= 1:
            // HTTP/1.1 (or treated as such) and the request has 'Connection: close', we should mirror that
            head.headers.add(name: "Connection", value: "close")
        default:
            // we should match the default or are dealing with some HTTP that we don't support, let's leave as is
            ()
        }
    }
    return head
}

extension Server.HTTPHandler {

    // Chopped up from HTTP1 Server Example
    private func handleFile(
        context: ChannelHandlerContext,
        request: HTTPServerRequestPart,
        _ filePath: String
    ) {
        self.buffer.clear()
        switch request {
        case .head(let request):
            self.keepAlive = request.isKeepAlive
            self.state.requestReceived()
            let fileHandleAndRegion = self.fileIO.openFile(
                path: filePath, eventLoop: context.eventLoop)
            fileHandleAndRegion.whenFailure { e in
                self.keepAlive = request.isKeepAlive
                self.state.requestReceived()
                var responseHead = httpResponseHead(
                    request: request, status: HTTPResponseStatus.notFound)
                self.buffer.clear()
                self.buffer.writeString(FourOhFourPage().contents)
                responseHead.headers.add(
                    name: "content-length",
                    value: "\(self.buffer!.readableBytes)")
                let response = HTTPServerResponsePart.head(responseHead)
                context.write(self.wrapOutboundOut(response), promise: nil)
            }
            fileHandleAndRegion.whenSuccess { (file, region) in
                var response = httpResponseHead(request: request, status: .ok)
                response.headers.add(
                    name: "Content-Length", value: "\(region.endIndex)")
                response.headers.add(
                    name: "Content-Type", value: "image/x-icon")
                context.write(
                    self.wrapOutboundOut(.head(response)), promise: nil)
                context.writeAndFlush(
                    self.wrapOutboundOut(.body(.fileRegion(region)))
                ).flatMap {
                    let p = context.eventLoop.makePromise(of: Void.self)
                    self.completeResponse(context, trailers: nil, promise: p)
                    return p.futureResult
                }.flatMapError { (_: Error) in
                    context.close()
                }.whenComplete { (_: Result<Void, Error>) in
                    _ = try? file.close()
                }
            }
        case .end:
            self.state.requestComplete()
        default:
            fatalError("oh noes: \(request)")
        }
    }
}

extension Server.HTTPHandler {
    // This has been mostly chopped up from Apple's but still needs to be refactored.
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        // This is the entry point to the handler so understanding the reqPart and the handler
        let reqPart = self.unwrapInboundIn(data)
        if let handler = self.handler {
            handler(context, reqPart)
            return
        }
        switch reqPart {
        case .head(let request):
            if request.uri == "/favicon.ico" {
                self.handler = { c, r in
                    self.handleFile(
                        context: c, request: r, "Resources/favicon.ico"
                    )
                }
                self.handler!(context, reqPart)
                return
            }
            // TODO this is broken Look into how to properlly handle files over HTTP
            #if DEBUG
                /*
                if request.uri == "/Yellowtail-Regular.ttf" {
                    self.handler = { c, r in
                        self.handleFile(
                            context: c, request: r,
                            "Resources/Yellowtail-Regular.tff"
                        )
                    }
                    self.handler!(context, reqPart)
                    return
                }
            */
                // Toying around with reading and writing files to Disk.

                if request.uri == "/write" {
                    self.writeToFile(request, context)
                    return
                }
                if request.uri == "/delete" {
                    self.deleteTestFile(request, context)
                    return
                }
            #endif
            if request.uri == RobotsTxt.url {
                self.handler = self.simplePageHandler(
                    request: request, RobotsTxt().contents)
                self.handler!(context, reqPart)
                return
            } else if request.uri == JSPage.url {
                self.keepAlive = request.isKeepAlive
                self.state.requestReceived()
                var responseHead = httpResponseHead(
                    request: request, status: HTTPResponseStatus.ok)
                self.buffer.clear()
                self.buffer.writeString(JSPage().contents)
                responseHead.headers.add(
                    name: "content-type",
                    value: "text/javascript; charset=utf-8")
                responseHead.headers.add(
                    name: "content-length",
                    value: "\(self.buffer!.readableBytes)")
                let response = HTTPServerResponsePart.head(responseHead)
                context.write(self.wrapOutboundOut(response), promise: nil)
                return
            }
            // Ugh not sure how to not have the pages be static
            else if let page = Server.pages[request.uri] {
                self.handler = self.simplePageHandler(
                    request: request, page.contents)
                self.handler!(context, reqPart)
            } else {
                // Page not found, 404
                self.keepAlive = request.isKeepAlive
                self.state.requestReceived()
                var responseHead = httpResponseHead(
                    request: request, status: HTTPResponseStatus.notFound)
                self.buffer.clear()
                self.buffer.writeString(FourOhFourPage().contents)
                responseHead.headers.add(
                    name: "content-length",
                    value: "\(self.buffer!.readableBytes)")
                let response = HTTPServerResponsePart.head(responseHead)
                context.write(self.wrapOutboundOut(response), promise: nil)
            }
        case .body:
            break  // What goes here? possible post request?
        case .end:
            self.state.requestComplete()
            let content = HTTPServerResponsePart.body(
                .byteBuffer(buffer!.slice()))
            context.write(self.wrapOutboundOut(content), promise: nil)
            self.completeResponse(context, trailers: nil, promise: nil)
        }
    }
}

extension Server.HTTPHandler {

    func completeResponse(
        _ context: ChannelHandlerContext, trailers: HTTPHeaders?,
        promise: EventLoopPromise<Void>?
    ) {
        self.state.responseComplete()
        let promise =
            self.keepAlive
            ? promise : (promise ?? context.eventLoop.makePromise())
        if !self.keepAlive {
            promise!.futureResult.whenComplete { (_: Result<Void, Error>) in
                context.close(promise: nil)
            }
        }
        self.handler = nil

        context.writeAndFlush(
            self.wrapOutboundOut(.end(trailers)), promise: promise)
    }
}

extension Server.HTTPHandler {

    func handleJustWrite(
        context: ChannelHandlerContext, request: HTTPServerRequestPart,
        statusCode: HTTPResponseStatus = .ok, string: String,
        trailer: (String, String)? = nil, delay: TimeAmount = .nanoseconds(0)
    ) {
        switch request {
        case .head(let request):
            self.keepAlive = request.isKeepAlive
            self.state.requestReceived()
            context.writeAndFlush(
                self.wrapOutboundOut(
                    .head(
                        httpResponseHead(request: request, status: statusCode))),
                promise: nil)
        case .body(buffer: _):
            ()
        case .end:
            self.state.requestComplete()
            context.eventLoop.scheduleTask(in: delay) { () -> Void in
                var buf = context.channel.allocator.buffer(
                    capacity: string.utf8.count)
                buf.writeString(string)
                context.writeAndFlush(
                    self.wrapOutboundOut(.body(.byteBuffer(buf))), promise: nil)
                var trailers: HTTPHeaders? = nil
                if let trailer = trailer {
                    trailers = HTTPHeaders()
                    trailers?.add(name: trailer.0, value: trailer.1)
                }

                self.completeResponse(context, trailers: trailers, promise: nil)
            }
        }
    }
}

extension Server.HTTPHandler {

    func simplePageHandler(request reqHead: HTTPRequestHead, _ contents: String)
        -> (
            (ChannelHandlerContext, HTTPServerRequestPart) -> Void
        )?
    {
        return { context, req in
            self.handleJustWrite(
                context: context,
                request: req,
                string: contents)
        }
    }
}
