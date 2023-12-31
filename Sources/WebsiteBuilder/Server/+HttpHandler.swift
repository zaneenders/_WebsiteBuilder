import NIOCore
import NIOHTTP1  // Understand what this does.
import NIOPosix

// My code separate from Apple's
// Still uses some of there function calls but plan to refactor this once I understand how Swift NIO works a little better
extension Server.HTTPHandler {

    func deleteTestFile(
        _ request: HTTPRequestHead, _ context: ChannelHandlerContext
    ) {
        self.buffer.clear()
        self.keepAlive = request.isKeepAlive
        self.state.requestReceived()
        let writeHandler = self.fileIO.remove(
            path: "Resources/test.txt", eventLoop: context.eventLoop)
        writeHandler.whenSuccess {

        }
        writeHandler.whenFailure { e in
            // print("error deleting file")
        }
        var responseHead = httpResponseHead(
            request: request, status: HTTPResponseStatus.ok)
        self.buffer.writeString("attempting delete")
        responseHead.headers.add(
            name: "content-length",
            value: "\(self.buffer!.readableBytes)")
        let response = HTTPServerResponsePart.head(responseHead)
        context.write(self.wrapOutboundOut(response), promise: nil)
    }

    func writeToFile(
        _ request: HTTPRequestHead, _ context: ChannelHandlerContext
    ) {
        self.keepAlive = request.isKeepAlive
        self.state.requestReceived()
        var responseHead = httpResponseHead(
            request: request, status: HTTPResponseStatus.ok)
        self.buffer.clear()
        guard
            let handle: NIOFileHandle = try? .init(
                path: "Resources/test.txt", mode: .write,
                flags: NIOFileHandle.Flags.allowFileCreation())
        else {
            print("unable to get file for.")
            return
        }
        let writeHandler = self.fileIO.write(
            fileHandle: handle, buffer: ByteBuffer(string: "Zane was here\n"),
            eventLoop: context.eventLoop)
        writeHandler.whenSuccess {
            try? handle.close()
        }
        writeHandler.whenFailure { e in
            print("error writing file: \(e)")
            try? handle.close()
        }
        self.buffer.writeString("File written")
        responseHead.headers.add(
            name: "content-length",
            value: "\(self.buffer!.readableBytes)")
        let response = HTTPServerResponsePart.head(responseHead)
        context.write(self.wrapOutboundOut(response), promise: nil)
    }
}
