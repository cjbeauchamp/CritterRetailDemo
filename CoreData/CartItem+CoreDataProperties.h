//
//  CartItem+CoreDataProperties.h
//  CritterRetail
//
//  Created by Chris Beauchamp on 10/1/15.
//  Copyright © 2015 Crittercism. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CartItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface CartItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *productID;
@property (nullable, nonatomic, retain) NSString *productName;
@property (nullable, nonatomic, retain) NSString *imageURL;
@property (nullable, nonatomic, retain) NSString *productDescription;
@property (nullable, nonatomic, retain) NSDecimalNumber *productPrice;
@property (nullable, nonatomic, retain) NSNumber *quantity;

@end

NS_ASSUME_NONNULL_END
