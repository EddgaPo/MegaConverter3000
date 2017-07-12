//
//  KNADataClass.m
//  Currency Converter 3000
//
//  Created by Nikolay Koroid on 07/07/2017.
//  Copyright © 2017 Nikolay Koroid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KNADataClass.h"
#import "KNAParserXML.h"

@interface KNADataClass ()
{
    NSMutableString *_pathForRates; //строка со ссылкой URL для финансового сервиса
    
    NSData *_responceData; //указатель на данные полученные от финансового сервиса
    
    KNAParserXML *_parserXML; //указатель на объект KNAParser (делегат NSXMLParser)
    
    NSMutableDictionary *_currencyRatesData; //словарь с курсами валют
}

@end



@implementation KNADataClass : NSObject

#pragma mark Constructor
- (KNADataClass *) init{
    self = [super init]; //конструктор  super класса
    
    if(self){ //успешно?
        
        //URL для финансового сервиса
        _pathForRates = @"https://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20yahoo.finance.xchange%20where%20pair%20in%20(%22USDEUR%22,%20%22USDRUB%22,%20%22EURUSD%22,%20%22EURRUB%22,%20%22RUBUSD%22,%20%22RUBEUR%22)&env=store://datatables.org/alltableswithkeys";
        
        //Инициализация класса для разбора XML
        _parserXML = [[KNAParserXML alloc] init];
        
        //запуск получения курсов от финансового сервиса по URL
        [self getXMLWith:_pathForRates];
        
        
    }
    
    return self; //возвращаем себя
}

- (void) getXMLWith: (NSString *) pathForRates{
    //формируем request и connection
    NSURLRequest *yahooRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:pathForRates]];
    NSURLConnection *yahooConnection = [[NSURLConnection alloc] initWithRequest:yahooRequest delegate:self];
}


#pragma mark - Utilities
//сконвертировать валюту по запросу суммы в начальной валюте
-(NSDecimalNumber *) convertCurencyWith:(NSString *) currencyType ofValue: (NSDecimalNumber *) initialValue{
    //Указатель на сконвертированное значение
    NSDecimalNumber *convertedValue = [[NSDecimalNumber alloc] init];
    
    //Указатель на курс по полученному запросу
    NSDecimalNumber *rateValueDec = [NSDecimalNumber decimalNumberWithString:[_currencyRatesData objectForKey:currencyType]];
    
    //Умножаем сумму в начальной валюте на курс для получения сконвертированно суммы
    convertedValue = [initialValue decimalNumberByMultiplyingBy:rateValueDec];
    
    return convertedValue; //возвращаем сконвертированную сумму
}


#pragma mark NSURLConnection Delegate methods

//получили ответ от сервиса
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(nonnull NSURLResponse *)response{
    _responseData = [[NSMutableData alloc] init]; //выделяем память под ответ от сервиса
    NSLog(@"Recieved responce from yahoo"); //сигнализируем что ответ есть
}

//получили порцию данные
- (void)connection:(NSURLConnection *)connection didReceiveData:(nonnull NSData *)data{
    [_responseData appendData:data]; //собираем данные от сервиса пока не завершится передача
}

//требуется ли кэшировать responce
- (NSCachedURLResponse *)connection:(NSURLConnection *) connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse{
    return nil; //не нужно кэшировать responce
}

//закончили получения данных от сервиса
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    _currencyRatesData = [_parserXML parseXMLtoDict:_responseData]; //начинаем разбор XML от сервиса, на выходе словарь с курсами валют
    NSLog(@"parsed"); //разобрали XML
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    _currencyRatesData = [_parserXML getDefaultRates]; //не получили ответа от сервера, заполняем значениями по умолчанию, курс на начало июля
}

@end
