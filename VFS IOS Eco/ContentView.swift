//
//  ContentView.swift
//  VFS IOS Eco
//
//  Created by Gavin Etmanski on 2026-11-13.
//

import SwiftUI

struct ContentView: View {
    private let asciiCat = """
        /\\_/\\
       ( o.o )
        > ^ <
      """

    var body: some View {
        Text(asciiCat)
            .font(.system(size: 40, design: .monospaced))
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ContentView()
}
