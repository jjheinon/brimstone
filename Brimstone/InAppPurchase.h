//
//  InAppPurchase.h
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#ifndef Brimstone_InAppPurchase_h
#define Brimstone_InAppPurchase_h

#import <StoreKit/StoreKit.h>

@interface InAppPurchase : NSObject 
<SKProductsRequestDelegate, SKPaymentTransactionObserver>

+(InAppPurchase*)instance;

- (void)validateProductIdentifiers:(NSArray *)productIdentifiers;

-(void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response;

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions;

-(void)purchaseApp;
-(void)restorePurchases;

+(NSString*)getFormattedPrice:(SKProduct*)product;
-(Boolean)isAppPurchased;

@property NSArray* products;
@property Boolean appPurchased;

@end

#endif
