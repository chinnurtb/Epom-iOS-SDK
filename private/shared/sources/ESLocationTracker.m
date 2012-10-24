//
//  ESLocationTracker.m
//  epom
//
//  Created by Orange on 10/17/12.
//
//

#import "ESLocationTracker.h"

#pragma mark -- ESLocationTracker private interface

@interface ESLocationTracker()

@property (readwrite, retain) CLLocationManager *locator;
@property (readwrite, assign) BOOL useLocation;

@end

#pragma mark -- ESLocationTracker implementation

@implementation ESLocationTracker

@synthesize locator;
@synthesize useLocation;

static ESLocationTracker *g_locationTracker = nil;

#pragma mark -- ESLocationTracker accessor

+(ESLocationTracker *) shared
{
	@synchronized([ESLocationTracker class])
	{
		if (g_locationTracker == nil)
		{
			g_locationTracker = [[ESLocationTracker alloc] init];
		}
		
		return g_locationTracker;
	}
	
	return nil;
}

#pragma mark -- ESLocationTracker methods implementation

-(void)setForceUseLocation:(BOOL)yesOrNo
{
	@synchronized(self)
	{
		self.useLocation = self.useLocation || yesOrNo;
		
		// try create
		if ((self.locator == nil) && [self locationManagerIsAvailable] && [self locationManagerIsAllowed])
		{
			self.locator = [[[CLLocationManager alloc] init] autorelease];
			self.locator.delegate = self;
			self.locator.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
			
			if ((self.locator.location == nil) && self.useLocation)
			{
				[self.locator startUpdatingLocation];
			}
			else
			{
				[self.locator startMonitoringSignificantLocationChanges];
			}
		}
		
	}
}

-(CLLocation *)currentLocation
{
	[self setForceUseLocation:self.useLocation];
	
	if (self.locator)
		return self.locator.location;
	
	return nil;
}


#pragma mark -- CLLocationManagerDelegate implementation

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	if (oldLocation == nil)
	{
		// enable default mode
		[self.locator stopUpdatingLocation];
		[self.locator startMonitoringSignificantLocationChanges];
	}
}

- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	ES_LOG_ERROR(@" Location manager error: %@", error);
}

#pragma mark -- Features availability checks

- (BOOL)locationManagerIsAvailable
{
	if (NSClassFromString(@"CLLocationManager") == nil)
	{
		return NO;
	}
	
	BOOL enabledAvailable = [CLLocationManager instancesRespondToSelector:@selector(locationServicesEnabled)];
	BOOL monitoringAvailable = [CLLocationManager instancesRespondToSelector:@selector(startMonitoringSignificantLocationChanges)];
	
	return  enabledAvailable && monitoringAvailable && [CLLocationManager locationServicesEnabled];
}

- (BOOL)locationManagerIsAllowed
{
	CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
	return (status == kCLAuthorizationStatusAuthorized) || (self.useLocation && (status == kCLAuthorizationStatusNotDetermined));
}


@end
