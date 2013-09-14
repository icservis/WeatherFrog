//
//  ForecastCell.m
//  WeatherFrog
//
//  Created by Libor Kučera on 14.09.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#import "ForecastCell.h"
#import "Weather.h"

@interface ForecastCell ()

@property (nonatomic, strong) NSDateFormatter* localDateFormatter;
@property (nonatomic, strong) NSNumberFormatter* localNumberFormatter;

@property (nonatomic, weak) IBOutlet UILabel* date;
@property (nonatomic, weak) IBOutlet UILabel* temperature;
@property (nonatomic, weak) IBOutlet UILabel* precipitation;
@property (nonatomic, weak) IBOutlet UILabel* windSpeed;
@property (nonatomic, weak) IBOutlet UIImageView* icon;

@end

@implementation ForecastCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTimezone:(NSTimeZone *)timezone
{
    _timezone = timezone;
    [self.localDateFormatter setTimeZone:timezone];
}

- (void)setWeather:(Weather *)weather
{
    _weather = weather;
    _date.text = [self.localDateFormatter stringFromDate:weather.timestamp];
    _temperature.text = [self.localNumberFormatter stringFromNumber:weather.temperature];
}

- (NSDateFormatter*)localDateFormatter
{
    if (_localDateFormatter == nil) {
        _localDateFormatter = [[NSDateFormatter alloc] init];
        [_localDateFormatter setDateStyle:NSDateFormatterShortStyle];
        [_localDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    return _localDateFormatter;
}

- (NSNumberFormatter*)localNumberFormatter
{
    if (_localNumberFormatter == nil) {
        _localNumberFormatter = [[NSNumberFormatter alloc] init];
        [_localNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    }
    return _localNumberFormatter;
}

@end
