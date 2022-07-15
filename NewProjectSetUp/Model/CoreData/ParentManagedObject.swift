//
//  ParentManagedObject.swift
//  FitFin
//
//  Created by MAC OS 13 on 08/12/21.
//

import Foundation
import CoreData

//MARK: - NSManagedObject
extension NSManagedObject {
    
    class func entityName() -> String {
        return "\(self.classForCoder())"
    }
    
    class func delete(removeObjects oldObjs: [NSManagedObject], newObjs:[NSManagedObject] = []){
        var setOld = Set(oldObjs)
        let setNew = Set(newObjs)
        
        setOld.subtract(setNew)
        
        for obj in setOld{
            _appDelegator.persistentContainer.viewContext.delete(obj)
        }
        _appDelegator.saveContext()
    }
}

//MARK: - Protocol ParentManagedObject
protocol ParentManagedObject {
    
    
}

extension ParentManagedObject where Self: NSManagedObject {
    
    /***
     It will create a new entity in database by passing its name and return NSManagedObject
     */
    static func createNewEntity() -> Self {
        let object = NSEntityDescription.insertNewObject(forEntityName: Self.entityName(), into: _appDelegator.persistentContainer.viewContext) as! Self
        return object
    }
    
    /***
     It will create a new entity in database by passing its name and return NSManagedObject, if object with that primary key already exist it will fetch that object and return.
     */
    static func createNewEntity(key: String,value: String) -> Self {
        let predicate = NSPredicate(format: "%K = %@",key,value)
        
        let results = fetch(predicate: predicate, sortDescs: nil)
        let entity: Self
        
        if results.isEmpty{
            entity = createNewEntity()
        }else{
            entity = results.first!
        }
        return entity
    }
    
    
    /***
     It will create a new entity in database by passing its name and return NSManagedObject, if object with that primary key already exist it will fetch that object and return.
     */
    static func createNewEntity(predicate: NSPredicate) -> Self {
        
        let results = fetch(predicate: predicate, sortDescs: nil)
        let entity: Self
        
        if results.isEmpty{
            entity = createNewEntity()
        }else{
            entity = results.first!
        }
        return entity
    }
    /***
     It will check for entity with that primary key  if found object will get return or will return nil.
     */
    static func checkEntity(key: String,value: String) -> Self? {
        let predicate = NSPredicate(format: "%K = %@",key,value)
        
        let results = fetch(predicate: predicate, sortDescs: nil)
        
        if results.isEmpty{
            return nil
        }else{
            return results.first
        }
    }
    
    
    /***
     It will return NSEntityDescription optional value, by passing entity name.
     */
    static func getExisting() -> NSEntityDescription? {
        let entityDesc = NSEntityDescription.entity(forEntityName: Self.entityName(), in: _appDelegator.persistentContainer.viewContext)
        return entityDesc
    }
    
    /***
     It will return an array of existing values from given entity name, with peredicate and sort description.
     */
    static func fetch(predicate:NSPredicate? = nil, sortDescs:[NSSortDescriptor]? = nil, fetchLimit :Int? = nil)-> [Self] {
        let entityDesc = getExisting()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = entityDesc
        
        if let _ = predicate {
            fetchRequest.predicate = predicate
        }
        if let _ = sortDescs {
            fetchRequest.sortDescriptors = sortDescs
        }
        if let limit = fetchLimit{
            fetchRequest.fetchLimit = limit
        }
        do {
            let resultsObj = try _appDelegator.persistentContainer.viewContext.fetch(fetchRequest)
            if (resultsObj as! [Self]).count > 0 {
                return resultsObj as! [Self]
            }else{
                return []
            }
            
        } catch let error as NSError {
            jprint("Error in fetchedRequest : \(error.localizedDescription)")
            return []
        }
    }
}

/*// CoreData operations
extension AddDisEmployeeVC{

    func fetchEmployeeFromCoreData(){
        employees = Employee.fetchDataFromEntity(predicate: nil, sortDescs: nil)
        tableView.reloadData()
    }
    
    func addEmployee(name: String){
        let emp = Employee.createNewEntity()
        emp.name = name
        _appDelegator.saveContext()
        employees.append(emp)
        tableView.reloadData()
    }
    
    func updateEmployee(name: String, idx: IndexPath){
        let emp = employees[idx.row]
        emp.name = name
        _appDelegator.saveContext()
        tableView.reloadData()
        self.view.endEditing(true)
    }
    
    func deleteEmployee(idx: IndexPath){
        _appDelegator.managedObjectContext.delete(employees[idx.row])
        _appDelegator.saveContext()
        employees.remove(at: idx.row)
        tableView.deleteRows(at: [idx], with: .middle)
    }
}
*/
