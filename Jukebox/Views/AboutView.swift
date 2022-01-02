//
//  AboutView.swift
//  Jukebox
//
//  Created by Sasindu Jayasinghe on 29/10/21.
//

import SwiftUI

struct AboutView: View {
    
    var body: some View {
        HStack {
            Link(destination: Constants.AppInfo.repo) {
                Image(nsImage: NSImage(named: "AppIcon") ?? NSImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            }
            VStack(alignment: .leading) {
                Text("Jukebox").font(.title).fontWeight(.bold)
                Text("Version \(Constants.AppInfo.appVersion ?? "?")")
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding(.leading, 10)
    }
    
}
