//
//  PeachCollectorContext.h
//  PeachCollector
//
//  Created by Rayan Arnaout on 24.09.19.
//  Copyright © 2019 European Broadcasting Union. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeachCollectorContextComponent.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeachCollectorContext : NSObject <NSCopying> 

@property (nonatomic, copy) NSString *contextID;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *appSectionID;
@property (nonatomic, copy) NSString *source;
@property (nonatomic, copy) NSString *referrer;
@property (nonatomic, copy) PeachCollectorContextComponent *component;

@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, copy) NSArray<NSString *> *items;
@property (nonatomic, copy) NSNumber *hitIndex;

@property (nonatomic, copy) NSString *experimentID;
@property (nonatomic, copy) NSString *experimentComponent;

- (instancetype)initCollectionContextWithHitIndex:(NSNumber *)hitIndex
                                           itemID:(NSString *)itemID
                                     experimentID:(nullable NSString *)experimentID
                              experimentComponent:(nullable NSString *)experimentComponent
                                     appSectionID:(nullable NSString *)appSectionID
                                           source:(nullable NSString *)source
                                        component:(nullable PeachCollectorContextComponent *)component
                                        contextID:(nullable NSString *)contextID
                                             type:(nullable NSString *)type;
                                   
- (instancetype)initCollectionContextWithItems:(NSArray<NSString *> *)items
                                  experimentID:(nullable NSString *)experimentID
                           experimentComponent:(nullable NSString *)experimentComponent
                                  appSectionID:(nullable NSString *)appSectionID
                                        source:(nullable NSString *)source
                                     component:(nullable PeachCollectorContextComponent *)component
                                     contextID:(nullable NSString *)contextID
                                          type:(nullable NSString *)type;

- (instancetype)initRecommendationContextWithHitIndex:(NSNumber *)hitIndex
                                               itemID:(NSString *)itemID
                                         appSectionID:(nullable NSString *)appSectionID
                                               source:(nullable NSString *)source
                                            component:(nullable PeachCollectorContextComponent *)component
                                            contextID:(nullable NSString *)contextID
                                                 type:(nullable NSString *)type;
                                   
- (instancetype)initRecommendationContextWithItems:(NSArray<NSString *> *)items
                                      appSectionID:(nullable NSString *)appSectionID
                                            source:(nullable NSString *)source
                                         component:(nullable PeachCollectorContextComponent *)component
                                         contextID:(nullable NSString *)contextID
                                              type:(nullable NSString *)type;

- (instancetype)initMediaContextWithID:(NSString *)contextID
                             component:(nullable PeachCollectorContextComponent *)component
                          appSectionID:(nullable NSString *)appSectionID
                                source:(nullable NSString *)source;

- (instancetype)initMediaContextWithID:(NSString *)contextID
                                  type:(NSString *)type
                             component:(nullable PeachCollectorContextComponent *)component
                          appSectionID:(nullable NSString *)appSectionID
                                source:(nullable NSString *)source;

/**
 * Add a custom number field to the context (can be a number or a boolean)
 */
- (void)addNumber:(NSNumber *)number forKey:(nonnull NSString *)key;

/**
 * Add a custom string field to the context
 */
- (void)addString:(NSString *)string forKey:(nonnull NSString *)key;

/**
 * Remove a custom string or number added previously
 * @param key the name of the custom field
 */
- (void)removeCustomField:(nonnull NSString *)key;

/**
 * Retrieve the value of a custom field previously set
 * @param key the name of the custom field
 * @return nil if the key was not found
 */
- (nullable id)valueForCustomField:(nonnull NSString *)key;

/**
 * @return a dictionary representation of the context as defined in the Peach documentation
 */
- (nullable NSDictionary *)dictionaryRepresentation;

@end

NS_ASSUME_NONNULL_END
