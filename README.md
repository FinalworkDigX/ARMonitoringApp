[![Build Status](https://travis-ci.org/FinalworkDigX/ARMonitoringApp.svg?branch=master)](https://travis-ci.org/FinalworkDigX/ARMonitoringApp)

<img src="https://i.imgur.com/hvj4iMi.png" alt="github_logo"/>


# RAM - ARMonitoring

Augmented Reality application that displays realtime information. This whole application uses Beacon based indoor-location to put the displayed information in the right place. (There are currently issues with the 3D trilateration).
The displayed data comes from the [SpringbootManager](https://github.com/FinalworkDigX/SpringbootManager) which uses Web Sockets for realtime data transfer. More information can be found at the Manager's documentation.


## Setup
### Requirements
1. [SpringbootManager](https://github.com/FinalworkDigX/SpringbootManager) installed and working.
2. [AngularFrontend](https://github.com/FinalworkDigX/AngularFrontend) to manage the backend.
3. [CocoaPods](https://guides.cocoapods.org/using/getting-started.html) installed on Mac. These are used throughout the project.

### Build
#### Install pods
Install Pods running following command:

```bash
$ pod install
```

#### Init Properties.plist
Copy Example.Properties.plist to Properties.Plist (in document root) and fill in the needed information

```bash
cp Example.Properties.plist Properties.plist
```
Needed information:
* api_url: The URL to where the [SpringbootManager](https://github.com/FinalworkDigX/SpringbootManager) is deployed with api version<br/>
__example:__ https://myAPI.com/v1/
* ws_url: The URL for STOMP client to connect to<br/>
__example:__ https://myAPI.com/managerWS/websocket
* beacon_uuid: UUID for iOS' LocationManager to look for<br/>
__example:__ 116e98d2-645d-11e8-adc0-fa7ae01bbebc

## Using the App
User manual shouldn't be necessary for this application. Once it has been setup it should be pretty straightforward

## Current issues
Known current issues:
* _Trilateration not working:_<br/>
    Using own [Trilateration3D](https://github.com/PudiPudi/Trilateration3D) pod<br/>
    __Issue:__ when used with ARSCN camera coordinates it returns random results<br/>
    __WorkAround:__ "Room" button on main view, sets closest beacon manually
* _Indoor location:_<br/>
    __Issue:__ Not looking for 'true north', to get full potential of product, code setup to get n-ammount of items with only 3 Beacons. For this to work, the north of the app has to be calibrated to always be the same, so loaded rooms (containg data items) always open in the same orientation. AKA always putting objects on the same place
* _"Build not passing"<br/>
    __Issue:__ [sqlite pod](https://github.com/stephencelis/SQLite.swift) creates error in travis-ci caussing build to fail.
