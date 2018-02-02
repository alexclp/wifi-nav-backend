//
//  Extensions.swift
//  Backendvapor 
//
//  Created by Alexandru Clapa on 30/01/2018.
//  Copyright © 2018 Alexandru Clapa. All rights reserved.
//

import Foundation

extension Dictionary {
	func jsonString() -> String? {
		let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
		guard jsonData != nil else { return nil }
		let jsonString = String(data: jsonData!, encoding: .utf8)
		guard jsonString != nil else { return nil }
		return jsonString! as String
	}
}
