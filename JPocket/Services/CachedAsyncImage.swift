//
//  CachedAsyncImage.swift
//  JPocket
//
//  Created by Ruby on 15/12/2024.
//

import Foundation
import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        if let url = url {
            CachedImage(url: url, scale: scale, content: content, placeholder: placeholder)
        } else {
            placeholder()
        }
    }
}

private struct CachedImage<Content: View, Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    init(
        url: URL,
        scale: CGFloat = 1.0,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        _loader = StateObject(wrappedValue: ImageLoader(url: url, scale: scale))
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = loader.image {
                content(image)
            } else {
                placeholder()
            }
        }
        .onAppear {
            loader.load()
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

private class ImageLoader: ObservableObject {
    @Published var image: Image?
    
    private let url: URL
    private let scale: CGFloat
    private var task: URLSessionDataTask?
    
    private static let cache = NSCache<NSURL, UIImage>()
    
    init(url: URL, scale: CGFloat) {
        self.url = url
        self.scale = scale
    }
    
    func load() {
        if let cachedImage = Self.cache.object(forKey: url as NSURL) {
            self.image = Image(uiImage: cachedImage)
            return
        }
        
        task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let uiImage = UIImage(data: data) else {
                return
            }
            
            Self.cache.setObject(uiImage, forKey: url as NSURL)
            
            DispatchQueue.main.async {
                self.image = Image(uiImage: uiImage)
            }
        }
        task?.resume()
    }
    
    func cancel() {
        task?.cancel()
    }
    
    deinit {
        cancel()
    }
} 
