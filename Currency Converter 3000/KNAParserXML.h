//
//  KNAParserXML.h
//  Currency Converter 3000
//
//  Created by Nikolay Koroid on 08/07/2017.
//  Copyright © 2017 Nikolay Koroid. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KNAParserXML : NSObject <NSXMLParserDelegate> {
    
}

-(KNAParserXML *) init; //конструктор

-(NSDictionary *) parseXMLtoDict: (NSData *) xmlData; //метод для разбора XML в словарь с курсами валют
-(NSDictionary *) getDefaultRates; //метод для получения значений курса на начало июляб если XML не получен

@end
