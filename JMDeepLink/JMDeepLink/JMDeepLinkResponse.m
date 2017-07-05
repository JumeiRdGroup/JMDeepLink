//
//  JMDeepLinkResponse.m
//  JuMei
//
//  Created by bojiaz on 16/9/14.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import "JMDeepLinkResponse.h"

@implementation JMDeepLinkResponse

- (NSString *)description {
    return [NSString stringWithFormat:@"Status: %@; Data: %@", self.statusCode, self.data];
}

@end
