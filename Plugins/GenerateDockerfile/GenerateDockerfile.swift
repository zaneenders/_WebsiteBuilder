import Foundation
import PackagePlugin

@main
/// `swift package --allow-writing-to-package-directory generate-dockerfile`
struct GenerateSetupScript: CommandPlugin {

    func performCommand(
        context: PluginContext,
        arguments: [String]
    ) async throws {
        var executableProducts: [ExecutableProduct] = []
        for p in context.package.products {
            guard let ep = p as? ExecutableProduct else {
                continue
            }
            if ep.name == "sample-website" {
                continue
            }
            executableProducts.append(ep)
        }
        guard executableProducts.count == 1 else {
            print(
                "Dockerfile generation for multiple executable Products not supported"
            )
            return
        }
        let executableName = executableProducts[0].name
        let fileName: String = "Dockerfile"
        let setupFilePath = context.package.directory.appending(
            subpath: fileName)
        let hasFile = FileManager.default.fileExists(
            atPath: setupFilePath.string)
        if !hasFile {
            write(dockerfileContents(executableName), to: setupFilePath)
            print("Generated Dockerfile: \(setupFilePath.string)")
        } else {
            do {
                try remove(setupFilePath)
                write(dockerfileContents(executableName), to: setupFilePath)
            } catch {
                print("unable to remove old \(fileName)")
            }
            print("Regenerated Dockerfile: \(setupFilePath.string)")
        }
    }

    func dockerfileContents(_ executableName: String) -> String {
        return """
            # ================================
            # Build image
            # ================================
            FROM swift:5.8-jammy as build

            # Install OS updates and, if needed, sqlite3
            RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \\
                && apt-get -q update \\
                && apt-get -q dist-upgrade -y\\
                && rm -rf /var/lib/apt/lists/*

            # Set up a build area
            WORKDIR /build

            # First just resolve dependencies.
            # This creates a cached layer that can be reused
            # as long as your Package.swift/Package.resolved
            # files do not change.
            COPY ./Package.* ./
            RUN swift package resolve

            # Copy entire repo into container
            COPY . .

            # Build everything, with optimizations
            RUN swift build -c release --static-swift-stdlib

            # Switch to the staging area
            WORKDIR /staging

            # Copy main executable to staging area
            RUN cp "$(swift build --package-path /build -c release --show-bin-path)/\(executableName)" ./

            # Copy resources bundled by SPM to staging area
            RUN find -L "$(swift build --package-path /build -c release --show-bin-path)/" -regex '.*\\.resources$' -exec cp -Ra {} ./ \\;

            # THESE ARE NOT CURRENTLY BEING USED
            # Copy any resources from the public directory and views directory if the directories exist
            # Ensure that by default, neither the directory nor any of its contents are writable.
            RUN [ -d /build/Public ] && { mv /build/Public ./Public && chmod -R a-w ./Public; } || true
            RUN [ -d /build/Resources ] && { mv /build/Resources ./Resources && chmod -R a-w ./Resources; } || true

            # ================================
            # Run image
            # ================================
            FROM ubuntu:jammy

            # Make sure all system packages are up to date, and install only essential packages.
            RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \\
                && apt-get -q update \\
                && apt-get -q dist-upgrade -y \\
                && apt-get -q install -y \\
                  ca-certificates \\
                  tzdata \\
            # If your app or its dependencies import FoundationNetworking, also install `libcurl4`.
                  # libcurl4 \\
            # If your app or its dependencies import FoundationXML, also install `libxml2`.
                  # libxml2 \\
                && rm -r /var/lib/apt/lists/*

            # Create a webserver user and group with /app as its home directory
            RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app webserver

            # Switch to the new home directory
            WORKDIR /app

            # Copy built executable and any staged resources from builder
            COPY --from=build --chown=webserver:webserver /staging /app

            # Ensure all further commands run as the webserver user
            USER webserver:webserver

            # Let Docker bind to port 8080
            EXPOSE 8080

            # Start the webserver service when the image is run, default to listening on 8080 in production environment
            ENTRYPOINT ["./\(executableName)"]
            CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
            """
    }

    private func remove(_ path: Path) throws {
        try FileManager.default.removeItem(atPath: path.string)
    }

    // TODO add to ScribeSystem
    private func write(_ contnets: String, to path: Path) {
        FileManager.default.createFile(
            atPath: path.string, contents: contnets.data(using: .utf8))
    }
}
