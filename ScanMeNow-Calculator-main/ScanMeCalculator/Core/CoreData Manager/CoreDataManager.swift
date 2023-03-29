//
//  CoreDataManager.swift
//  ScanMeCalculator
//
//  Created by Zein Rezky Chandra on 28/03/23.
//

import Foundation
import CoreData

struct CoreDataManager {
    
    // MARK: - Class Func
    
    static var shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ScanMeCalculator")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    // MARK: - Func for Business Process
    
    func saveInputResult(input: String, result: Double) {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        guard let inputResultEntity = NSEntityDescription.entity(forEntityName: "InputResultCoreData", in: context) else { return }
        
        let inputResult = NSManagedObject(entity: inputResultEntity, insertInto: context)
        inputResult.setValue(input, forKey: "inputCoreData")
        inputResult.setValue(result, forKey: "resultCoreData")
        
        do {
            try context.save()
        } catch {
            print("Save Error")
            return
        }
    }
    
    func fetchInputResultData() -> [InputResultCoreData] {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "InputResultCoreData")
        
        do {
            return try context.fetch(fetchRequest) as? [InputResultCoreData] ?? []
        } catch {
            print("Fetch Error")
            return []
        }
    }
    
}
