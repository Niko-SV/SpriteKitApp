//
//  SKNode.swift
//  SpriteKitApp
//
//  Created by NikoS on 28.05.2023.
//
import SpriteKit

public extension SKNode {
    
    func isTouched(name: String) -> Bool {
        return self.name == name || self.parent?.name == name
    }
}
