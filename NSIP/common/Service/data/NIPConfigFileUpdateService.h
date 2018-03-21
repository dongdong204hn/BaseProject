//
//  NIPConfigFileUpdateService.h
//  NSIP
//
//  Created by Eric on 16/9/23.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import <Foundation/Foundation.h>


#define NSIP_CONFIG_FILE_UPDATE_NOTIFICATION  @"NSIP_config_file_update_notification"
#define NSIP_CONFIG_NOTIFICATION_KEYWORD  @"NSIP_config_file_notification_keyword_field"

#define PROMPT_TEXT_KEY      @"promptText.json"       //存储各类提示信息
#define GLOBAL_TEXT_KEY      @"globalText.json"       //客户端文案
#define PAGE_URL_INFO_KEY    @"PageURLsInfo.json"     //页面url信息

@interface NIPConfigFileUpdateService : NSObject

@property (nonatomic, strong) NSString *promptTextFilePath;
@property (nonatomic, strong) NSString *globalTextFilePath;
@property (nonatomic, strong) NSString *pageURLsInfoFilePath;

+ (instancetype)sharedService;


- (void)checkUpdate;


@end
