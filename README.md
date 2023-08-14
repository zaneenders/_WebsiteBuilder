# _WebsiteBuilder 
- [ ] creative name

⚠️ Currently only supported on Linux ⚠️

Welcome to `_WebsiteBuilder` This package aims to help build and deploy personal or small websites. Well I have ambitious ideas for what this project could be, one day at a time.

## Getting Started

### Swift

First check that you have Swift installed using the following command.

```bash
swift
```
You should see something similar the following.

```
Welcome to Swift!

Subcommands:

  swift build      Build Swift packages
  swift package    Create and work on packages
  swift run        Run a program from a package
  swift test       Run package tests
  swift repl       Experiment with Swift code interactively

  Use `swift --help` for descriptions of available options and flags.

  Use `swift help <subcommand>` for more information about a subcommand.

```

If you don't have swift installed please check [Swift.Org](https://www.swift.org/download/) to get swift downloaded.

### Swift Package

Now that we have swift installed and ready to use we need to start by making a new folder.

```bash
mkdir ExampleWebsite
cd ExampleWebsite
swift package init --type executable
```

This will setup a new Swift package with an executable product setup for you. You should see output similar to below.

```
Creating executable package: ExampleWebsite
Creating Package.swift
Creating .gitignore
Creating Sources/
Creating Sources/main.swift
```

Now open this directory with your favorite editor and open the `Package.swift` file.

### Package.swift

I personally like to delete the extra comments except for the `// swift-tools-version: 5.8` which is specifies the swift version to the [Swift Package Manager](https://www.swift.org/package-manager/).

Edit the `Package.swift` to include this package as a dependency. Here is what my `Package.swift` file looks like.

```swift
// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "ExampleWebsite",
    dependencies: [
        .package(
            url: "https://github.com/zaneenders/_WebsiteBuilder",
            from: "0.0.0")
    ],
    targets: [
        .executableTarget(
            name: "ExampleWebsite",
            dependencies: [
                .product(name: "WebServer", package: "_WebsiteBuilder"),
                .product(name: "HTMLBuilder", package: "_WebsiteBuilder"),
            ],
            path: "Sources")
    ]
)

```

Now using the command line build the package to make sure everything is linking together nicely.

```bash
swift build
```

Here is what mine looks like.

```
➜  ExampleWebsite swift build
Building for debugging...
[7/7] Linking ExampleWebsite
Build complete! (3.60s)
```

### Starting your Website

Now that your package is all setup lets get started with your first website.

I would run the next few commands to setup the correct folder structure.

```bash
rm Sources/main.swift
mkdir Sources/ExampleWebsite
touch Sources/ExampleWebsite/ExampleWebsite.swift
```

Then replace the contents of `ExampleWebsite.swift` with the following borrowed mostly from [SampleWebsite.swift](https://github.com/zaneenders/_WebsiteBuilder/blob/0.0.0/Sources/SampleWebsite/SampleWebsite.swift) with some names changes to prevent conflict with target names. This file is located in the `_WebsiteBuilder` repository.

```swift
import HTMLBuilder
import WebServer

@main
struct ExampleWebsite: WebsiteProtocol {
    var name: String = "sample-website"
    var pages: [Page] {
        Page(
            "index",
            HTML(Head(js: false)) {
                Body {
                    Heading(.one, "Zane was here")
                        .style(background: .yellow)
                    Heading(.three, "Welcome to my website")
                        .style(foreground: .hex("696969"))
                    Paragraph("I don't like the color red")
                        .style(foreground: .hex("ffffff"))
                        .style(background: .red)
                }
            }
        )
    }
}

```

From here you run the following command and check your `localhost:8080` and you should see the start of your new website. Enjoy and let me know what you think.

```bash
swift run
```
Output:
```
Building for debugging...
Build complete! (0.40s)
starting server for example-website @0.0.0.0:8080
```

Use `ctrl-c` to close the server.

### Multiple Pages

From here I think the best thing to do is add another page.

```swift
import HTMLBuilder
import WebServer

@main
struct ExampleWebsite: WebsiteProtocol {
    var name: String = "example-website"
    var pages: [Page] {
        Page(
            "index",
            HTML(Head(js: false)) {
                Body {
                    Heading(.one, "Zane was here")
                        .style(background: .yellow)
                    Link("Other", to: "other")
                }
            }
        )
        Page(
            "other",
            HTML(Head(js: false)) {
                Body {
                    Heading(.one, "Zane was also here")
                        .style(background: .blue)
                    Link("Home", to: "/")
                }
            }
        )
    }
}

```

## Deploy with Fly.io

I have setup this project to be easy to deploy. I have been using Fly.io because its pretty cheap as you can get a tiny 256MB box for just under $2.00 a month and from my experimenting with this project so far RAM usage has never gone over 60MB so that should hold us over for the time being.

To deploy, first run the following command to build a Dockerfile for use to use with Fly.io command line tool.

```bash
swift package --allow-writing-to-package-directory generate-dockerfile
```

This will generate a `Dockerfile` appropriate for what ever you named your executable target the.

From here the steps are pretty easy. Follow the [fly.io](https://fly.io/docs/apps/launch/) instructions and you are off to the races using `fly launch` or `fly deploy` for proceeding updates.
