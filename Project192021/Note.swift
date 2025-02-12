//
//  Note.swift
//  Project192021
//
//  Created by Aleksei Ivanov on 12/2/25.
//

import Foundation
import UIKit

class Note: NSObject, Codable {
    var text: String
    
    init(text: String) {
        self.text = text
    }
}
