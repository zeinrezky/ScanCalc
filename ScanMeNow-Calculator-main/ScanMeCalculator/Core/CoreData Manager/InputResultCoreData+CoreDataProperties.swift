//
//  InputResultCoreData+CoreDataProperties.swift
//  ScanMeCalculator
//
//  Created by Zein Rezky Chandra on 28/03/23.
//
//

import Foundation
import CoreData


extension InputResultCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InputResultCoreData> {
        return NSFetchRequest<InputResultCoreData>(entityName: "InputResultCoreData")
    }

    @NSManaged public var inputCoreData: String?
    @NSManaged public var resultCoreData: Double

}

extension InputResultCoreData : Identifiable {

}
