//
//  ViewController.h
//  Currency Converter 3000
//
//  Created by Nikolay Koroid on 04/07/17.
//  Copyright © 2017 Nikolay Koroid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *initialCurrency; //начальная валюта

@property (weak, nonatomic) IBOutlet UILabel *convertedCurrency; //целевая валюта

@property (weak, nonatomic) IBOutlet UIPickerView *currencyPicker; //Picker view для выбора валюты

@property (weak, nonatomic) IBOutlet UIView *UIViewWithPicker; //Subview включающий Toolbar и Picker

@property (weak, nonatomic) NSMutableString *userChoicePickerFrom; //для хранения выбора начальной валюты

@property (weak, nonatomic) NSMutableString *userChoisePickerTo; //для хранения выбора целевой валюты

@property (weak, nonatomic) NSMutableString *buttonSummoner; //определяет кто вызвал Picker - целевая или начальная валюты

@property (weak, nonatomic) IBOutlet UIButton *startConvButton; //кнопка для выполнения конвертации

@property (weak, nonatomic) IBOutlet UIButton *buttonCopyToBuf; //кнопка для копировани в буфер

@property (weak, nonatomic) IBOutlet UIButton *buttonFrom; //кнопка для выбора начальной валюты

@property (weak, nonatomic) IBOutlet UIButton *buttonTo; //кнопка для выбора целевой валюты

@property (weak, nonatomic) IBOutlet UITextField *userInput; //поле для ввода суммы в начальной валюте

@property (strong, nonatomic) IBOutlet UIView *wholeScreen; //Вся сцена

@property (weak, nonatomic) IBOutlet UIButton *hideKeyboardButton; //кнопка для закрытия окна с клавиатурой

@property (weak, nonatomic) IBOutlet UILabel *sumResult; //сумма в целевой валюте

@end

