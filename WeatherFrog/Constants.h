//
//  MapViewConstants.h
//  WeatherFrog
//
//  Created by Libor Kučera on 26.07.13.
//  Copyright (c) 2013 IC Servis. All rights reserved.
//

#ifndef WeatherFrog_Constants_h
#define WeatherFrog_Constants_h

#pragma mark - Images

static NSString* const imageLogo = @"logo";
static NSString* const imageWaitingFrogLandscape = @"waiting-frog-landscape";
static NSString* const imageWaitingFrogPortrait = @"waiting-frog-portrait";

#pragma mark - Banner

static float const kExpiryTimeInterval = 86400*30;
static int const kExpiryAlertCount = 3;
static float const kExpiryAlertTimerPeriod = 30.0;

#pragma mark - Times

static float const kAnimationDuration = 0.5f;

#pragma mark - Forecast

static int const kBackgoundFetchInterval = 3600;
static int const kAstroFeedHoursCount = 30*24;

#pragma mark - ForecastController - Portrait

static CGFloat const labelTopMargin = 3.0f;
static CGFloat const labelHeight = 21.0f;
static CGFloat const timeTopMargin = 3.0f;
static CGFloat const timeHeight = 21.0f;
static CGFloat const iconTopMargin = 0.0f;
static CGFloat const iconSize = 64.0f;
static CGFloat const tableTopMargin = 2.0f;
static float const PortraitForecastIconSize = 80; // icon size before resizinh

#pragma mark - ForecastController - Landscape

static float const LandscapeForecastElementsCount = 12; // number of elements in page
static float const LandscapeForecastConfigHours = 72; // hours interval in page
static float const LandscapeForecastIconSize = 40; // icon size
static float const LandscapeForecastIconMargin = 5; // icon margin
static float const LandscapeForecastGraphMargin = 5; // graph margin
static float const BarPlotPrecipitationMinValue = 0.4f; // min value of precipitation
static float const BarPlotPrecipitationMaxValue = 150.0f; // max value of precipitation
static NSString *const BarPlotPrecipitationLabelsString = @"1,10,100"; // procipitation labels
static int const ScatterPlotTemperatureLabelsCount = 5; // count of label on temp axis
static float const ScatterPlotMarginPercentualValue = 10.0f; // percent of scatter plot margin
static int const ScatterPlotXAxisMajorIntervalLength = 86400;
static int const ScatterPlotXAxisMinorTicksPerInterval = 3;

#pragma mark - MapView

static double const kMapCenterLatitude = 48.15952f;
static double const kMapCenterLongitude = 17.12769f;
static float const kMapRadiusMultiplier = 1000.0f;

#pragma mark - MBProgressHud

static float const kHudDisplayTimeInterval = 1.2f;

#pragma mark - Support

static NSString* const weatherFrogSupportEmail = @"support@weatherfrog.info";
static NSString* const weatherFrogSupportWeb = @"http://weatherfrog.info/";

#endif
