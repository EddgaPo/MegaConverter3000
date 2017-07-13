//
//  ViewController.m
//  Currency Converter 3000
//
//  Created by Nikolay Koroid on 04/07/17.
//  Copyright © 2017 Nikolay Koroid. All rights reserved.
//

#import "ViewController.h"
#import "KNADataClass.h"

@interface ViewController ()
{
    NSArray *_pickerArray; //список валют в Picker View
    NSDictionary *_currencyTypes; //Словарь для установки начального значения при открытии  Picker view
    NSDecimalNumber *_sumInitial; //Переменная для хранения введенной суммы в формате NSDecimalNumber
    NSDecimalNumberHandler *_behaviorDec; //правило округления до 2 знаков арифметическое
    NSDecimalNumberHandler *_behaviorDecDown; //правило округления до 2 знаков вниз
    KNADataClass *_currencyData; //Класс для работы с данными о курсах валют
    Boolean _buttonPressed; //для отслеживания запоздания в работе Picker view
}
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Инициализация массива доступных значений для валют
    _pickerArray = [[NSArray alloc]initWithObjects:@"USD", @"EUR", @"RUB", nil];
    
    //Инициализация словаря для установки валюты при открытии Picker View
    _currencyTypes = [NSDictionary dictionaryWithObjectsAndKeys:
                      [NSNumber numberWithInt:0], @"USD",
                      [NSNumber numberWithInt:1], @"EUR",
                      [NSNumber numberWithInt:2], @"RUB",
                      nil];
    
    //Связь с элементом Picker View (в рамках текущего класса описана реализация делегатов для Picker View
    _currencyPicker.dataSource = self;
    _currencyPicker.delegate = self;
    
    //скрываем Picker View пока он не будет вызван
    _UIViewWithPicker.hidden = true;
    
    //устанавливаем начальные значения начальной и целевой валюты
    _initialCurrency.text = @"USD";
    _convertedCurrency.text = @"RUB";
    
    //устанавливаем, что на данный момент не происходит выбора валюты
    _buttonSummoner = @"none";
    _buttonPressed = false;
    
    //добавляем наблюдателя за событием UIKeyboardDidShowNotification
    //это нужно для того чтоб после появления клавиатуры для ввода отключить остальные элементы UI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardDidShowNotification object:nil];
    
    //инициализируем класс для получения и расчета курсов валют
    _currencyData = [[KNADataClass alloc] init];
    
    //инициализируем правила округления
    _behaviorDec = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain
                                                                       scale:2
                                                            raiseOnExactness:NO
                                                             raiseOnOverflow:NO
                                                            raiseOnUnderflow:NO
                                                         raiseOnDivideByZero:NO];
    _behaviorDecDown = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundDown
                                                                          scale:2
                                                               raiseOnExactness:NO
                                                                raiseOnOverflow:NO
                                                               raiseOnUnderflow:NO
                                                            raiseOnDivideByZero:NO];
    
    //выполняем отключение элементов UI, которые не должны быть активны при запуске приложения
    _hideKeyboardButton.userInteractionEnabled = false;
    _startConvButton.userInteractionEnabled = false;
    _buttonCopyToBuf.userInteractionEnabled = true;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Picker view delegates
- (int)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1; //в нашем Picker View всего один столбец
}

- (int)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return (int)_pickerArray.count; //возвращаем количество элементов в столбце Picker View
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return _pickerArray[row];//возвращаем название элементов в PickerView
}

//данные метод вызывается при выборе элемента в Picker View
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *tempStringForCurrency = _pickerArray[row]; //указатель на выбранное значение
    if ([_buttonSummoner isEqualToString: @"From"]){ //если пользователь выбирает начальную валюту
        _userChoicePickerFrom = tempStringForCurrency; //присваиваем Label начальной валюты выбранное значение Picker View
        if(_buttonPressed){
            _initialCurrency.text = _userChoicePickerFrom;
        }
    }
    if ([_buttonSummoner isEqualToString: @"To"]){ //если пользователь выбирает целевую валюту
        _userChoisePickerTo = tempStringForCurrency; //присваиваем Label целевой валюты выбранное значение Picker View
        if(_buttonPressed) {
            _convertedCurrency.text = _userChoisePickerTo;
        }
    }
    _buttonPressed = false;
}


#pragma mark - actions for choosing currency
//пользователь хочет выбрать начальную валюту
- (IBAction)userChoiceFrom:(id)sender {
    [self.view endEditing:YES]; //на случай если открыта клавиатура
    _buttonSummoner = @"From"; //вызов Picker View будет со стороны начальной валюты
    _buttonPressed = false;
    
    //устанавливаем начальное значение Picker View в соответствии с указанной в UI начальной валютой
    [_currencyPicker selectRow:[[_currencyTypes objectForKey:_initialCurrency.text] intValue] inComponent:0 animated:NO];
    
    _UIViewWithPicker.hidden = false; //показываем Picker View
    
    //отключаем взаимодействие с другими элементами, скрываем не нужные
    _buttonTo.userInteractionEnabled = false;
    _buttonFrom.userInteractionEnabled = false;
    _startConvButton.userInteractionEnabled = false;
    _userInput.userInteractionEnabled = false;
    _buttonCopyToBuf.userInteractionEnabled = false;
    _buttonCopyToBuf.hidden = true;
}

//пользователь хочет выбрать целевую валюту
- (IBAction)userChoiceTo:(id)sender {
    [self.view endEditing:YES]; //на случай если открыта клавиатура
    _buttonSummoner = @"To"; //вызов Picker View со стороны целевой валюты
    _buttonPressed = false;
    
    //устанавливаем начальное значение Picker View в соответствии с указанной в UI целевой валютой
    [_currencyPicker selectRow:[[_currencyTypes objectForKey:_convertedCurrency.text] intValue] inComponent:0 animated:NO];
    
    _UIViewWithPicker.hidden = false;//показываем Picker View
    
    //отключаем взаимодействие с другими элементами? скрываем не нужные
    _buttonTo.userInteractionEnabled = false;
    _buttonFrom.userInteractionEnabled = false;
    _startConvButton.userInteractionEnabled = false;
    _userInput.userInteractionEnabled = false;
    _buttonCopyToBuf.userInteractionEnabled = false;
    _buttonCopyToBuf.hidden = true;
}

#pragma mark - toolbar of Picker view actions
//нажата кнопка выбора на Toolbar для Picker View
- (IBAction)pressedDone:(id)sender {
    _buttonPressed = true;
    if([_buttonSummoner isEqualToString: @"From"]){ //вызов был со стороны начальной валюты?
        _initialCurrency.text = _userChoicePickerFrom; //обновляем Label начальной валюты
    }
    if([_buttonSummoner isEqualToString: @"To"]){ // вызов был со стороны целевой валюты?
        _convertedCurrency.text = _userChoisePickerTo; //обновляем Label целевой валюты
    }
    
    _UIViewWithPicker.hidden = true; //скрываем Picker View

    
    //включаем взаимодействие с остальными элементами, отображаем их если скрыли
    _buttonTo.userInteractionEnabled = true;
    _buttonFrom.userInteractionEnabled = true;
    _startConvButton.userInteractionEnabled = true;
    _userInput.userInteractionEnabled = true;
    _buttonCopyToBuf.userInteractionEnabled = true;
    _buttonCopyToBuf.hidden = false;
}

//нажата кнопка отмены на Toolbar для Picker View
- (IBAction)pressedCancel:(id)sender {
    _UIViewWithPicker.hidden = true; //скрываем Picker View

    
    //включаем взаимодействие с остальными элементами, отображаем их если скрыли
    _buttonTo.userInteractionEnabled = true;
    _buttonFrom.userInteractionEnabled = true;
    _startConvButton.userInteractionEnabled = true;
    _userInput.userInteractionEnabled = true;
    _buttonCopyToBuf.userInteractionEnabled = true;
    _buttonCopyToBuf.hidden = false;
}


#pragma mark - actions to hide keyboard for textfield
//Метод слушает наступление события UIKeyboardDidShowNotification
- (void)keyboardWillShow:(NSNotification*)aNotification{
    _hideKeyboardButton.userInteractionEnabled = true; //активируем кнопку для скрытия клавиатуры
    
    //отключаем взаимодействие с остальными элементами
    _buttonTo.userInteractionEnabled = false;
    _buttonFrom.userInteractionEnabled = false;
    _startConvButton.userInteractionEnabled = false;
    _buttonCopyToBuf.userInteractionEnabled = false;
}

//Нажата кнопка для скрытия клавиатуры (срабатывает при нажатии экрана в любом месте кроме клавиатуры)
- (IBAction)hideKeyboard:(id)sender {
    NSString *userInputWithPeriod = [_userInput.text stringByReplacingOccurrencesOfString:@"," withString:@"."]; //считываем ввод пользователя и заменяем "," на "." если нашли
    
    //Иницилизируем введенную пользователем сумму в формате NSDecimalNumber
    NSDecimalNumber *sumTemp = [NSDecimalNumber decimalNumberWithString: userInputWithPeriod];
    
    //округляем до двух знаков после запятой по правилу арифметики
    _sumInitial = [sumTemp decimalNumberByRoundingAccordingToBehavior:_behaviorDec];
    
    //если пользователь так ничего и не ввел - указываем 0
    if(isnan([_sumInitial floatValue])){
        _userInput.text = @"0";
        _sumInitial = [NSDecimalNumber decimalNumberWithString:@"0"];
    }
    
    _hideKeyboardButton.userInteractionEnabled = false; //отключаем кнпоку скрытия клавиатуры
    
    //включаем взаимодействие с остальными элементами
    _buttonTo.userInteractionEnabled = true;
    _buttonFrom.userInteractionEnabled = true;
    _startConvButton.userInteractionEnabled = true;
    _buttonCopyToBuf.userInteractionEnabled = true;
    [self.view endEditing:YES];// скрываем клавиатуру
}


#pragma mark - action to convert currency
//пользователь нажал кнопку "Сконвертировать валюту"
- (IBAction)startConvertion:(id)sender {
    
    //формируем ключ вида "USD/RUB" для вызова конвертации
    NSString *fromString = [NSString stringWithString:_initialCurrency.text];
    NSString *fromStringWithSep = [fromString stringByAppendingString:@"/"];
    NSString *requestString = [fromStringWithSep stringByAppendingString:_convertedCurrency.text];
    
    //Вызываем метод инстанса класса KNADataClass для расчета сконвертированной суммы
    NSDecimalNumber *convertedValueDec = [[_currencyData convertCurencyWith:requestString ofValue:_sumInitial] decimalNumberByRoundingAccordingToBehavior:_behaviorDecDown];
    
    //получили результат, обновляем Label для сконвертированной суммы
    if(convertedValueDec) {
        _sumResult.text = [convertedValueDec stringValue];
    }
}

//пользователь нажал кнопку "Скопировать в буфер"
- (IBAction)copyToPasteBoard:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard]; //указатель на Pasteboard
    [pasteboard setString:_sumResult.text]; //копируем в Pasteboard сконвертированную сумму
}

@end
