//
//  Model.swift
//  absolute
//
//  Created by aiv on 21.05.2023.
//

import Foundation

struct Translation: Hashable {
    var id: String
    var source: String
    var target: String
}

struct XLIFFParser {
    static func parse(fileURL: URL) -> [Translation]? {
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        let parser = XMLParser(data: data)
        let delegate = XLIFFParserDelegate()
        parser.delegate = delegate
        
        guard parser.parse() else {
            return nil
        }
        
        return delegate.translations
    }
}

class XLIFFParserDelegate: NSObject, XMLParserDelegate {
    var translations: [Translation] = []
    private var currentTranslation: Translation?
    
    private var currentElement: String?
    private var currentValue: String?
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        
        if elementName == "trans-unit" {
            if let id = attributeDict["id"] {
                currentTranslation = Translation(id: id, source: "", target: "")
            }
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue = string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "source" {
            currentTranslation?.source = currentValue ?? ""
        } else if elementName == "target" {
            currentTranslation?.target = currentValue ?? ""
        } else if elementName == "trans-unit" {
            guard let translation = currentTranslation else { return }
            translations.append(translation)
        }
    }
}

func saveFile(with translations: [Translation], filePath: String) {

    var xliffString = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    xliffString += "<xliff version=\"1.2\" xmlns=\"urn:oasis:names:tc:xliff:document:1.2\">\n"
    xliffString += "  <file source-language=\"en\" target-language=\"ru\" datatype=\"plaintext\" original=\"my_file_name.txt\">\n"
    xliffString += "    <body>\n"
    
    for translation in translations {
        xliffString += "      <trans-unit id=\"\(translation.id)\">\n"
        xliffString += "        <source>\(translation.source)</source>\n"
        xliffString += "        <target>\(translation.target)</target>\n"
        xliffString += "      </trans-unit>\n"
    }
    
    xliffString += "    </body>\n"
    xliffString += "  </file>\n"
    xliffString += "</xliff>\n"
    
    do {
        try xliffString.write(toFile: filePath, atomically: true, encoding: .utf8)
        print("XLIFF файл успешно обновлен.")
    } catch {
        print("Ошибка при обновлении XLIFF файла: \(error)")
    }
}
