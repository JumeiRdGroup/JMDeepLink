//
//  JMDeepLinkMatchHelper.h
//  JuMei
//
//  Created by bojiaz on 16/9/13.
//  Copyright © 2016年 Jumei Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JMDeepLinkBlocks.h"

@interface JMDeepLinkMatchHelper : NSObject

+ (JMDeepLinkMatchHelper *)getInstance;

- (void)createMatchWithCallBlock:(void (^)(void))callBlock;

@end
