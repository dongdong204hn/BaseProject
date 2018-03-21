//
//  URSARC.h
//  URS
//
//  Created by long huihu on 12-8-21.
//  Copyright (c) 2012年 long huihu. All rights reserved.
//

#ifndef URS_URSARC_h
#define URS_URSARC_h

#import <Foundation/Foundation.h>

#ifndef URS_STRONG
#if __has_feature(objc_arc)
#define URS_STRONG strong
#else
#define URS_STRONG retain
#endif
#endif

#ifndef URS_WEAK
#if __has_feature(objc_arc_weak)
#define URS_WEAK weak
#elif __has_feature(objc_arc)
#define URS_WEAK unsafe_unretained
#else
#define URS_WEAK assign
#endif
#endif

#ifndef URS_AUTORELEASE
#if __has_feature(objc_arc)
#define URS_AUTORELEASE(obj) obj
#else
#define URS_AUTORELEASE(obj) [obj autorelease]
#endif
#endif

#ifndef URS_SUPERDEALLOC
#if __has_feature(objc_arc)
#define URS_SUPERDEALLOC
#else
#define URS_SUPERDEALLOC [super dealloc];
#endif
#endif

#ifndef URS_BRIDGE_TRANSFER
#if __has_feature(objc_arc)
#define URS_BRIDGE_TRANSFER __bridge_transfer
#else
#define URS_BRIDGE_TRANSFER
#endif
#endif

#ifndef URS_BRIDGE
#if __has_feature(objc_arc)
#define URS_BRIDGE __bridge
#else
#define URS_BRIDGE
#endif
#endif

#endif
