Monkey C Barrel for Sending Position using OSMAnd protocol
====================================

This barrel give you some function to send the position an some data to a [traccar server](https://www.traccar.org/) or any other tracking service which uses the [OSMAnd protocol](https://www.traccar.org/osmand/). You will need to build any Widget or DataField. It is designed and tested for Garmin Edge devices.

If you use the barrel as a background service for a DataField you will only be able to send a position every 5 minutes. This limitation is for saving battery of the devices. If you use this barrel for a widget you don't have this limitation. The suggested interval for sending the position is about 30 seconds. You
will need to set a property `traccarURL` in MainApp.

The following applications using the barrel:
  - DataField: [PauseTimer](https://github.com/britiger/PauseTimer-connectiq-cm) with background service, also sends position to CriticalMaps
