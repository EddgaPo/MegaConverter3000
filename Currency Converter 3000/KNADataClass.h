//
//  KNADataClass.h
//  Currency Converter 3000
//
//  Created by Nikolay Koroid on 07/07/2017.
//  Copyright © 2017 Nikolay Koroid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KNADataClass : NSObject <NSURLConnectionDelegate>
{
    NSMutableData *_responseData; //указатель на полученные от финансового сервиса данные
}

@property (strong, nonatomic) NSDictionary *currencyRatesData;;

- (KNADataClass *) init; //конструктор
- (void) getXMLWith: (NSString *) pathForRates; //получение данных от финансового сервиса по ссылке

//сконвертировать валюту с запросом в формате "USD/RUB" и определенной суммой
-(NSDecimalNumber *) convertCurencyWith:(NSString *) currencyType ofValue:(NSDecimalNumber *) initialValue;

@end
