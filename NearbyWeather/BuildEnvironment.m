//
//  BuildEnvironment.m
//  NearbyWeather
//
//  Created by Erik Maximilian Martens on 29.01.20.
//  Copyright © 2020 Erik Maximilian Martens. All rights reserved.
//

#import "BuildEnvironment.h"

@implementation BuildEnvironment

+ (BOOL)isReleaseEvironment
{
#if DEBUG==1
  return NO;
#else
  return YES;
#endif
}

@end
