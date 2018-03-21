//
//  NSString+NIPBasicAdditions.m
//  NSIP
//
//  Created by 赵松 on 16/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NSString+NIPBasicAdditions.h"
#import "NSData+NIPBasicAdditions.h"
#import <CommonCrypto/CommonDigest.h>
#import "nip_macros.h"

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation NSString (NIPBasicAdditions)

- (NSComparisonResult)compareNumerically:(NSString*) anotherString withSepateString:(NSString *)separate
{
    if (self.length == 0 && anotherString.length == 0)
    {
        return NSOrderedSame;
    }
    else if (self.length == 0)
    {
        return NSOrderedAscending;
    }
    else if (anotherString.length == 0)
    {
        return NSOrderedDescending;
    }
    
    NSArray *array1 = [self componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString: separate]];
    NSArray *array2 = [anotherString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString: separate]];
    int i = 0;
    
    for(; i < array1.count && i < array2.count; i++)
    {
        int res = [array1[i] intValue] - [array2[i] intValue];
        if(res != 0)
        {
            if(res > 0)
                return NSOrderedDescending;
            else
                return NSOrderedAscending;
        }
    }
    
    if(array1.count == array2.count)
    {
        return NSOrderedSame;
    }
    else if(i == array1.count)
    {
        for(int j=i; j<array2.count; j++)
        {
            if([array2[j] intValue] != 0)
            {
                return NSOrderedAscending;
            }
        }
        return NSOrderedSame;
    }
    else
    {
        for(int j=i; j<array1.count; j++)
        {
            if ([array1[j] intValue] != 0)
            {
                return NSOrderedDescending;
            }
        }
        return NSOrderedSame;
    }
}

+ (NSString *)localizedStringForKey:(NSString *)key
{
	return [[[NSBundle mainBundle] localizedInfoDictionary] objectForKey:key];
}

- (BOOL)containsSubstring:(NSString *)substring
{
    if (substring.length == 0) {
        return YES;
    }
    return [self rangeOfString:substring].length > 0;
}

- (BOOL)isWhitespaceAndNewlines
{
	NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
	for (NSInteger i = 0; i < self.length; ++i) {
		unichar c = [self characterAtIndex:i];
		if (![whitespace characterIsMember:c]) {
			return NO;
		}
	}
	return YES;
}

- (BOOL)isEmptyOrWhitespace
{
	return !self.length ||
	![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (BOOL)isEmailAddress {
    NSString *EMAIL = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", EMAIL];
    return [regextestmobile evaluateWithObject:self];
}

- (BOOL)isMatchRegex:(NSString *)regex {
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [regextestmobile evaluateWithObject:self];
}

- (BOOL)isMobileNumber {
    NSString *MOBILE = @"^1[0-9]{10}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:self];
}

- (BOOL)isAccountName {
    NSString *account = @"^[a-zA-Z][a-zA-Z0-9_]{5,29}$";
    NSPredicate *regexName= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", account];
    return [regexName evaluateWithObject:self];
}

- (BOOL)isAccountPwd {
    NSString *account = @"^(\\w*((?=\\w*\\d)(?=\\w*[a-zA-Z])|(?=\\w*\\d)(?=\\w*_)|(?=\\w*_)(?=\\w*[a-zA-Z]))\\w*)(\\w{6,25})$";
    NSPredicate *regex = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", account];
    return [regex evaluateWithObject:self];
}

- (BOOL)isPersonName {
    NSString *account = @"^([\u4e00-\u9fa5]{2,5})|([a-zA-Z]+(?=[a-zA-Z\\s.]*[a-zA-Z]+)[a-zA-Z\\s.]{1,}[a-zA-Z.]{1,})$";
    NSPredicate *regexName= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", account];
    return [regexName evaluateWithObject:self];
}

- (BOOL)isChineseWord {
    NSString *account = @"^([\u4e00-\u9fa5]+)$";
    NSPredicate *regexName= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", account];
    return [regexName evaluateWithObject:self];
}

- (BOOL)isIdentityCard {
    //正则校验
    NSString *identity = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    NSPredicate *regextest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", identity];
    
    //按位精准校验
    if([regextest evaluateWithObject:self]){ //如果正则表达式匹配的话
        if(self.length==18){
            NSArray *idCardWi = @[@7, @9, @10, @5, @8, @4, @2, @1, @6, @3, @7, @9, @10, @5, @8, @4, @2]; //将前17位加权因子保存在数组里
            NSArray *idCardY = @[@1, @0, @10, @9, @8, @7, @6, @5, @4, @3, @2]; //这是除以11后，可能产生的11位余数、验证码，也保存成数组
            NSInteger idCardWiSum = 0; // 用来保存前17位各自乖以加权因子后的总和
            NSNumber *wiNumber;
            for(NSInteger i=0; i<17; i++){
                wiNumber = idCardWi[i];
                idCardWiSum += [self substringWithRange:NSMakeRange(i, 1)].integerValue * wiNumber.integerValue;
            }
            
            NSInteger idCardMod = idCardWiSum%11;//计算出校验码所在数组的位置
            NSString *idCardLast = [self substringFromIndex:17];//得到最后一位身份证号码
            
            //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
            if(idCardMod == 2){
                if([idCardLast isEqualToString:@"X"] || [idCardLast isEqualToString:@"x"]){
                    return YES;
                }else{
                    return NO;
                }
            }else{
                //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
                if([idCardLast isEqualToString:[NSString stringWithFormat:@"%@", idCardY[idCardMod]]]){
                    return YES;
                }else{
                    return NO;
                }
            }
            
        }
    }
    
    return NO;
}


- (BOOL)isMaleByIdentityCard {
    NSString *maleString = [self substringWithRange:NSMakeRange(self.length - 2, 1)];
    if (maleString.integerValue % 2 == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)isImageFileName {
    NSString *pngName = @"^[\\s\\S]*.((bmp)|(dib)|(gif)|(jfif)|(jpe)|(jpeg)|(jpg)|(png)|(tif)|(tiff)|(ico))[\\s\\S]*$";
    NSPredicate *regexName= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pngName];
    return [regexName evaluateWithObject:self];
}

- (BOOL)isPostalCode {
    NSString *regex = @"^[1-9]\\d{5}$";
    NSPredicate *regexName= [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [regexName evaluateWithObject:self];
}


/**
 Returns a percent-escaped string following RFC 3986 for a query string key or value.
 RFC 3986 states that the following characters are "reserved" characters.
 - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
 - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
 
 In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
 query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
 should be percent-escaped in the query string.
 - parameter string: The string to be percent-escaped.
 - returns: The percent-escaped string.
 */
- (NSCharacterSet *)getNormalAllowedURLCharacterSet
{
    static NSString * const kNTURLCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kNTURLCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    
    NSMutableCharacterSet * normalAllowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [normalAllowedCharacterSet removeCharactersInString:[kNTURLCharactersGeneralDelimitersToEncode stringByAppendingString:kNTURLCharactersSubDelimitersToEncode]];
    
    return normalAllowedCharacterSet;
}

- (NSString *)URLEncodedString
{
    NSCharacterSet *allowedCharacterSet = [self getNormalAllowedURLCharacterSet];
    return [self URLEncodedStringWithAllowdCharacters:allowedCharacterSet];
}

- (NSString *)URLEncodedStringLeaveUnescapedCharacterSet:(NSCharacterSet *)UnescapedCharacterSet {
    NSMutableCharacterSet *allowedCharacterSet = [[self getNormalAllowedURLCharacterSet] mutableCopy];
    [allowedCharacterSet formUnionWithCharacterSet:UnescapedCharacterSet];
    
    return [self URLEncodedStringWithAllowdCharacters:allowedCharacterSet];
}

- (NSString *)URLEncodedStringWithAllowdCharacters:(NSCharacterSet *)allowedCharacterSet {
    // 分批处理，字符串过长可能引起编码失败
    static NSUInteger const batchSize = 50;
    
    NSUInteger index = 0;
    NSMutableString *encodedString = @"".mutableCopy;
    
    while (index < self.length) {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wgnu"
        NSUInteger length = MIN(self.length - index, batchSize);
#pragma GCC diagnostic pop
        NSRange range = NSMakeRange(index, length);
        
        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [self rangeOfComposedCharacterSequencesForRange:range];
        
        NSString *substring = [self substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [encodedString appendString:encoded];
        
        index += range.length;
    }
    
    return encodedString;
}

- (NSString *)URLDecodedString
{
    NSString *result = [self stringByRemovingPercentEncoding];

	return result;
}


- (NSString *)escapeHTML
{
	NSMutableString *s = [NSMutableString string];
	
	NSInteger start = 0;
	NSUInteger len = [self length];
	NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"<>&\""];
	
	while (start < len) {
		NSRange r = [self rangeOfCharacterFromSet:chs options:0 range:NSMakeRange(start, len - start)];
		if (r.location == NSNotFound) {
			[s appendString:[self substringFromIndex:start]];
			break;
		}
		
		if (start < r.location) {
			[s appendString:[self substringWithRange:NSMakeRange(start, r.location-start)]];
		}
		
		switch ([self characterAtIndex:r.location]) {
			case '<':
				[s appendString:@"&lt;"];
				break;
			case '>':
				[s appendString:@"&gt;"];
				break;
			case '"':
				[s appendString:@"&quot;"];
				break;
			case '&':
				[s appendString:@"&amp;"];
				break;
		}
		
		start = r.location + 1;
	}
	
	return s;
}

- (NSString*)unescapeHTML
{
	NSMutableString *s = [NSMutableString string];
	NSMutableString *target = [self mutableCopy];
	NSCharacterSet *chs = [NSCharacterSet characterSetWithCharactersInString:@"&"];
	
	while ([target length] > 0) {
		NSRange r = [target rangeOfCharacterFromSet:chs];
		if (r.location == NSNotFound) {
			[s appendString:target];
			break;
		}
		
		if (r.location > 0) {
			[s appendString:[target substringToIndex:r.location]];
			[target deleteCharactersInRange:NSMakeRange(0, r.location)];
		}
		
		if ([target hasPrefix:@"&lt;"]) {
			[s appendString:@"<"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&gt;"]) {
			[s appendString:@">"];
			[target deleteCharactersInRange:NSMakeRange(0, 4)];
		} else if ([target hasPrefix:@"&quot;"]) {
			[s appendString:@"\""];
			[target deleteCharactersInRange:NSMakeRange(0, 6)];
		} else if ([target hasPrefix:@"&amp;"]) {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 5)];
		} else {
			[s appendString:@"&"];
			[target deleteCharactersInRange:NSMakeRange(0, 1)];
		}
	}
	
	return s;
}

- (NSString *)stringByAppendingUrlParameter:(NSString *)param value:(NSString *)value
{
    NSMutableString *string = [self mutableCopy];
    
    if ([string rangeOfString:@"="].length != 0) {
        [string appendFormat:@"&%@=%@", param, [value URLEncodedString]];
    } else {
        [string appendFormat:@"?%@=%@", param, [value URLEncodedString]];
    }
    return string;
}

- (NSString*)stringByAppendingUrlParameters:(NSDictionary *)params
{
    if (params == nil || [params count] == 0) {
        return self;
    }
    NSMutableString *string = [self mutableCopy];
    NSArray *keys = [[params allKeys] sortedArrayUsingSelector:@selector(compare:)];
    NSString *firstKey = [keys objectAtIndex:0];
    NSString *firstValue = [params objectForKey:firstKey];
    
    if ([string rangeOfString:@"="].length != 0) {
        [string appendFormat:@"&%@=%@", firstKey, [firstValue URLEncodedString]];
    } else {
        [string appendFormat:@"?%@=%@", firstKey, [firstValue URLEncodedString]];
    }
    for (NSUInteger i = 1; i < [keys count]; i++) {
        NSString *key = [keys objectAtIndex:i];
        NSString *value = [params objectForKey:key];
        [string appendFormat:@"&%@=%@", key, [value URLEncodedString]];
    }
    return string;
}

- (NSDictionary *)breakQueryParameters
{
    NSArray *array = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:3];
    
    for (NSString *pair in array) {
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

- (NSDictionary *)getQueryParameters {
    NSString *paramStr = self;
    NSRange qMarkrange = [self rangeOfString:@"?" options:NSBackwardsSearch];
    if (NSNotFound != qMarkrange.length) {
        paramStr = [self substringFromIndex:qMarkrange.location];
    }
    return [paramStr breakQueryParameters];
}

- (NSString *)md5Digest
{
    const char* str = [self UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, (CC_LONG)strlen(str), result);
    NSMutableString *returnHashSum = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [returnHashSum appendFormat:@"%02x", result[i]];
    }
	return returnHashSum;
}

- (NSString*)base64Encode
{
    if ([self length] == 0)
        return @"";
    
    const char *source = [self UTF8String];
    NSUInteger strlength  = strlen(source);
    
    char *characters = malloc(((strlength + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    
    NSUInteger length = 0;
    NSUInteger i = 0;
    
    while (i < strlength) {
        char buffer[3] = {0, 0, 0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < strlength)
            buffer[bufferLength++] = source[i++];
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}

- (NSString*)base64Decode
{
    unsigned long ixtext, lentext;
    unsigned char ch, inbuf[4], outbuf[4];
    short i, ixinbuf;
    Boolean flignore, flendtext = false;
    const unsigned char *tempcstring;
    NSMutableData *theData;
    
    ixtext = 0;
    tempcstring = (const unsigned char *)[self UTF8String];
    lentext = [self length];
    theData = [NSMutableData dataWithCapacity:lentext];
    ixinbuf = 0;
    
    while (true) {
        if (ixtext >= lentext){
            break;
        }
        ch = tempcstring[ixtext++];
        flignore = false;
        if ((ch >= 'A') && (ch <= 'Z')) {
            ch = ch - 'A';
        } else if ((ch >= 'a') && (ch <= 'z')) {
            ch = ch - 'a' + 26;
        } else if ((ch >= '0') && (ch <= '9')) {
            ch = ch - '0' + 52;
        } else if (ch == '+') {
            ch = 62;
        } else if (ch == '=') {
            flendtext = true;
        } else if (ch == '/') {
            ch = 63;
        } else {
            flignore = true;
        }
        
        if (!flignore) {
            short ctcharsinbuf = 3;
            Boolean flbreak = false;
            
            if (flendtext) {
                if (ixinbuf == 0) {
                    break;
                }
                
                if ((ixinbuf == 1) || (ixinbuf == 2)) {
                    ctcharsinbuf = 1;
                } else {
                    ctcharsinbuf = 2;
                }
                
                ixinbuf = 3;
                
                flbreak = true;
            }
            
            inbuf[ixinbuf++] = ch;
            
            if (ixinbuf == 4) {
                ixinbuf = 0;
                
                outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
                outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
                outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
                
                for (i = 0; i < ctcharsinbuf; i++) {
                    [theData appendBytes: &outbuf[i] length: 1];
                }
            }
            
            if (flbreak) {
                break;
            }
        }
    }
    return [[NSString alloc] initWithData:theData encoding:NSUTF8StringEncoding];
}

+ (NSString *)nip_StringWithBase64EncodedString:(NSString *)string
{
    NSData *data = [NSData nip_DataWithBase64EncodedString:string];
    if (data)
    {
        return [[self alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString *)nip_Base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data nip_Base64EncodedStringWithWrapWidth:wrapWidth];
}

- (NSString *)nip_Base64EncodedString
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data nip_Base64EncodedString];
}

- (NSString *)nip_Base64DecodedString
{
    return [NSString nip_StringWithBase64EncodedString:self];
}

- (NSData *)nip_Base64DecodedData
{
    return [NSData nip_DataWithBase64EncodedString:self];
}


- (NSData *)base16Data
{
    if ([self length] % 2 != 0) {
        return nil;
    }
    unsigned char key[[self length] / 2 + 1];
    bzero(key, [self length] / 2 + 1);
    
    for (int i = 0; i < [self length] / 2; i++) {
        NSString *str = [self substringWithRange:NSMakeRange(2 * i, 2)];
        key[i] = [self stringToASCIIChar:str];
    }
    return [NSData dataWithBytes:key length:[self length] / 2];
}

- (BOOL)isValidHttpURL
{
    if ([self hasPrefix:@"http"]) {
        return YES;
    }
    return NO;
}

- (NSString *)stringMatchRegex:(NSString*)regex {
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:nil];
    NSRange range = [reg rangeOfFirstMatchInString:self options:(0) range:[self rangeOfString:self]];
    if (range.length > 0) {
        return [self substringWithRange:range];
    }
    return nil;
}

- (NSString*)emailPrefix
{
    NSRange atRange = [self rangeOfString:@"@"];
    if (atRange.length > 0) {
        return [self substringToIndex:atRange.location];
    }
    return nil;
}

- (NSString*)emailSuffix
{
    NSRange atRange = [self rangeOfString:@"@"];
    if (atRange.length > 0) {
        return [self substringFromIndex:atRange.location + atRange.length];
    }
    return nil;
}

- (unichar)stringToASCIIChar:(NSString *)str
{
    if ([str length] < 2) {
        return 0;
    }
    unichar one = [str characterAtIndex:0];
    unichar two = [str characterAtIndex:1];
    if(('0' <= one) && (one <= '9')) {
        one = one - '0';
    }
    if(('a' <= one) && (one <= 'z')) {
        one = one - 'a' + 10;
    }
    if(('A' <= one) && (one <= 'Z')) {
        one = one-'A'+ 10;
    }
    if(('0' <= two) && (two <= '9')) {
        two = two - '0';
    }
    if(('a' <= two) && (two <= 'z')) {
        two = two - 'a' + 10;
    }
    if(('A' <= two) && (two <= 'Z')) {
        two = two - 'A' + 10;
    }
    return one * 16 + two;
}

#ifdef GNUSTEP
- (NSString *)stringByTrimming
{
	return [self stringByTrimmingSpaces];
}
#else
- (NSString *)stringByTrimming
{
	NSMutableString *mStr = [self mutableCopy];
	CFStringTrimWhitespace((__bridge CFMutableStringRef)mStr);
	
	NSString *result = [mStr copy];
	
	return result;
}
#endif



static  char* hex[] = {
    "00","01","02","03","04","05","06","07","08","09","0A","0B","0C","0D","0E","0F",
    "10","11","12","13","14","15","16","17","18","19","1A","1B","1C","1D","1E","1F",
    "20","21","22","23","24","25","26","27","28","29","2A","2B","2C","2D","2E","2F",
    "30","31","32","33","34","35","36","37","38","39","3A","3B","3C","3D","3E","3F",
    "40","41","42","43","44","45","46","47","48","49","4A","4B","4C","4D","4E","4F",
    "50","51","52","53","54","55","56","57","58","59","5A","5B","5C","5D","5E","5F",
    "60","61","62","63","64","65","66","67","68","69","6A","6B","6C","6D","6E","6F",
    "70","71","72","73","74","75","76","77","78","79","7A","7B","7C","7D","7E","7F",
    "80","81","82","83","84","85","86","87","88","89","8A","8B","8C","8D","8E","8F",
    "90","91","92","93","94","95","96","97","98","99","9A","9B","9C","9D","9E","9F",
    "A0","A1","A2","A3","A4","A5","A6","A7","A8","A9","AA","AB","AC","AD","AE","AF",
    "B0","B1","B2","B3","B4","B5","B6","B7","B8","B9","BA","BB","BC","BD","BE","BF",
    "C0","C1","C2","C3","C4","C5","C6","C7","C8","C9","CA","CB","CC","CD","CE","CF",
    "D0","D1","D2","D3","D4","D5","D6","D7","D8","D9","DA","DB","DC","DD","DE","DF",
    "E0","E1","E2","E3","E4","E5","E6","E7","E8","E9","EA","EB","EC","ED","EE","EF",
    "F0","F1","F2","F3","F4","F5","F6","F7","F8","F9","FA","FB","FC","FD","FE","FF"
};

static short val[] = {
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,
    0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F,0x3F
};

- (NSString*)javaScriptEscape
{
    NSMutableString *sbuf = [[NSMutableString alloc] init];
    NSUInteger len = self.length;
    for (NSUInteger i = 0; i < len; i++) {
        unichar ch = [self characterAtIndex:i];
        if (ch == ' ') {                        // space : map to '+'
            [sbuf appendString:@"+"];
        } else if ('A' <= ch && ch <= 'Z') {    // 'A'..'Z' : as it was
            [sbuf appendString:[NSString stringWithCharacters:&ch length:1]];
        } else if ('a' <= ch && ch <= 'z') {    // 'a'..'z' : as it was
            [sbuf appendString:[NSString stringWithCharacters:&ch length:1]];
        } else if ('0' <= ch && ch <= '9') {    // '0'..'9' : as it was
            [sbuf appendString:[NSString stringWithCharacters:&ch length:1]];
        } else if (ch == '-' || ch == '_'       // unreserved : as it was
                   || ch == '.' || ch == '!'
                   || ch == '~' || ch == '*'
                   || ch == '\'' || ch == '('
                   || ch == ')') {
            [sbuf appendString:[NSString stringWithCharacters:&ch length:1]];
        } else if (ch <= 0x007F) {              // other ASCII : map to %XX
            [sbuf appendString:@"%"];
            [sbuf appendString:[NSString stringWithUTF8String:hex[ch]]];
        } else {
            [sbuf appendString:@"%"];
            [sbuf appendString:@"u"];
            [sbuf appendString:[NSString stringWithUTF8String:hex[(ch >> 8)]]];
            [sbuf appendString:[NSString stringWithUTF8String:hex[(0x00FF & ch)]]];
        }
    }
    return sbuf;
}

- (NSString*)javaScriptUnescape
{
    NSMutableString *sbuf = [[NSMutableString alloc] init];
    NSUInteger len = self.length;
    NSUInteger i = 0;
    while (i < len) {
        unichar ch = [self characterAtIndex:i];
        if (ch == '+') {                        // + : map to ' '
            [sbuf appendString:@" "];
        } else if ('A' <= ch && ch <= 'Z') {    // 'A'..'Z' : as it was
            [sbuf appendString:[NSString stringWithCharacters:&ch length:1]];
        } else if ('a' <= ch && ch <= 'z') {    // 'a'..'z' : as it was
            [sbuf appendString:[NSString stringWithCharacters:&ch length:1]];
        } else if ('0' <= ch && ch <= '9') {    // '0'..'9' : as it was
            [sbuf appendString:[NSString stringWithCharacters:&ch length:1]];
        } else if (ch == '-' || ch == '_'       // unreserved : as it was
                   || ch == '.' || ch == '!'
                   || ch == '~' || ch == '*'
                   || ch == '\'' || ch == '('
                   || ch == ')') {
            [sbuf appendString:[NSString stringWithCharacters:&ch length:1]];
        } else if (ch == '%') {
            unichar cint = 0;
            if ('u' != [self characterAtIndex:i+1]) {         // %XX : map to ascii(XX)
                cint = (cint << 4) | val[[self characterAtIndex:i + 1]];
                cint = (cint << 4) | val[[self characterAtIndex:i + 2]];
                i += 2;
            } else {                            // %uXXXX : map to unicode(XXXX)
                cint = (cint << 4) | val[[self characterAtIndex:i + 2]];
                cint = (cint << 4) | val[[self characterAtIndex:i + 3]];
                cint = (cint << 4) | val[[self characterAtIndex:i + 4]];
                cint = (cint << 4) | val[[self characterAtIndex:i + 5]];
                i += 5;
            }
            [sbuf appendString:[NSString stringWithCharacters:&cint length:1]];
        }
        i++;
    }
    return sbuf;
}

-(NSString *)encodeUTF8{
    CFStringRef nonAlphaNumValidChars = CFSTR("![        DISCUZ_CODE_1        ]’()*+,-./:;=?@_~");
    NSString *preprocessedString = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingUTF8));
    NSString *newStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)preprocessedString,NULL,nonAlphaNumValidChars,kCFStringEncodingUTF8));
    return newStr;
}

-(NSString *)encodeGB2312{
    CFStringRef nonAlphaNumValidChars = CFSTR("![        DISCUZ_CODE_1        ]’()*+,-./:;=?@_~");
    NSString *preprocessedString = (NSString *)CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (CFStringRef)self, CFSTR(""), kCFStringEncodingGB_18030_2000));
    NSString *newStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)preprocessedString,NULL,nonAlphaNumValidChars,kCFStringEncodingGB_18030_2000));
    return newStr;
}

- (NSInteger)letterCount {
    NSInteger letterCount = 0;
    for (NSUInteger i=0; i<self.length; i++) {
        unichar c = [self characterAtIndex:i];
        if ( (c>='a'&&c<='z')||(c>='A'&&c<='Z')) {
            letterCount++;
        }
    }
    return letterCount;
}

- (NSInteger)numCount {
    NSInteger numCount = 0;
    for (NSUInteger i=0; i<self.length; i++) {
        unichar c = [self characterAtIndex:i];
        if (c>='0'&&c<='9') {
            numCount++;
        }
    }
    return numCount;
}

- (BOOL)containRarelyUsedWordByEncodeGB2312 {
    if (!notEmptyString(self)) {
        return NO;
    }
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:@"[\\u4e00-\\u9fa5]+" options:0 error:nil];
    NSRange range = [reg rangeOfFirstMatchInString:self options:(0) range:[self rangeOfString:self]];
    NSString *chineseStr = nil;//先取出中文
    if (range.length > 0) {
        chineseStr = [self substringWithRange:range];
    }
    
    if (!notEmptyString(chineseStr)) {
        return NO;
    }
    NSInteger i = chineseStr.length;
    NSString *word = nil;
    NSArray *words = nil;
    while(i > 0) { //逐字判断
        word = [chineseStr substringWithRange:NSMakeRange(i - 1, 1)];
        words = [[word encodeGB2312] componentsSeparatedByString:@"%"];
        //检查编码范围
        if (notEmptyArray(words) && 3 == words.count) {
            UInt64 mac1 =  strtoul([words[1] UTF8String], 0, 16);
            if (mac1 < strtoul([@"B0" UTF8String], 0, 16) || mac1 > strtoul([@"F7" UTF8String], 0, 16)) {
                return YES;
            }
            
            mac1 =  strtoul([words[2] UTF8String], 0, 16);
            if (mac1 < strtoul([@"A1" UTF8String], 0, 16) || mac1 > strtoul([@"FE" UTF8String], 0, 16)) {
                return YES;
            }
        }
        i--;
    }
    return NO;
}

- (NSString *)hideMiddleMobileNumber {
    if (self.length>=8&&![self containsSubstring:@"*"]) {
        return [NSString stringWithFormat:@"%@****%@",[self substringWithRange:NSMakeRange(0, 3
                                                                                          )],
                [self substringWithRange:NSMakeRange(7, self.length-7)]];
    }
    return self;
}

- (NSString *)abbrAccount {
    NSString *abbrString = nil;
    if (notEmptyString(self)) {
        if (self.length < 19) {
            abbrString = self;
        } else {
            if ([self isEmailAddress]) {
                NSArray *accountArray = [self componentsSeparatedByString:@"@"];
                if (1 < accountArray.count) {
                    NSString *frontAccount = accountArray[0];
                    NSInteger i = 1;
                    while (i < accountArray.count - 1) {
                        frontAccount = [frontAccount stringByAppendingString:[NSString stringWithFormat:@"@%@", accountArray[i]]];
                        i++;
                    }
                    NSString *backAccount = [NSString stringWithFormat:@"...@%@", [accountArray lastObject]];
                    frontAccount = [frontAccount substringToIndex:MIN(frontAccount.length, 18 - MAX(0, backAccount.length))];
                    abbrString = [NSString stringWithFormat:@"%@%@", frontAccount, backAccount];
                }
            } else {
                abbrString = [NSString stringWithFormat:@"%@...", [self substringToIndex:14]];
            }
        }
    } else {
        abbrString = @"";
    }
    return abbrString;
}

- (NSDate *)birthdayFromIdCardNo {
    NSDateFormatter *formater =[[NSDateFormatter alloc] init];
    [formater setDateFormat:@"YYYYMMdd"];
    NSString *text;
    if (self.length==18) {
        text = [self substringWithRange:NSMakeRange(6, 8)];
    } else if (self.length==15) {
        text = [self substringWithRange:NSMakeRange(6, 6)];
        text = [text stringByAppendingString:@"19"];
    }
    if (notEmptyString(text)) {
        return [formater dateFromString:text];
    }
    return nil;
}

- (NSString *)genderFromIdCardNo {
    NSString *gender = @"M";
    NSInteger key = [[self substringWithRange:NSMakeRange(self.length - 2, 1)] integerValue];
    if (key%2==0) {
        gender = @"F";
    } else{
        gender = @"M";
    }
    return gender;
}




@end
