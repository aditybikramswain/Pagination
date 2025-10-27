//
//  Model.swift
//  PaginationI
//
//  Created by Apple on 27/10/25.
//

import Foundation
import UIKit

struct Model: Identifiable {
    let id = UUID().uuidString
    let title: String
    let description: String
    let image: String
    let status: Bool
    let data: UIImage?
    let errorMessage: String?

}
