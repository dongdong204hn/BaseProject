//
//  NSURL+NIPBasicAdditions.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NSURL+NIPBasicAdditions.h"
#import "NSString+NIPBasicAdditions.h"

@implementation NSURL (NIPBasicAdditions)


- (NSURL *)urlByRemoveQuery
{
    if(![self host] || ![self query])
        return self;
    
    return [self urlByRemoveAbsoluteSubString:[NSString stringWithFormat:@"?%@", [self query]]];
}

- (BOOL)isEquivalent:(NSURL *)aURL {
    if ([self isEqual:aURL])
        return YES;
    
    if ([self host]) {
        if ([[self host] caseInsensitiveCompare:[aURL host]] != NSOrderedSame)
            return NO;
    }
    else {
        if ([aURL host]) {
            return NO;
        }
    }
    
    NSString * scheme1 = [self scheme];
    NSString * scheme2 = [aURL scheme];
    if (scheme1) {
        if ([scheme1 caseInsensitiveCompare:scheme2] != NSOrderedSame)
            return NO;
    }
    else {
        if (scheme2) {
            return NO;
        }
    }
    
    NSString * s1 = self.path;
    NSString * s2 = aURL.path;
    if (s1) {
        if ([s1 hasSuffix:@"/"]) {
            s1 = [s1 substringToIndex:s1.length - 1];
        }
        if ([s2 hasSuffix:@"/"]) {
            s2 = [s2 substringToIndex:s2.length - 1];
        }
        if ([s1 compare:s2] != NSOrderedSame) {
            return NO;
        }
    }
    else {
        if (s2) {
            return NO;
        }
    }
    
    // at this point, we've established that the urls are equivalent according to the rfc
    // insofar as scheme, host, and paths match
    
    // according to rfc2616, port's can weakly match if one is missing and the
    // other is default for the scheme, but for now, let's insist on an explicit match
    if ([self port]) {
        if ([[self port] compare:[aURL port]] != NSOrderedSame)
            return NO;
    }
    else {
        if ([aURL port]) {
            return NO;
        }
    }
    
    if ([self query]) {
        if ([[self query] compare:[aURL query]] != NSOrderedSame)
            return NO;
    }
    else {
        if ([self query]) {
            return NO;
        }
    }
    
    // for things like user/pw, fragment, etc., seems sensible to be
    // permissive about these.  (plus, I'm tired :-))
    return YES;
}

- (NSURL *)urlByAppendQuery:(NSDictionary *)parameter
{
    if (!parameter || parameter.count == 0) {
        return self;
    }
    
    NSMutableDictionary * mergedParameter = [[self parametersDictionary] mutableCopy];
    if (!mergedParameter) {
        mergedParameter = [[NSMutableDictionary alloc] init];
    }
    
    for (id key in parameter) {
        if (parameter[key]) {
            mergedParameter[key] = parameter[key];
        }
    }
    
    if (mergedParameter.count == 0) {
        return self;
    }
    
    NSString * scheme = [self scheme];
    
    NSString * host = [self host];
    if ([self port]) {
        host = [NSString stringWithFormat:@"%@:%@", host, [self port]];
    }
    
    NSString * path = [self path];
    if (!path || path.length == 0) {
        path = @"/";
    }
    
    NSURL * temp = [[NSURL alloc] initWithScheme:scheme host:host path:path];
    NSString * str = [NSString stringWithFormat:@"%@?", [temp absoluteString]];
    
    for (id key in mergedParameter) {
        if ([[str substringFromIndex:(str.length - 1)] isEqualToString:@"?"]) {
            str = [str stringByAppendingString:[NSString stringWithFormat:@"%@=%@",
                                                [key encodeUTF8],
                                                [[mergedParameter[key] description] encodeUTF8]]];
        }
        else {
            str = [str stringByAppendingString:[NSString stringWithFormat:@"&%@=%@",
                                                [key encodeUTF8],
                                                [[mergedParameter[key] description] encodeUTF8]]];
        }
    }
    
    // fragment
    NSString * fragment = [self fragment];
    if (fragment && fragment.length > 0) {
        str = [NSString stringWithFormat:@"%@#%@", str, fragment];
    }
    
    return [NSURL URLWithString:str];
}

- (NSDictionary *)parametersDictionary
{
    NSString *paramString = nil;
    NSArray *array = [self.resourceSpecifier componentsSeparatedByString:@"?"];
    if ([array count] > 1) {
        paramString = [array objectAtIndex:1];
    }
    
    NSArray *components = [paramString componentsSeparatedByString:@"&"];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:3];
    
    for (NSString *pair in components) {
        NSArray *pairArray = [pair componentsSeparatedByString:@"="];
        if ([pairArray count] == 2) {
            NSString *key = [pairArray objectAtIndex:0];
            NSString *value = [pairArray objectAtIndex:1];
            value = [value URLDecodedString];
            [param setObject:value forKey:key];
        }
    }
    return param;
}

- (NSArray *)getPathComponents
{
    NSArray *array = [self.resourceSpecifier componentsSeparatedByString:@"?"];
    if ([array count] > 0) {
        NSString *pathString = [array objectAtIndex:0];
        pathString = [pathString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/ "]];
        return [pathString componentsSeparatedByString:@"/"];
    }
    return nil;
}

#pragma mark -

- (NSURL *)urlByRemoveAbsoluteSubString:(NSString *)subString
{
    NSString * str = [self absoluteString];
    NSRange range = [str rangeOfString:subString];
    if (range.location == NSNotFound) {
        return self;
    }
    
    NSString * str1 = [str substringToIndex:range.location];
    NSString * str2 = [str substringFromIndex:(range.location + range.length)];
    NSString * str3 = [str1 stringByAppendingString:str2];
    NSURL * url = [NSURL URLWithString:str3];
    
    return url;
}
@end
