//
//  UIImage+NIPLoadBundleImage.m
//  NSIP
//
//  Created by zramals on 17/4/10.
//  Copyright © 2017年 netease. All rights reserved.
//

#import "UIImage+NIPLoadBundleImage.h"
#import <objc/runtime.h>

@implementation UIImage (NIPLoadBundleImage)

+ (void)load
{
    Class selfClass = object_getClass([self class]);
    Method originalMethod = class_getInstanceMethod(selfClass, @selector(imageNamed:));
    Method swizzledMethod = class_getInstanceMethod(selfClass, @selector(nip_imageNamed:));
    method_exchangeImplementations(originalMethod, swizzledMethod);
    
}

+ (nullable UIImage *)nip_imageNamed:(NSString *)name
{
    //add ability of load bundle image first
    NSString * bundleName = @"main.bundle";
    NSString * imgName = [NSString stringWithFormat:@"%@",name];
    
    NSString * bundlePath = [[NSBundle mainBundle].resourcePath stringByAppendingPathComponent: bundleName];
    NSBundle * mainBundle = [NSBundle bundleWithPath:bundlePath];
    NSString * imgPath = [mainBundle pathForResource:imgName ofType:@"png"];
    
    UIImage * image;
    static NSString * model;
    
    if (!model) {
        model = [[UIDevice currentDevice] model];
    }
    
    if ([model isEqualToString:@"iPad"]) {
        NSData *imageData = [NSData dataWithContentsOfFile: imgPath];
        image = [UIImage imageWithData:imageData scale:2.0];
    }else{
        image = [UIImage imageWithContentsOfFile: imgPath];
    }
    if (image) {
        NSLog(@"Swizzle # nip_imageNamed");
        return  image;
    }else
    {
        // Forward to primary implementation.
        return [self nip_imageNamed:name];
    }
  
}

@end
