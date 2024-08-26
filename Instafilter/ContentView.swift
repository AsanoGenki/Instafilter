//
//  ContentView.swift
//  Instafilter
//
//  Created by Genki on 8/26/24.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI
import StoreKit

struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var selectedItem: PhotosPickerItem?
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    @State private var showingFilters = false
    let context = CIContext()
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                        processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("写真がありません", systemImage: "photo.badge.plus", description: Text("タップして画像をインポートしてください"))
                    }
                }
                .onChange(of: selectedItem, loadImage)
                Spacer()
                HStack {
                    Text("強度")
                    Slider(value: $filterIntensity)
                        .onChange(of: filterIntensity, applyProcessing)
                }
                .padding(.vertical)
                HStack {
                    Button("フィルターの変更", action: changeFilter)
                    Spacer()
                    if let processedImage {
                        ShareLink("共有", item: processedImage, preview: SharePreview("Instafilter image", image: processedImage))
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            .confirmationDialog("フィルターを選択", isPresented: $showingFilters) {
                Button("結晶化") { setFilter(CIFilter.crystallize()) }
                Button("エッジ") { setFilter(CIFilter.edges()) }
                Button("ガウスぼかし") { setFilter(CIFilter.gaussianBlur()) }
                Button("ピクセル化") { setFilter(CIFilter.pixellate()) }
                Button("セピア調") { setFilter(CIFilter.sepiaTone()) }
                Button("アンシャープマスク") { setFilter(CIFilter.unsharpMask()) }
                Button("ビネット") { setFilter(CIFilter.vignette()) }
                Button("キャンセル", role: .cancel) { }
            }
        }
    }
    func changeFilter() {
        showingFilters = true
    }
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            guard let inputImage = UIImage(data: imageData) else { return }

            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
    }
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys

        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }

        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }

        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
    }
    @MainActor func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
        filterCount += 1

        if filterCount >= 20 {
            requestReview()
        }
    }
}

#Preview {
    ContentView()
}
