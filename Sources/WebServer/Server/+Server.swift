#if os(Linux)
    import CHelpers  // Epoll
    import Glibc  // for errno
    import Crypto  // Will use for websockets
    import RegexBuilder

    extension Server {
        func incoming(
            _ listenFD: Int32, _ epollFD: Int32,
            _ tempEventPointer: UnsafeMutablePointer<epoll_event>
        ) {
            let errorCode = -1

            while true {
                var a = sockaddr()
                var l = socklen_t()
                let fd = accept(listenFD, &a, &l)
                guard fd != errorCode else {
                    if errno == EAGAIN || errno == EWOULDBLOCK {
                        break
                    } else {
                        print("accpet error \(errno)")
                        break
                    }
                }
                // TODO get address and port from getnameinfo
                if set_non_block(fd) == errorCode {
                    print("nonblocking: \(errno)")
                }
                let e = EPOLLIN.rawValue | EPOLLET.rawValue
                tempEventPointer.pointee.data.fd = fd
                tempEventPointer.pointee.events = e
                let r = epoll_ctl(
                    epollFD, EPOLL_CTL_ADD, fd, tempEventPointer
                )
                if r == -1 {
                    print("Error: epoll_ctl")
                    return
                }
            }
        }

        func reading(
            _ epollFD: Int32, _ current: UnsafeMutablePointer<epoll_event>,
            _ tempEventPointer: UnsafeMutablePointer<epoll_event>
        ) {
            var done = false
            // TODO how do we combine multiple buffers?
            // test readSize 10 to see
            let readSize = 1024
            let buffer = UnsafeMutableRawPointer.allocate(
                byteCount: readSize,
                alignment: MemoryLayout<UInt8>.alignment)
            defer {
                buffer.deallocate()
            }
            while true {
                let numRead = read(
                    current.pointee.data.fd, buffer, readSize)
                if numRead == -1 {
                    if errno != EAGAIN {
                        print("read error \(errno)")
                        done = true
                        break
                    }
                    let e = EPOLLOUT.rawValue | EPOLLET.rawValue
                    tempEventPointer.pointee.events = e
                    tempEventPointer.pointee.data.fd =
                        current.pointee.data.fd
                    let ret = epoll_ctl(
                        epollFD, EPOLL_CTL_MOD,
                        current.pointee.data.fd,
                        tempEventPointer)
                    if ret == -1 {
                        print("eror: epoll_ctl:mod \(errno)")
                        done = true
                    }
                    break
                } else if numRead == 0 {
                    done = true
                    break
                }
                var bytes: [UInt8] = []
                for o in 0..<numRead {
                    let b = buffer.load(
                        fromByteOffset: o, as: UInt8.self)
                    bytes.append(b)
                }
                guard
                    let str = String(
                        bytes: bytes, encoding: .utf8)
                else {
                    exit(1)
                }
                let pageRequestRegex = Regex {
                    One("GET ")
                    Capture {
                        "/"
                        ZeroOrMore {
                            // This captures everything excluding whats in the negative lookahead
                            NegativeLookahead {
                                One(" HTTP/1.1")
                            }
                            CharacterClass.any
                        }
                    }
                    One(" HTTP/1.1")
                    One(.newlineSequence)
                }
                if let match = str.firstMatch(of: pageRequestRegex) {
                    routes.add(current.pointee.data.fd, String(match.output.1))
                }
                if logging {
                    // Log/ print request
                    let ret = write(1, buffer, numRead)
                    if ret == -1 {
                        print("write error \(errno)")
                        done = true
                        break
                    }
                }
            }
            if done {
                close(current.pointee.data.fd)
            }
        }

        func outgoing(
            _ current: UnsafeMutablePointer<epoll_event>
        ) {
            if let r = routes.lookup(current.pointee.data.fd) {
                if let page = pages[r] {
                    let res =
                        "HTTP/1.1 200 OK\r\nContent-type: text/html; charset=utf-8\r\n\r\n\(page.description)"
                        .cString(using: .utf8)!
                    let count = write(
                        current.pointee.data.fd, res, res.count)
                    if count == -1 {
                        print(
                            "error writing response \(current.pointee.data.fd)"
                        )
                    }
                    routes.remove(current.pointee.data.fd)
                    close(current.pointee.data.fd)
                    return
                }
                routes.remove(current.pointee.data.fd)
            }
            let res =
                """
                HTTP/1.1 404 Not Found\r\nContent-type: text/html; charset=utf-8\r\n\r\nThis is not the page you are looking for.\r\n
                """
                .cString(using: .utf8)!
            let count = write(current.pointee.data.fd, res, res.count)
            if count == -1 {
                print(
                    "error writing response \(current.pointee.data.fd)"
                )
            }
            close(current.pointee.data.fd)
        }
    }

#endif
