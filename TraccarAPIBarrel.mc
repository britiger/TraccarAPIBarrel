using Toybox.Application;
using Toybox.System;
using Toybox.Position;
using Toybox.Time;
using Toybox.Communications;
using Toybox.Math;
using Toybox.Lang;
using Toybox.StringUtil;

(:background)
module TraccarAPIBarrel {

    function getTraccarURL() {
        var url = null;
        try {
            var url = Application.Properties.getValue("traccarURL");
            if (url.equals("")) {
                url = null;
            }
            System.println("URL: " + url);
            return url;
        } catch (e instanceof Application.ObjectStoreAccessException) {
            System.println("Need to set traccarURL in app or view.");
        }
        return null;
    }

    function getDeviceIdRaw() {
        // Get non hashed deviceId
        var propDeviceId = "";
        try {
            propDeviceId =  Application.Properties.getValue("deviceId");
        } catch (e instanceof Lang.Exception) {
            System.println("Need to define Property deviceId in your Application");
            propDeviceId = "";
        }
        if (propDeviceId == null || propDeviceId.equals("")) {
            // initalisation of application property
            // need to call in non-background for inital set value
            // setValue is not possible in background!
            var mySettings = System.getDeviceSettings();
            propDeviceId = mySettings.uniqueIdentifier;
            try {
                Application.Properties.setValue("deviceId", propDeviceId);
            } catch (e instanceof Application.ObjectStoreAccessException) {
                System.println("Need to set deviceId in app or view.");
            }
        }
        return propDeviceId;
    }
    
    function sendPositionData(callbackMethod) {
        var baseURL = getTraccarURL();
        if (baseURL == null) {
            System.println("not traccar URL set, skip.");
            return 0;
        }
        var url = baseURL + "?id=" + getDeviceIdRaw();
        var parms = {}; // For TESTing, don't send
    
        var positionInfo = Position.getInfo(); // get current Postion
        // Check position
        if (positionInfo.accuracy < Position.QUALITY_POOR) {
            // Location not good enough
            return -1; // use last position
        }
        var myLocation = positionInfo.position.toDegrees();
        System.println("Latitude: " + myLocation[0]); 
        System.println("Longitude: " + myLocation[1]); 
        System.println("Accu: " + positionInfo.accuracy);

        // Check Position can be real or it's only a dummy
        if (myLocation[0] >= 179 || (myLocation[0] == 0 && myLocation[1] == 0)){
            return -2;
        }
        url = url + "&lat=" + myLocation[0];
        url = url + "&lon=" + myLocation[1];
        url = url + "&altitude=" + positionInfo.altitude;
        url = url + "&heading=" + Math.toDegrees(positionInfo.heading);
        url = url + "&speed=" + positionInfo.speed*3.6; // m/sec => km/h

        // Battery
        var stats = System.getSystemStats();
        url = url + "&batt=" + stats.battery;

        var options = {                                             // set the options
           :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
           :headers => {                                            // set headers
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON},
                                                                    // set response type
           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
           };
        System.println("start request");
        if(callbackMethod == null) {
            callbackMethod = new Lang.Method(TraccarAPIBarrel, :onReceive);
        }
        Communications.makeWebRequest(url, parms, options, callbackMethod);
        return 0;
    }

    function onReceive(responseCode, data) {
       if (responseCode == 200) {
           System.println("Request Successful");                   // print success
       }
       else {
           System.println("Response: " + responseCode);            // print response code
       }
    }
}
