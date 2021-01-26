//
//  InAppPurchase.m
//  Brimstone
//
//  @author Janne Heinonen <jjh@iki.fi>
//  @brief Brimstone - 8 April 2015
//  @license MIT

#import <Foundation/Foundation.h>
#import "InAppPurchase.h"
#import "GameScene.h"
#import "GameLogic.h"
#import "MenuLogic.h"

@implementation InAppPurchase

static InAppPurchase* inAppPurchaseInstance;

+(InAppPurchase*)instance
{
    if (inAppPurchaseInstance == nil) {
        inAppPurchaseInstance = [[InAppPurchase alloc] init];
    }
    if (inAppPurchaseInstance.products == nil || inAppPurchaseInstance.products.count == 0) {
        if ([inAppPurchaseInstance isAppPurchased] == NO) {
            NSArray *arr = @[@"Brimstone_Full_Version"];
            [inAppPurchaseInstance validateProductIdentifiers:arr];
        }
    }
    return inAppPurchaseInstance;
}


// Custom method
- (void)validateProductIdentifiers:(NSArray *)productIdentifiers
{
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:[NSSet setWithArray:productIdentifiers]];
    productsRequest.delegate = self;
    [productsRequest start];
}

// SKProductsRequestDelegate protocol method
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.products = response.products;
    [[GameScene menuLogicInstance] updateProductInfo:self.products];
   
//    for (NSString* invalidIdentifier in response.invalidProductIdentifiers) {
//    }
    //[self displayStoreUI]; // Custom method
}

-(void)purchaseApp
{
    if (self.products == nil || self.products.count == 0) {
        NSLog(@"!!! No products to purchase");
        [[GameScene menuLogicInstance] showError:NSLocalizedString(@"Product not found in iTunes Store, please retry later.", nil)];
        return;
    }
    SKProduct *product = [self.products objectAtIndex:0];
    SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
    payment.quantity = 1;
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

-(void)restorePurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

+(NSString*)getFormattedPrice:(SKProduct*)product
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    return formattedPrice;
}

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction* trans in transactions) {
        if (trans.transactionState == SKPaymentTransactionStatePurchased || trans.transactionState == SKPaymentTransactionStateRestored) {
            self.appPurchased = YES;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"appPurchased"];
            [defaults synchronize];

            [[SKPaymentQueue defaultQueue] finishTransaction:trans];
            
            if ([GameScene gameLogicInstance].inAppPurchaseMenuVisible == YES) {
                [[GameScene menuLogicInstance] exitInAppPurchaseMenu];
                
                if ([GameScene gameLogicInstance].selectLevelMenuVisible == YES) {
                    [GameScene gameLogicInstance].currentLevel = [GameScene gameLogicInstance].currentLevel-1;
                    [[GameScene menuLogicInstance] showSelectLevelMenu:[GameScene gameLogicInstance].currentLevel+1];
                }
            }
            return;
        } else if (trans.transactionState == SKPaymentTransactionStateFailed) {
            NSLog(@"!!! Purchase failed");
            NSLog(@"%@", trans.error.description);
            [[SKPaymentQueue defaultQueue] finishTransaction:trans];
            [[GameScene menuLogicInstance] showError:trans.error.localizedDescription];
            
            if ([GameScene sceneInstance].inAppPurchaseButton  != nil) {
                [GameScene menuLogicInstance].inAppPurchaseClicked = NO;
                if ([GameScene sceneInstance].inAppPurchaseButton  != nil) {
                    [GameScene sceneInstance].inAppPurchaseButton.alpha = 1.0;
                }
            }
        }
    }
}

-(Boolean)isAppPurchased
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    Boolean ob = [defaults boolForKey:@"appPurchased"];
    self.appPurchased = ob;
    return self.appPurchased;
}

@end
