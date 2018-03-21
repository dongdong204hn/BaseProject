//
//  NIPVersionUpdater.h
//  NSIP
//
//  Created by 赵松 on 16/12/8.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPAction.h"

typedef void (^SimpleCompletionBlock)(void);

@interface NIPVersionUpdater : NIPAction

@property (nonatomic,strong) NSString   *maxVersion;
@property (nonatomic,strong) NSString   *minVersion;
@property (nonatomic,strong) NSString   *inVersion;
@property (nonatomic,strong) NSString   *itunesUrl;
@property (nonatomic,strong) NSString   *desc;
@property (nonatomic,strong) NSString   *serverTime;
@property (nonatomic,assign) BOOL silently;
@property (nonatomic,copy) SimpleCompletionBlock actionCompletionBlock;

+ (void)checkVersion:(BOOL)silently withUrlString:(NSString*)urlString withCompletion:(SimpleCompletionBlock)block;

@end
