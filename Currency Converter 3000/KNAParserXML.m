//
//  KNAParserXML.m
//  Currency Converter 3000
//
//  Created by Nikolay Koroid on 08/07/2017.
//  Copyright © 2017 Nikolay Koroid. All rights reserved.
//

#import "KNAParserXML.h"

@implementation KNAParserXML{
    NSMutableDictionary *_ratesDictionary; //словарь с курсами валют
    NSString *_rateName; //позиция XML которой заканчивается блок данных
    NSString *_currentEleName; //позиция с названием курса в формате "USD/RUB"
    NSString *_currentEleValue; //позиция со значение курса
    NSString *_tempNameEle; //для временного хранения названия курса при разборе XML
    NSString *_tempRateEle; //для временного хранения значения курса при разборе XML
    NSXMLParser *parserXML; //объект NSXMLParser
}

//конструктор
- (KNAParserXML *) init{
    self = [super init];
    return self;
}

//Разобрать XML в словарь с курсами валют
-(NSDictionary *) parseXMLtoDict: (NSData *) xmlData{
    parserXML = [[NSXMLParser alloc] initWithData:xmlData]; //инициализация объекта NSXMLParser
    parserXML.delegate = self; //указываем данный класс делегатом
    _currentEleName = [[NSString alloc] init]; //выделяем место под название текущего элемента
    [parserXML parse]; //запускаем разбор XML
    if([_ratesDictionary count] != 0){ //успешно разобрали?
        NSLog(@"parsed successessfully"); //отмечаем успех
    } else{
        NSLog(@"something went wrong"); //отмечаем провал
    }
    
    //добавляем в словарь курсов валют значение когда начальная и целевая валюта совпадает
    [_ratesDictionary setObject: @"1" forKey:@"USD/USD"];
    [_ratesDictionary setObject: @"1" forKey:@"EUR/EUR"];
    [_ratesDictionary setObject: @"1" forKey:@"RUB/RUB"];
    
    return _ratesDictionary;//возвращаем словарь с курсами валют
}

//Заполнить словарь с курсами валют значениями по умолчанию (курсы на начало июля)
-(NSDictionary *) getDefaultRates {
    _ratesDictionary = [[NSMutableDictionary alloc] init]; //выделяем место под словарь с курсами валют
    
    //Добавляем в словарь значения по умолчанию
    [_ratesDictionary setObject: @"0.8769" forKey:@"USD/EUR"];
    [_ratesDictionary setObject: @"60.3550" forKey:@"USD/RUB"];
    [_ratesDictionary setObject: @"1.1398" forKey:@"EUR/USD"];
    [_ratesDictionary setObject: @"68.6470" forKey:@"EUR/RUB"];
    [_ratesDictionary setObject: @"0.0165" forKey:@"RUB/USD"];
    [_ratesDictionary setObject: @"0.0145" forKey:@"RUB/EUR"];
    [_ratesDictionary setObject: @"1" forKey:@"USD/USD"];
    [_ratesDictionary setObject: @"1" forKey:@"EUR/EUR"];
    [_ratesDictionary setObject: @"1" forKey:@"RUB/RUB"];
    
    return _ratesDictionary; //возвращаем словарь с курсами валют
}

#pragma mark - NSXMLParser delegate methods
//начали разбор XML
-(void)parserDidStartDocument:(NSXMLParser *)parser{
    _ratesDictionary = [[NSMutableDictionary alloc] init];//выделяем память под словарь с курсами
}

//Обработчик ощибок при разборе
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError{
    NSLog(@"%@", [parseError localizedDescription]); //пишем в лог описание ошибки
}

//Начало обработки элемента при разборе
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict{
    _currentEleName = elementName; //для каждого обрабатываемого элемента сохраняем его имя
}

//окончание обработки элемента при разборе
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName{
    
    if ([elementName isEqualToString:@"rate"]) { //это конец блока с данными об одном из курсов валют?
        [_ratesDictionary setObject: _tempRateEle forKey:_tempNameEle]; //добавляем значение курса в словарь
        
        //обнуляем переменные
        _tempRateEle = @"";
        _tempNameEle = @"";
    }
    else if ([elementName isEqualToString:@"Name"]){ //мы нашли название курса?
        _tempNameEle = [[NSString alloc] initWithString:_currentEleValue]; //сохраняем название курса
        
    }
    else if ([elementName isEqualToString:@"Rate"]){//мы нашли значение курса?
        _tempRateEle = [[NSString alloc] initWithString:_currentEleValue]; //созраняем значение курса
    }
    
    _currentEleName = @""; //обнуляем название элемента
}


//При обработке элемента найдено значение
-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    //обрабатываемый в данный момент элемент "Name" или "Rate"?
    if ([_currentEleName isEqualToString:@"Name"] || [_currentEleName isEqualToString:@"Rate"]) {
        if (![string isEqualToString:@"\n"]) { // его значение не перевод строки?
            _currentEleValue = string;//тогда сохраняем его значение
        }
    }
}

@end
