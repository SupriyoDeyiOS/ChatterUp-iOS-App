//
//  MessageModel.swift
//  ChatterUp Swift
//
//  Created by Supriyo Dey on 05/05/24.
//

import Foundation

struct MessageResponseModel: Codable {
    let action: String
    let data: MessageDataModel?
}

struct MessageDataModel: Codable {
    let sender: String?
    let senderId: String?
    let id: String?
    let message: String?
    let image: String?
    let deleteId: String?
}
