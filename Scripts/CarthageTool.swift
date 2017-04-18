#!/usr/bin/env xcrun --toolchain com.apple.dt.toolchain.Default --sdk macosx swift

import Foundation
import SwiftScriptCore

class CarthageTool {
    
    func run() {
        XcodeLogger.output(message: "Welcome to CarthageTool", type: .note)
        XcodeLogger.output(message: "Detected platform:", type: .note)
        XcodeLogger.output(message: XcodeEnvironment.platformName.rawValue, type: .note, indentation: 1)
        
        guard let sourceRootURL = XcodeEnvironment.sourceRootURL else {
            XcodeLogger.output(message: "Missing Source Root URL", type: .error)
            return
            
        }
        
        let carthageFrameworksURL = sourceRootURL.appendingPathComponent("Carthage/Build/iOS/")
        
        guard let builtProductsFolderURL = XcodeEnvironment.builtProductsFolderURL else {
            XcodeLogger.output(message: "Missing Built Products URL", type: .error)
            return
        }
                
        let carthageFrameworksURLEnumerator = FileManager.default.enumerator(at: carthageFrameworksURL, includingPropertiesForKeys: nil)
        var sourceFrameworkURLs: [URL] = []
        while let subURL = carthageFrameworksURLEnumerator?.nextObject() {
            if let subURL = subURL as? URL,
                subURL.pathExtension == "framework" {
                sourceFrameworkURLs.append(subURL)
            }
        }
        
        XcodeLogger.output(message: "Detected frameworks:", type: .note)
        let sourceFrameworkNames = sourceFrameworkURLs.flatMap { $0.lastPathComponent }
        for sourceFrameworkName in sourceFrameworkNames {
            XcodeLogger.output(message: sourceFrameworkName, type: .note, indentation: 1)
        }
        
        do {
            try FileManager.default.createDirectory(at: builtProductsFolderURL, withIntermediateDirectories: true, attributes: nil)
            
        } catch let error as NSError {
            XcodeLogger.output(message: error.localizedDescription, type: .error)
        }
        
        sourceFrameworkURLs.forEach { sourceFrameworkURL in
            let destinationFrameworkURL = builtProductsFolderURL.appendingPathComponent(sourceFrameworkURL.lastPathComponent)

            do {
                try FileManager.default.copyItem(at: sourceFrameworkURL, to: destinationFrameworkURL)
            } catch let error as NSError {
                if error.code == CocoaError.Code.fileWriteFileExists.rawValue {
                    XcodeLogger.output(message: error.localizedDescription, type: .note)
                } else {
                    XcodeLogger.output(message: error.localizedDescription, type: .error)
                }
                return
            }
            
            if
                let bundle = Bundle(url: destinationFrameworkURL),
                let executablePath = bundle.executablePath {
                let lastPathComponent = destinationFrameworkURL.lastPathComponent
                
                XcodeLogger.output(message: "Perfoming lipo on \(lastPathComponent)", type: .note)
                
                switch XcodeEnvironment.platformName {
                case .iphoneos:
                    remove(architecture: .i386, from: executablePath)
                    remove(architecture: .x86_64, from: executablePath)
                case .iphonesimulator:
                    remove(architecture: .armv7, from: executablePath)
                    remove(architecture: .arm64, from: executablePath)
                case .unsupported:
                    XcodeLogger.output(message: "Unsupported platform", type: .error, line: #line)
                    return
                }
            } else {
                XcodeLogger.output(message: "Invalid bundle for \(destinationFrameworkURL.lastPathComponent)", type: .error, line: #line)
            }
        }
        
        XcodeLogger.output(message: "CarthageTool done.", type: .note)
    }
    
    func remove(architecture: Architecture, from executablePath: String) {
        XcodeLogger.output(message: "\t Attempting to remove \(architecture.rawValue)", type: .note)
        if info(for: executablePath).contains(architecture.rawValue) {
            XcodeLogger.output(message: "\t \(architecture.rawValue) found. Removing…", type: .note)
            let infoOutput = Bash.run(command: "/usr/bin/lipo", arguments: [executablePath, "-remove", architecture.rawValue, "-o", executablePath])
            
            if !infoOutput.isEmpty {
                XcodeLogger.output(message: infoOutput, type: .note)
            }
        } else {
            XcodeLogger.output(message: "\t \(architecture.rawValue) not found. Skipping…", type: .note)
        }
    }
    
    func info(for executablePath: String) -> String {
        return Bash.run(command: "/usr/bin/lipo", arguments: [executablePath, "-info"])
    }
    
}

CarthageTool().run()
