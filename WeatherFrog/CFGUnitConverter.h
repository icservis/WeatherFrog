//
//  CFGUnitConverter.h
//  WeatherFrog
//
//  Created by Kučera Libor on 18.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface CFGUnitConverter : NSObject

- (NSString*)convertPercent:(NSNumber*)percent;
- (NSString*)convertDegrees:(NSNumber*)degrees;
- (NSString*)convertTemperature:(NSNumber*)temperatureCelsius;
- (NSString*)convertWindDirection:(NSNumber*)windDirectionRadius;
- (NSString*)convertWindSpeed:(NSNumber*)windSpeedMetresPerSecond;
- (NSString*)convertWindScale:(NSNumber*)windScaleBeaufort;
- (NSString*)convertPrecipitation:(NSNumber*)precipitationMilimetresPerhour;
- (NSString*)convertPressure:(NSNumber*)presureHectoPascals;
- (NSString*)convertAltitude:(NSNumber*)altitudeMetres;

@end
