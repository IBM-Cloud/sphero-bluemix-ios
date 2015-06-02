sphero-bluemix-ios
================================================================================

This [project](https://github.com/IBM-Bluemix/sphero-bluemix-ios) is an iOS app that demonstrates how to steer a [Sphero](http://www.gosphero.com/sphero/) ball via URL commands using [IBM Bluemix](http://bluemix.net), the [MQTT](http://mqtt.org) protocol and the [IBM Internet of Things](https://console.ng.bluemix.net/?ace_base=true#/store/serviceOfferingGuid=8e3a9040-7ce8-4022-a36b-47f836d2b83e&fromCatalog=true) service. Watch the [videos](http://heidloff.net/nh/home.nsf/article.xsp?id=13.04.2015120246NHEDSS.htm) to learn more.

For the communication between the iOS app and the ball over bluetooth the [Sphero iOS SDK](https://github.com/orbotix/Sphero-iOS-SDK) is used. Since the SDK is not available under an open source license two directories need to be downloaded and copied into the iOS project.

For the communication between the iOS app and IBM Bluemix the [IBM WebSphere iOS MQTT Client](http://www-933.ibm.com/support/fixcentral/swg/selectFix?product=ibm/WebSphere/WebSphere+MQ&fixids=1.0.0.4-WS-MQCP-MA9B&source=dbluesearch&function=fixId&parent=ibm/WebSphere) is used which needs to be downloaded and copied into the iOS project as well. 

Authors: Mike Robertson, Bryan Boyd


Setting up the iOS Project
----------------------------------------------------------------------------------

After importing the dependencies and opening the project in Xcode, you should have the following [project structure](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-ios/master/images/projectstructure.png).

Download the [Sphero iOS SDK](https://github.com/orbotix/Sphero-iOS-SDK/zipball/master) and extract it. Copy the following two folders into the root of your iOS project.

* [RobotKit.framework](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-ios/master/images/importsphero1.png)
* [RobotUIKit.framework](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-ios/master/images/importsphero2.png)

To import the MQTT client library [download](http://www-933.ibm.com/support/fixcentral/swg/selectFix?product=ibm/WebSphere/WebSphere+MQ&fixids=1.0.0.4-WS-MQCP-MA9B&source=dbluesearch&function=fixId&parent=ibm/WebSphere) the package and extract it. Make sure you select and download the refresh pack "1.0.0.4-WS-MQCP-MA9B.zip". From the [zip file](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-ios/master/images/importmqtt1.png) import the following two files into the [Chariot folder](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-ios/master/images/importmqtt2.png).

* libiosMQTT.a
* MqttOCClient.h


Setup of the Bluemix Application and the Node-RED Flow
----------------------------------------------------------------------------------

In order to send commands to the iOS app a Node-RED flow in IBM Bluemix is used in combination with the IBM Internet of Things Foundation. 

Log in to Bluemix and create a new application, e.g. MySphero, based on the [Internet of Things Foundation Starter](https://console.ng.bluemix.net/?ace_base=true#/store/appType=web&cloudOEPaneId=store&appTemplateGuid=iot-template&fromCatalog=true). Additionally add the [Internet of Things](https://console.ng.bluemix.net/?ace_base=true#/store/serviceOfferingGuid=8e3a9040-7ce8-4022-a36b-47f836d2b83e&fromCatalog=true) service to it.

In the next step you have to register your own device. Open the dashboard of the Internet of Things service and navigate to 'Add Device'. As device type choose 'and' and an unique device id - [screenshot](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-android/master/images/registerdevice1.png). As result you'll get an org id and password - [screenshot](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-android/master/images/registerdevice2.png).

In order to import the flow open your newly [created Bluemix application](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-ios/master/images/flow.png) and open the Node-RED editor, e.g. http://mysphero.mybluemix.net/red, and choose [import from clipboard]((https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-android/master/images/nodered4.png). You find the flow (flow.txt) in the sub-directory 'noderedflow'. In the [outgoing IoT node](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-android/master/images/nodered3.png) select your unique device id and deploy the application.


Run the iOS App and invoke URLs
----------------------------------------------------------------------------------

Before running the app you need to enter the Internet of Things configuration from the previous step in the iOS app. You can either do this in the UI of the app or directly in the source code. If you don’t want to modify the source code you can enter your configuration in the app’s [welcome screen](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-ios/master/images/welcomescreen.png). Alternatively you can define the values of your org id, the unique id and the password in the file [LoginViewController.m](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-ios/master/images/config.png).

The app can not be run via the emulator but only via actual iOS devices. Before you can do this you need to sign the app. Also make sure that both Wifi and Bluetooth are enabled.

After this you can see the connected device in the IoT dashboard. You can now invoke the following URL commands to steer the Sphero ball.

* [/go](http://mysphero.mybluemix.net/go)
* [/stop](http://mysphero.mybluemix.net/stop)
* [/left](http://mysphero.mybluemix.net/left)
* [/right](http://mysphero.mybluemix.net/right)
* [/reverse](http://mysphero.mybluemix.net/reverse)

![alt text](https://raw.githubusercontent.com/IBM-Bluemix/sphero-bluemix-ios/master/images/flow.png "Flow")