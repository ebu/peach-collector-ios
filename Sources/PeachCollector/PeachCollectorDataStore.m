//
//  PeachCollectorDataStore.m
//  PeachCollector
//
//  Created by Rayan Arnaout on 17.10.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import "PeachCollectorDataStore.h"
#import "PeachPersistentContainer.h"

@interface PeachCollectorDataStore ()

@property (nonatomic) PeachPersistentContainer *persistentContainer;

@property (nonatomic) NSOperationQueue *serialOperationQueue;
@property (nonatomic) NSMapTable<NSString *, NSOperation *> *operations;
@property (nonatomic) NSMapTable<NSString *, PCDataStoreReadCompletionBlock> *readCompletionBlocks;
@property (nonatomic) NSMapTable<NSString *, PCDataStoreWriteCompletionBlock> *writeCompletionBlocks;

@property (nonatomic) dispatch_queue_t concurrentQueue;

@end

@implementation PeachCollectorDataStore


- (instancetype)init{
    if (self = [super init]) {
        
        NSURL *directoryURL = [[NSPersistentContainer defaultDirectoryURL] URLByAppendingPathComponent:@"PeachCollector"];
        // Check if the PeachCollector folder is already created, create it if not
        if (! [NSFileManager.defaultManager fileExistsAtPath:directoryURL.absoluteString]) {
            NSError *err;
            if (![NSFileManager.defaultManager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&err]) {
                NSLog(@"Unable to create folder at %@: %@", directoryURL, err);
            }
        }
        
        self.persistentContainer = [[PeachPersistentContainer alloc] initWithName:@"PeachCollector"];
        [self.persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
            if (error != nil) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                // abort();
            }
        }];
        
        self.serialOperationQueue = [[NSOperationQueue alloc] init];
        self.serialOperationQueue.maxConcurrentOperationCount = 1;
        
        self.operations = [NSMapTable strongToWeakObjectsMapTable];
        self.readCompletionBlocks = [NSMapTable strongToStrongObjectsMapTable];
        self.writeCompletionBlocks = [NSMapTable strongToStrongObjectsMapTable];
        
        self.concurrentQueue = dispatch_queue_create("ch.ebu.PeachCollector.DataStore.concurrent", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return self.persistentContainer.viewContext;
}



- (void)performBackgroundReadTask:(id (^)(NSManagedObjectContext *managedObjectContext))task
                           withPriority:(NSOperationQueuePriority)priority
                        completionBlock:(PCDataStoreReadCompletionBlock)completionBlock
{
    NSString *handle = NSUUID.UUID.UUIDString;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *managedObjectContext = self.persistentContainer.newBackgroundContext;
        managedObjectContext.undoManager = nil;
        
        __block id result = nil;
        
        [managedObjectContext performBlockAndWait:^{
            result = task(managedObjectContext);
            NSCAssert(! managedObjectContext.hasChanges, @"The managed object context must not be altered");
        }];
        
        completionBlock(result, nil);
        
        dispatch_barrier_async(self.concurrentQueue, ^{
            [self.operations removeObjectForKey:handle];
            [self.readCompletionBlocks removeObjectForKey:handle];
        });
    }];
    operation.queuePriority = priority;
    
    dispatch_barrier_async(self.concurrentQueue, ^{
        [self.readCompletionBlocks setObject:completionBlock forKey:handle];
        [self.operations setObject:operation forKey:handle];
        [self.serialOperationQueue addOperation:operation];
    });
}


- (void)performBackgroundWriteTask:(void (^)(NSManagedObjectContext *managedObjectContext))task
                            withPriority:(NSOperationQueuePriority)priority
                         completionBlock:(PCDataStoreWriteCompletionBlock)completionBlock;
{
    NSString *handle = NSUUID.UUID.UUIDString;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        NSManagedObjectContext *managedObjectContext = self.persistentContainer.newBackgroundContext;
        if (@available(iOS 10, *)) {
            managedObjectContext.automaticallyMergesChangesFromParent = YES;
        }
        managedObjectContext.mergePolicy = NSOverwriteMergePolicy;
        managedObjectContext.undoManager = nil;
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(backgroundManagedObjectContextDidSave:)
                                                   name:NSManagedObjectContextDidSaveNotification
                                                 object:managedObjectContext];
        
        __block NSError *error = nil;
        
        [managedObjectContext performBlockAndWait:^{
            task(managedObjectContext);
            
            if (managedObjectContext.hasChanges) {
                if (! [managedObjectContext save:&error]) {
                    [managedObjectContext rollback];
                }
            }
        }];
        
        completionBlock ? completionBlock(error) : nil;
        
        [NSNotificationCenter.defaultCenter removeObserver:self
                                                      name:NSManagedObjectContextDidSaveNotification
                                                    object:managedObjectContext];
        
        dispatch_barrier_async(self.concurrentQueue, ^{
            [self.operations removeObjectForKey:handle];
            [self.writeCompletionBlocks removeObjectForKey:handle];
        });
    }];
    operation.queuePriority = priority;
    
    dispatch_barrier_async(self.concurrentQueue, ^{
        [self.writeCompletionBlocks setObject:completionBlock forKey:handle];
        [self.operations setObject:operation forKey:handle];
        [self.serialOperationQueue addOperation:operation];
    });
}


#pragma mark Notifications

- (void)backgroundManagedObjectContextDidSave:(NSNotification *)notification
{
    NSAssert(! NSThread.isMainThread, @"Saves are only made on background contexts and thus notified on background threads");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *viewContext = self.persistentContainer.viewContext;
        if (notification.object != viewContext) {
            [viewContext mergeChangesFromContextDidSaveNotification:notification];
            
            NSError *error = nil;
            if (! [viewContext save:&error]) {
               NSLog(@"Could not save merged changes into the main context. Reason: %@", error);
            }
        }
    });
}

@end

