//
//  FluvioClientSwiftExampleApp.swift
//  Shared
//
//  Created by Sebastian Imlay on 4/14/22.
//

import SwiftUI
import FluvioClientSwift

@main
struct FluvioClientSwiftExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


class RustAppWrapper: ObservableObject {
    var rust: Fluvio
    
    init (rust: Fluvio) {
        self.rust = rust
    }
}
