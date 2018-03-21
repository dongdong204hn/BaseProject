//
//  NIPActionSheet.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPActionSheet.h"


@interface NIPActionSheet()

@property (nonatomic,strong) id sheetObject;

@end

@implementation NIPActionSheet

@synthesize dismissBlock=_dismissBlock;


- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
    NSMutableArray *otherButtonTitlesArray = [NSMutableArray array];
    if (otherButtonTitles) {
        [otherButtonTitlesArray addObject:otherButtonTitles];
        va_list otherButtonTitleArgList;
        va_start(otherButtonTitleArgList, otherButtonTitles);
        NSString *title = va_arg(otherButtonTitleArgList, typeof(NSString*));
        while (title) {
            [otherButtonTitlesArray addObject:title];
            title = va_arg(otherButtonTitleArgList, typeof(NSString*));
        }
        va_end(otherButtonTitleArgList);
    }
    NIPActionSheet *actionSheet = [[NIPActionSheet alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle andButtons:otherButtonTitlesArray];
    
    return actionSheet;
}

- (id)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle  andButtons:(NSArray*)buttons {
    NIPActionSheet *actionSheet = [[NIPActionSheet alloc] initWithTitle:title cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:nil andButtons:buttons];
    
    return actionSheet;
}

- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle andButtons:(NSArray*)buttons {
    self = [super init];
    if (self) {
        if ([UIAlertController class]) { //ios8 or later
            self.sheetObject = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            if (cancelButtonTitle) {
                [self addActionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel andButtonIndex:0];
            }
            if (destructiveButtonTitle) {
                [self addActionWithTitle:destructiveButtonTitle style:UIAlertActionStyleDestructive andButtonIndex:1];
            }
            if (buttons.count) {
                [buttons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self addActionWithTitle:obj style:UIAlertActionStyleDefault andButtonIndex:idx +2];
                }];
            }
        } else{
            self.sheetObject = [[UIActionSheet alloc] initWithTitle:title
                                                           delegate:(id<UIActionSheetDelegate>)self cancelButtonTitle:cancelButtonTitle destructiveButtonTitle:destructiveButtonTitle otherButtonTitles:nil];
            [self performSelector:@selector(timeout) withObject:nil afterDelay:600];//这里是防止arc 自动把本类释放，delegate回调会成nil，造成崩溃
            if  (buttons) {
                [buttons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [self.sheetObject addButtonWithTitle:obj];
                }];
            }
        }
    }
    return self;
}

- (void)setDismissBlock:(ActionSheetBlock)dismissBlock {
    _dismissBlock = [dismissBlock copy];
}

- (void)timeout {
    if (![UIAlertController class]) { //alertview需要特殊处理
        UIActionSheet *actionSheet = (UIActionSheet *)self.sheetObject;
        actionSheet.delegate = nil;
        [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:NO];
        actionSheet = nil;
        [[self class]  cancelPreviousPerformRequestsWithTarget:self];
    }
}

- (void)addActionWithTitle:(NSString*)title style:(UIAlertActionStyle)actionStyle andButtonIndex:(NSInteger)buttonIndex{
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:title
                                                            style:actionStyle
                                                          handler:^(UIAlertAction * action) {
                                                              if (self.dismissBlock) {
                                                                  self.dismissBlock(buttonIndex);
                                                              }
                                                              self.sheetObject = nil;
                                                          }];
    [self.sheetObject addAction:defaultAction];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.dismissBlock) {
        self.dismissBlock(buttonIndex);
    }
}

- (void)showInController:(UIViewController *)controller {
    if ([UIAlertController class]) {
        [controller presentViewController:self.sheetObject animated:YES completion:nil];
    } else {
        if (controller.tabBarController.tabBar) {
            [self.sheetObject showFromTabBar:controller.tabBarController.tabBar];
        } else {
            [self.sheetObject showInView:controller.view];
        }
    }
}


@end
