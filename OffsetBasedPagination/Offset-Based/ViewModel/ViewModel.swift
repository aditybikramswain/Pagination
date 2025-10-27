//
//  ViewModel.swift
//  PaginationI
//
//  Created by Apple on 27/10/25.
//

import Foundation
import Combine
import UIKit
import SwiftUI

class ViewModel: ObservableObject {
    @Published var iamge = [Model]()
    @Published var isLoading: Bool = false
    private var pageLimtit: Int = 10
    private var currentPage: Int = 1
    
    @MainActor
    func loadTheNextPage() async throws {
        guard !isLoading else {return}
        isLoading = true
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        let startId = (currentPage - 1) * pageLimtit
        let endID = startId + pageLimtit
        await withTaskGroup(of: Model?.self) { group in
            for id in startId ..< endID {
                group.addTask { [weak self] in
                    guard let self else { return nil }
                    let result = await self.loadDataByID(for: id)
                    return result
                }
            }

            for await result in group {
                if let model = result {
                    withAnimation(.easeOut(duration: 0.3)) {
                        self.iamge.append(model)
                    }
                }
            }
            self.currentPage += 1
            self.isLoading = false
        }
    }
    
    private func loadDataByID(for id: Int) async -> Model {
        let urlString = "https://loremflickr.com/500/400/nature?lock=\(id)"
        guard let url = URL(string: urlString) else {
            return makeErrorModel(id: id, message: "Invalid URL")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return makeErrorModel(id: id, message: "Invalid HTTP response")
            }
            guard let uiImage = UIImage(data: data) else {
                return makeErrorModel(id: id, message: "Corrupted image data")
            }
            
            return Model(
                title: "Nature Image \(id)",
                description: "Fetched successfully",
                image: urlString,
                status: true,
                data: uiImage,
                errorMessage: nil
            )
        } catch {
            return makeErrorModel(id: id, message: error.localizedDescription, description: "Network error")
        }
    }

    
}
extension ViewModel {
    /// Creates a standardized error model for failed image loads
    func makeErrorModel(id: Int, message: String, description: String? = nil) -> Model {
        let urlString = "https://loremflickr.com/500/400/nature?lock=\(id)"
        return Model(
            title: "Image \(id)",
            description: description ?? "Error loading image \(id)",
            image: urlString,
            status: false,
            data: nil,
            errorMessage: message
        )
    }
}

