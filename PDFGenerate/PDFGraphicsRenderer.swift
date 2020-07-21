//
//  PDFGraphicsRenderer.swift
//  PDFGenerate
//
//  Created by Hanson on 2020/7/16.
//  Copyright © 2020 Hanson. All rights reserved.
//

import UIKit

/// UIGraphicsPDFRenderer + PDFKit 生成 PDF
class PDFGraphicsRenderer {
    
    static let A4Width: CGFloat = 595.2
    static let A4Height: CGFloat = 841.8
    
    var pageRect = CGRect(x: 0, y: 0, width: A4Width, height: A4Height)
    var margin = CGPoint(x: 10, y: 10)
    var marginSize: CGSize {
        return CGSize(width: margin.x * 2, height: margin.y * 2)
    }
    
    var headlineText: String = ""
    var bodyText: String = ""
    var images: [UIImage] = []
    
    func generatePDFData() -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Hanson",
            kCGPDFContextAuthor: "Hanson",
            kCGPDFContextTitle: headlineText
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            var imageOffset = addHeadline(headlineText, topOffset: 40)
            imageOffset = addHeadline(headlineText, topOffset: imageOffset)
            for image in images {
                imageOffset = addImage(image, topOffset: imageOffset)
            }
            print("BodyText Top : \(imageOffset)")
            addText(bodyText, topOffset: imageOffset + 10, pdfContext: context)
        }
        
        return data
    }
}

extension PDFGraphicsRenderer {
    @discardableResult
    func addHeadline(_ headline: String, topOffset: CGFloat) -> CGFloat {
        let headlineFont = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        let headlineAttributes: [NSAttributedString.Key: Any] = [.font: headlineFont]
        let attributedheadline = NSAttributedString(string: headline, attributes: headlineAttributes)
        let headlineStringSize = attributedheadline.size()
        let headlineStringRect = CGRect(x: (pageRect.width - headlineStringSize.width) / 2.0, y: topOffset,
                                        width: headlineStringSize.width, height: headlineStringSize.height)
        attributedheadline.draw(in: headlineStringRect)
        return headlineStringRect.origin.y + headlineStringRect.size.height
    }

    @discardableResult
    func addBody(_ body: String, topOffset: CGFloat) -> CGFloat {
        let textFont = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        let textAttributes: [NSAttributedString.Key: Any] = [.paragraphStyle: paragraphStyle, .font: textFont]
        let attributedText = NSAttributedString(string: body, attributes: textAttributes)
        // TODO: - Change Height
        let textRect = CGRect(x: 10, y: topOffset, width: pageRect.width - 20,
                              height: pageRect.height - topOffset - pageRect.height / 5.0)
        attributedText.draw(in: textRect)
        return textRect.origin.y + textRect.size.height
    }

    @discardableResult
    func addImage(_ image: UIImage, topOffset: CGFloat) -> CGFloat {
        let maxHeight = pageRect.height * 0.4
        let maxWidth = pageRect.width * 0.8
        let aspectWidth = maxWidth / image.size.width
        let aspectHeight = maxHeight / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        let scaledWidth = image.size.width * aspectRatio
        let scaledHeight = image.size.height * aspectRatio
        let imageX = (pageRect.width - scaledWidth) / 2.0
        let imageRect = CGRect(x: imageX, y: topOffset, width: scaledWidth, height: scaledHeight)
        image.draw(in: imageRect)
        return imageRect.origin.y + imageRect.size.height
    }
    
    func addText(_ text: String, topOffset: CGFloat, pdfContext: UIGraphicsPDFRendererContext) {
        let textRect = CGRect(x: margin.x, y: -topOffset,
                              width: pageRect.width - marginSize.width,
                              height: pageRect.height - topOffset - margin.y)
        
        var result = renderText(text, textRect: textRect)
        while result.textRange.location != result.textLocation {
            // 新起一页 PDF
            pdfContext.beginPage()
            let textRect = CGRect(x: margin.x, y: -margin.y,
                                  width: pageRect.width - marginSize.width,
                                  height: pageRect.height - marginSize.height)
            result = renderText(text, range: result.textRange, textRect: textRect)
        }
//        let lines = CTFrameGetLines(frameRef) as Array
//            var origins = [CGPoint](repeating: .zero, count: lines.count)
//            CTFrameGetLineOrigins(frameRef, CFRangeMake(0, 0), &origins)
//            let last = origins.last?.y ?? 0
//            print("最后一行文字 Y 坐标: \(last)")
    }
    
    func renderText(_ text: String, range: CFRange = CFRangeMake(0, 0), textRect: CGRect) -> (textRange: CFRange, textLocation: CFIndex) {
        // 字体，段落
        let textFont = UIFont.systemFont(ofSize: 50.0, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .natural
        paragraphStyle.lineBreakMode = .byWordWrapping
        let textAttributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: textFont
        ]

        let currentText = CFAttributedStringCreate(nil, text as CFString, textAttributes as CFDictionary)
        let framesetter = CTFramesetterCreateWithAttributedString(currentText!)
        var currentRange = range
        
        print("文本textRect: \(textRect)")
        // 绘制文字段落
        let framePath = CGMutablePath()
        framePath.addRect(textRect, transform: .identity)
        let frameRef = CTFramesetterCreateFrame(framesetter, currentRange, framePath, nil)
        
        let context = UIGraphicsGetCurrentContext()!
        context.textMatrix = .identity
        // 翻转 Context
        context.translateBy(x: 0, y: textRect.height)
        context.scaleBy(x: 1, y: -1)
        CTFrameDraw(frameRef, context)
        
        // 获取在 frameRect 内绘制的文字的 Range
        currentRange = CTFrameGetVisibleStringRange(frameRef)
        currentRange.location += currentRange.length
        currentRange.length = CFIndex(0)
        
        return (currentRange, CFAttributedStringGetLength(currentText))
    }
}
