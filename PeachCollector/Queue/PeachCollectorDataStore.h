//
//  PeachCollectorDataStore.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 17.10.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

// Block signatures
typedef void (^PCDataStoreReadCompletionBlock)(id _Nullable result, NSError * _Nullable error);
typedef void (^PCDataStoreWriteCompletionBlock)(NSError * _Nullable error);

@interface PeachCollectorDataStore : NSObject

- (NSManagedObjectContext *)managedObjectContext;

/**
 *  Enqueue a read operation on the serial queue, with a priority level. Pending tasks with higher priority will be moved to the front and executed first. The mandatory completion block will be called on completion.
 *
 *  @param task The read task to be executed. The background context is provided, on which Core Data operations must be performed. A single result can be returned from the task block and will be forwarded to the provided completion block.
 *  @param priority The priority to apply.
 *  @param completionBlock  The block to be called on completion. The block is part of the task itself and should therefore be lightweight (otherwise use GCD to send time-consuming operations on another thread). Beware that if managed objects are returned, they can only be used from within the block associated thread, not on another thread you would dispatch work onto.
 *
 *  @discussion This method can be called from any thread.
 */
- (void)performBackgroundReadTask:(id _Nullable (^)(NSManagedObjectContext *managedObjectContext))task
                           withPriority:(NSOperationQueuePriority)priority
                        completionBlock:(PCDataStoreReadCompletionBlock)completionBlock;

/**
 *  Enqueue a write operation on the serial queue, with a priority level. Pending tasks with higher priority will be moved to the front and executed first. The optional completion block will be called on completion.
 *
 *  @param task The write task to be executed. The background context is provided, on which Core Data operations must be performed. A single success boolean must be returned from the task block (failed tasks will be rollbacked).
 *  @param priority The priority to apply.
 *  @param completionBlock The block to be called on completion. The block is part of the task itself and should therefore be lightweight, otherwise use GCD to send time-consuming operations on another thread.
 *
 *  @discussion Once the task successfully completes, a save is automaticaly performed. If the save operation fails (e.g. because of model validation errors), the work is rollbacked automatically and the completion block is called with corresponding error information. This method can be called from any thread.
 */
- (void)performBackgroundWriteTask:(void (^)(NSManagedObjectContext *managedObjectContext))task
                            withPriority:(NSOperationQueuePriority)priority
                         completionBlock:(nullable PCDataStoreWriteCompletionBlock)completionBlock;


@end

NS_ASSUME_NONNULL_END
