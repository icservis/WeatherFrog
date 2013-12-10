//
//  WeatherSymbol.h
//  WeatherFrog
//
//  Created by Libor Kučera on 10.12.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kWeatherSymbolNone = 0,
    kWeatherSymbolSun = 1,
    kWeatherSymbolLightCloud = 2,
    kWeatherSymbolPartlyCloud = 3,
    kWeatherSymbolCloud = 4,
    kWeatherSymbolLightRainSun = 5,
    kWeatherSymbolLightRainThunderSun = 6,
    kWeatherSymbolSleetSun = 7,
    kWeatherSymbolSnowSun = 8,
    kWeatherSymbolLightRain = 9,
    kWeatherSymbolRain = 10,
    kWeatherSymbolRainThunder = 11,
    kWeatherSymbolSleet = 12,
    kWeatherSymbolSnow = 13,
    kWeatherSymbolSnowThunder = 14,
    kWeatherSymbolFog = 15,
    kWeatherSymbolSunWinterDarkness = 16,
    kWeatherSymbolLightCloudWinterDarkness = 17,
    kWeatherSymbolLightRainSunWinterDarkness = 18,
    kWeatherSymbolSnowSunWinterDarkness = 19,
    kWeatherSymbolSleetSunThunder = 20,
    kWeatherSymbolSnowSunThunder = 21,
    kWeatherSymbolLightRainThunder = 22,
    kWeatherSymbolSleetThunder = 23
} kWeatherSymbol;

typedef enum {
    kWeatherNotificationLevelNone = 0,
    kWeatherNotificationLevelLow = 1,
    kWeatherNotificationLevelMiddle = 2,
    kWeatherNotificationLevelHigh = 3,
    kWeatherNotificationLevelAll = 4
} kWeatherNotificationLevel;

@interface WeatherSymbol : NSObject

@property (nonatomic, strong) NSNumber* symbol;

- (instancetype)initWithSymbol:(NSUInteger)weatherSymbol;
- (UIImage*)imageForSize:(NSUInteger)size isNight:(BOOL)isNight;
- (NSString*)localizedName;

+ (NSArray*)notificationsConfigForLevel:(NSUInteger)notificationLevel;
+ (NSArray*)sampleSymbolsForNotificationLevel:(NSUInteger)notificationLevel;

@end
