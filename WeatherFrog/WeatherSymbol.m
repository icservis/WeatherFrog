//
//  WeatherSymbol.m
//  WeatherFrog
//
//  Created by Libor Kučera on 10.12.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "WeatherSymbol.h"

@implementation WeatherSymbol

@synthesize symbol;

- (instancetype)initWithSymbol:(NSUInteger)weatherSymbol
{
    if (self = [super init]) {
        self.symbol = [NSNumber numberWithInteger:weatherSymbol];
    }
    return self;
}

- (NSString*)localizedName
{
    static NSArray* localeNames;
    if (localeNames == nil) {
        localeNames = [[NSArray alloc] initWithObjects:
                       NSLocalizedString(@"Weather undefined", @"kWeatherSymbolNone"),
                       NSLocalizedString(@"Clear", @"kWeatherSymbolSun"),
                       NSLocalizedString(@"Light Cloud", @"kWeatherSymbolLightCloud"),
                       NSLocalizedString(@"Partly Cloud", @"kWeatherSymbolPartlyCloud"),
                       NSLocalizedString(@"Cloud", @"kWeatherSymbolCloud"),
                       NSLocalizedString(@"Light Rain and Sun", @"kWeatherSymbolLightRainSun"),
                       NSLocalizedString(@"Light Rain, Thunder and Sun", @"kWeatherSymbolLightRainThunderSun"),
                       NSLocalizedString(@"Sleet Sun", @"kWeatherSymbolSleetSun"),
                       NSLocalizedString(@"Snow Sun", @"kWeatherSymbolSnowSun"),
                       NSLocalizedString(@"Light Rain", @"kWeatherSymbolLightRain"),
                       NSLocalizedString(@"Rain", @"kWeatherSymbolRain"),
                       NSLocalizedString(@"Rain and Thunder", @"kWeatherSymbolRainThunder"),
                       NSLocalizedString(@"Sleet", @"kWeatherSymbolSleet"),
                       NSLocalizedString(@"Snow", @"kWeatherSymbolSnow"),
                       NSLocalizedString(@"Snow and Thunder", @"kWeatherSymbolSnowThunder"),
                       NSLocalizedString(@"Fog", @"kWeatherSymbolFog"),
                       NSLocalizedString(@"Sun (Winter Darkness)", @"kWeatherSymbolSunWinterDarkness"),
                       NSLocalizedString(@"Light Cloud (Winter Darkness)", @"kWeatherSymbolLightCloudWinterDarkness"),
                       NSLocalizedString(@"Light Rain and Sun (Winter Darkness)", @"kWeatherSymbolLightRainSunWinterDarkness"),
                       NSLocalizedString(@"Snow (Winter Darkness)", @"kWeatherSymbolSnowSunWinterDarkness"),
                       NSLocalizedString(@"Sleet Sun (Winter Darkness)", @"kWeatherSymbolSleetSunThunder"),
                       NSLocalizedString(@"Snow, Sun and Thunder", @"kWeatherSymbolSnowSunThunder"),
                       NSLocalizedString(@"Light Rain and Thunder", @"kWeatherSymbolLightRainThunder"),
                       NSLocalizedString(@"Sleet Thunder", @"kWeatherSymbolSleetThunder"),
                       nil];
    }
    NSUInteger weatherSymbol = [self.symbol integerValue];
    if ([localeNames objectAtIndex:weatherSymbol] != nil) {
        return [localeNames objectAtIndex:weatherSymbol];
    } else {
        return [localeNames firstObject];
    }
}

- (UIImage*)imageForSize:(NSUInteger)size isNight:(BOOL)isNight
{
    NSString* imageName = [NSString stringWithFormat:@"weathericon-%@-%d-%ld", self.symbol, isNight, (unsigned long)size];
    return [UIImage imageNamed:imageName];
}

+ (NSArray*)notificationsConfigForLevel:(NSUInteger)notificationLevel
{
    NSMutableArray* array = [NSMutableArray array];
    
    if (notificationLevel == kWeatherNotificationLevelLow) {
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowSunThunder]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRainThunder]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleetThunder]];
    }
    
    if (notificationLevel == kWeatherNotificationLevelMiddle) {
        
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolRain]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolRainThunder]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleet]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnow]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowThunder]];
        
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowSunThunder]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRainThunder]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleetThunder]];
    }
    
    if (notificationLevel == kWeatherNotificationLevelHigh) {
        
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRainSun]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRainThunderSun]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleetSun]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowSun]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRain]];
        
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolRain]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolRainThunder]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleet]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnow]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowThunder]];
        
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowSunThunder]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRainThunder]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleetThunder]];
    }
    
    return array;
}

+ (NSArray*)sampleSymbolsForNotificationLevel:(NSUInteger)notificationLevel
{
    NSMutableArray* array = [NSMutableArray array];
    
    if (notificationLevel == kWeatherNotificationLevelNone) {
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolNone]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolNone]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolNone]];
    }
    
    if (notificationLevel == kWeatherNotificationLevelLow) {
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowSunThunder]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRainThunder]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleetThunder]];
    }
    
    if (notificationLevel == kWeatherNotificationLevelMiddle) {
        
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolRain]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolRainThunder]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleet]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnow]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowThunder]];
        
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowSunThunder]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRainThunder]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleetThunder]];
    }
    
    if (notificationLevel == kWeatherNotificationLevelHigh) {
        
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRainSun]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRainThunderSun]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleetSun]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowSun]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRain]];
        
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolRain]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolRainThunder]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleet]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnow]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowThunder]];
        
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolSnowSunThunder]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolLightRainThunder]];
        //[array addObject:[NSNumber numberWithInteger:kWeatherSymbolSleetThunder]];
    }
    
    if (notificationLevel == kWeatherNotificationLevelAll) {
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolNone]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolSun]];
        [array addObject:[NSNumber numberWithInteger:kWeatherSymbolNone]];
    }
    
    return array;
}

@end
