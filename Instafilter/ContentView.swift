//
//  ContentView.swift
//  Instafilter
//
//  Created by Genki on 8/26/24.
//

import SwiftUI

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                if let processedImage {
                    processedImage
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView("写真がありません", systemImage: "photo.badge.plus", description: Text("タップして画像をインポートしてください"))
                }
                Spacer()
                HStack {
                    Text("強度")
                    Slider(value: $filterIntensity)
                }
                .padding(.vertical)
                HStack {
                    Button("フィルターの変更", action: changeFilter)
                    Spacer()
                    // share the picture
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
        }
    }
    func changeFilter() {
    }
}

#Preview {
    ContentView()
}
