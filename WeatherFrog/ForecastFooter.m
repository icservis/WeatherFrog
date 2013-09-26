//
//  ForecastFooter.m
//  WeatherFrog
//
//  Created by Libor Kučera on 22.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "ForecastFooter.h"
#import "Astro.h"

@interface ForecastFooter()

@property (nonatomic, weak) IBOutlet UILabel* moonPhase;

@end

@implementation ForecastFooter

+ (CGFloat)forecastFooterHeight
{
    return 21.0f;
}

- (void)setAstro:(Astro *)astro
{
    _astro = astro;
    _moonPhase.text = astro.moonPhase;
}

@end
