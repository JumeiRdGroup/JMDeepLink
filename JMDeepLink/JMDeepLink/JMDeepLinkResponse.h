//
//  JMDeepLinkResponse.h
//  JuMei
//
//  Created by bojiaz on 16/9/14.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMDeepLinkResponse : NSObject

@property (nonatomic, strong) NSNumber *statusCode;
@property (nonatomic, strong) NSDictionary *data;

@end
