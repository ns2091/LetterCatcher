//
//  Character.swift
//  CarExample
//
//  Created by やきそば on 2025/03/23.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation

struct Character: Codable {
    let char: String
    let modelFile: String
    let soundFile: String
    let scale: Float
    let rotate: Float    
}
