import XCTest
@testable import XlsxReaderWriter

final class XlsxReaderWriterTests: XCTestCase {
    func testExample() throws {
        let package = try BRAOfficeDocumentPackage.open("/Users/jh/Downloads/10.12数据分析，数据指导后续功能优化 2.xlsx")
//        guard let relationships = package.relationships else { return }
//        for relationship in relationships.relationshipsArray {
//            print(relationship.target)
//            guard let subRelationships = relationship.relationships else { continue }
//            for subRelationship in subRelationships.relationshipsArray {
//                print(subRelationship.target)
//            }
//        }
        
        func enumerateRelationships(_ relationships: BRARelationships?) {
            relationships?.relationships.forEach({ relationship in
                print(relationship.target)
                enumerateRelationships(relationship.relationships)
            })
        }
        enumerateRelationships(package.relationships)
    }
    func testExample2() throws {
        let package = try BRAOfficeDocumentPackage.open("/Users/jh/Downloads/工资表-工资条自动生成1 3.xlsx")
    }
    
    func testNumberFormat() {
        let format = BRANumberFormat(formatCode: "_(\"¥\"* #,##0.000_);_(\"¥\"* \\(#,##0.000\\);_(\"¥\"* \"-\"???_);_(@_)", andId: 8)
        print(format.numberFormatParts.first!.type.rawValue)
        print(format.formatNumber(-1111))
    }
}
