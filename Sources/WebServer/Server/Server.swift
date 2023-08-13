#if os(Linux)
    import CHelpers
    import Glibc  // for errno
    import Crypto

    struct Routing {
        private var routeLookup: [Int32: String] = [:]

        func lookup(_ fd: Int32) -> String? {
            routeLookup[fd]
        }

        mutating func add(_ fd: Int32, _ r: String) {
            routeLookup[fd] = r
        }

        mutating func remove(_ fd: Int32) {
            routeLookup.removeValue(forKey: fd)
        }
    }

    actor Server {
        // https://github.com/apple/swift-crypto/blob/main/Sources/Crypto/Insecure/Insecure_HashFunctions.swift
        let sha1 = Insecure.SHA1()
        var routes = Routing()
        let website: Website
        let logging: Bool
        let pages: [String: Page]

        init(severing website: Website, logging: Bool = false) {
            var arrR: [String: Page] = [:]
            for page in website.pages {
                if page.fileName == "index" {
                    arrR["/"] = page
                } else {
                    arrR["/" + page.fileName] = page
                }
            }
            self.pages = arrR
            self.website = website
            self.logging = logging
        }

        func start(
            at host: String = "0.0.0.0", on port: Int
        ) {
            print("starting server for \(website.name) @\(host):\(port)")
            let errorCode = -1
            let maxEvents = 10240
            let tempEventPointer = UnsafeMutablePointer<epoll_event>.allocate(
                capacity: 1)
            let eventsPointer = UnsafeMutablePointer<epoll_event>.allocate(
                capacity: maxEvents)
            defer {
                eventsPointer.deallocate()
                tempEventPointer.deallocate()
            }
            var _host = host
            var _port = "\(port)"
            let listenFD: Int32 = create_and_bind(&_host, &_port)
            defer {
                close(listenFD)
            }
            if listenFD == errorCode {
                print("-1")
                return
            }
            if set_non_block(listenFD) == errorCode {
                print("-2")
                return
            }
            let idk: Int32 = 0
            let epollFD: Int32 = epoll_create1(idk)
            if epollFD == errorCode {
                print("epoll ed error")
                return
            }
            if listen(listenFD, SOMAXCONN) == errorCode {
                print("listen error")
            }
            tempEventPointer.pointee.data.fd = listenFD
            tempEventPointer.pointee.events =
                EPOLLIN.rawValue | EPOLLET.rawValue
            if epoll_ctl(epollFD, EPOLL_CTL_ADD, listenFD, tempEventPointer)
                == errorCode
            {
                print("epoll_ctl error")
                return
            }
            let timeout: Int32 = -1
            while true {
                let n = epoll_wait(epollFD, eventsPointer, 10240, timeout)
                for i in 0..<n {
                    let current = eventsPointer.advanced(by: Int(i))
                    let a = current.pointee.events & EPOLLERR.rawValue
                    let b = current.pointee.events & EPOLLHUP.rawValue
                    let c = ~current.pointee.events & EPOLLIN.rawValue
                    // idk why c is broken
                    if (a != 0) || (b != 0) /* || (c != 0) */ {
                        if logging {
                            print("closing \(current.pointee.data.fd)")
                        }
                        close(current.pointee.data.fd)
                    } else if listenFD == current.pointee.data.fd {
                        incoming(listenFD, epollFD, tempEventPointer)
                    } else if current.pointee.events
                        & EPOLLIN.rawValue != 0
                    {
                        reading(epollFD, current, tempEventPointer)
                    } else if current.pointee.events
                        & EPOLLOUT.rawValue != 0
                    {
                        outgoing(current)
                    }
                }
            }
        }
    }
#endif
