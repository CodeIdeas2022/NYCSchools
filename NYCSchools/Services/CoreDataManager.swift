//
//  CoreDataManager.swift
//  Services
//
//  Created by M1Pro on 9/30/22.
//

import Foundation
import CoreData
import Combine

public class CDManager {
    let modelName = "Model"
    static let shared = CDManager()
    lazy var persistentContainer: NSPersistentContainer = {
        let modelURL = Bundle(for: CDManager.self).url(forResource: modelName, withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: managedObjectModel!)
        return container
    }()
    
    lazy var context: NSManagedObjectContext = {
        return persistentContainer.viewContext
    }()
    
    func insert(schools: [School]) -> PassthroughSubject<Void, Swift.Error> {
        let subject = PassthroughSubject<Void, Swift.Error>()
        func save() {
            for school in schools {
                school.schoolEntity(self.context)
            }
            do {
                try context.save()
                subject.send()
                subject.send(completion: .finished)
            }
            catch {
                print("CD Model load failed:\(error)")
                subject.send(completion: .failure(error))
            }
        }
        if let e = delete() {
            subject.send(completion: .failure(e))
            return subject
        }
        load { [unowned self] error in
            if let e = error {
                subject.send(completion: .failure(e))
                return
            }
            self.context.perform {
                save()
            }
        }
        return subject
    }
    
    func delete() -> Swift.Error? {
        guard let storeDescription = self.persistentContainer.persistentStoreDescriptions.first else {
            return Error.noStoreDescription
        }
        guard let url = storeDescription.url else {
            return Error.noStoreUrl
        }
        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: url, ofType: storeDescription.type)
            return nil
        }
        catch {
            return error
        }
    }
    
    func load(_ completion: @escaping (_ error: Swift.Error?) -> Void) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let e = error{
                completion(e)
                return
            }
            completion(nil)
        }
    }
}

extension CDManager {
    struct EntityName {
        static let school = "SchoolInfo"
    }
    
    enum Error: Swift.Error {
        case noStoreDescription
        case noStoreUrl
    }
}

extension CDManager {
    func fetch<T>(_ predicates: [NSPredicate], sortDescriptors: [NSSortDescriptor]) -> [T] {
        let request = NSFetchRequest<SchoolInfo>(entityName: "\(T.self)")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        request.sortDescriptors = sortDescriptors
        do {
            return ((try context.fetch(request)) as? [T]) ?? []
        }
        catch {
            return []
        }
    }
}

extension School {
    @discardableResult func schoolEntity(_ context: NSManagedObjectContext) -> SchoolInfo {
        let schoolEntity = NSEntityDescription.insertNewObject(forEntityName: CDManager.EntityName.school, into: context) as! SchoolInfo
        schoolEntity.dbn = dbn
        schoolEntity.name = name
        schoolEntity.borough = borough
        schoolEntity.addressLine1 = addressLine1
        schoolEntity.city = city
        schoolEntity.zip = zip
        schoolEntity.overview = overview
        schoolEntity.neighborhood = neighborhood
        schoolEntity.phone = phone
        schoolEntity.email = email
        schoolEntity.website = website
        schoolEntity.totalStudents = totalStudents
        schoolEntity.graduationRate = graduationRate
        schoolEntity.latitude = latitude
        schoolEntity.longitude = longitude
        return schoolEntity
    }
}



