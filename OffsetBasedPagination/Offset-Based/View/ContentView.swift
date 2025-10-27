//
//  ContentView.swift
//  PaginationI
//
//  Created by Apple on 27/10/25.
//

import SwiftUI

struct ContentView: View {
  @StateObject var vm = ViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack() {
                    ForEach(vm.iamge.indices, id: \.self) { index in
                        let item = vm.iamge[index]
                        VStack() {
                            if let image = item.data {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 150)
                                    .clipped()
                                    .cornerRadius(12)
                                    .clipped()
                                    .cornerRadius(12)
                                    .transition(.opacity.combined(with: .scale)) // <— fade + zoom
                                    .animation(.easeInOut(duration: 0.4), value: item.data)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.7))
                                    .overlay {
                                        Text(item.errorMessage ?? "Error")
                                            .font(.caption.bold())
                                            .foregroundColor(.red)
                                            .padding()
                                    }
                                    .frame(height: 150)
                                    .cornerRadius(12)
                            }
                            Text(item.title)
                                .font(.headline)
                            Text(item.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .onAppear {
                            if index == vm.iamge.count - 2 {
                                Task {
                                    do {
                                        
                                        try await vm.loadTheNextPage()
                                    } catch {
                                        print("Failed to load next page on appear: \(error)")
                                    }
                                }
                            }
                        }
                        
                    }
                }
                .padding()
                if vm.isLoading {
                    ProgressView("Loading More...")
                        .padding()
                }
            }
            .navigationTitle("Pagination")
            .task {
                if vm.iamge.isEmpty {
                    do {
                        try await vm.loadTheNextPage()
                    } catch {
                        print("Failed to load initial page in .task: \(error)")
                    }
                }
            }
            
        }
    }
}

#Preview {
    ContentView()
}

