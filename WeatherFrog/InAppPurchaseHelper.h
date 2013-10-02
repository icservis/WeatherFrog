//
//  InAppPurchaseHelper.h
//  WeatherFrog.info
//
//  Created by Libor Kučera on 03.06.13.
//  Copyright (c) 2013 IC Servis, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString *const IAPHelperProductPurchasedNotification;

typedef void (^RequestProductsCompletionHandler)(BOOL success, NSArray * products);

@interface InAppPurchaseHelper : NSObject

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers;
- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler;
- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;
- (void)restoreCompletedTransactions;

@end
