//
//  NSAttributedString+Extensions.swift
//  RichEditorView
//
//  Created by Vladimir Babin on 8/11/23.
//

import Foundation

internal extension NSAttributedString {
    
    func toHtml() -> String? {
        let attributes = [NSAttributedString.DocumentAttributeKey.documentType: NSAttributedString.DocumentType.html]
        do {
            let htmlData = try self.data(from: NSMakeRange(0, self.length), documentAttributes: attributes)
            if let htmlString = String(data: htmlData, encoding: String.Encoding.utf8) {
                return htmlString
            }
        } catch {
            print("Error creating HTML from Attributed String")
        }
        return nil
    }
}
