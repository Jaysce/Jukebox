//
//  AboutView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 29/10/21.
//

import SwiftUI

struct AboutView: View {
    
    let jukeboxRepo = "https://github.com/Jaysce/Jukebox"
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    
    var body: some View {
        HStack {
            Link(destination: URL(string: jukeboxRepo)!) {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            VStack(alignment: .leading) {
                Text("Jukebox").font(.title).fontWeight(.bold)
                Text("Version \(appVersion ?? "?")")
            }
            Spacer()
        }
        .padding(.leading, 10)
    }
    
}
