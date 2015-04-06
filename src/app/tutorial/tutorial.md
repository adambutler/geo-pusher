# Building a location aware realtime chat application with AngularJS & Pusher

In this guide you will learn how to build an AngularJS application that allows realtime communication between people nearby.

[Check out the demo](http://geo-pusher.herokuapp.com/)

Communication applications are everywhere, whether you're tweeting, snapchatting or even meerkatting these tools all require you to be connected to the person you're subscribed to.

But what if you were instead connected by your physical location? Localised information becomes more relevant and communities, particularly in dense areas such as a university grounds, would form organically. Realtime conversations could spawn based on events happening at the present and messages could spread virally outwards from a single location.

In this tutorial we're going to learn how to build such an application using AngularJS and Pusher. Angular provides great flexibility for creating real-time web applications and Pusher gives us the power to broadcast and receive messages without having to manage infrastructure. We'll do this by creating location specific [channels](https://pusher.com/docs/client_api_guide/client_private_channels) that utilise [client events](https://pusher.com/docs/client_api_guide/client_events) for sending and receiving messages. Most of the work will be on the client-side leaving only Express.js to serve files and [authenticate users](https://pusher.com/docs/authenticating_users).

## Tutorial

Here's an outline of the flow -

- The user lands on the Application and we request their GeoLocation, alongside a friendly notice to let them know the status.
- Once we have the users location we generate a channel name based on a low precision lookup of their location. This room name will be the same for people who are near their location.
- Using the Pusher Angular library we subscribe to the private location channel authenticating the user with node Express.js in doing so.
- We then listen for message events on the channel and push them to a full screen map near the location they were published.
- Remember at any time you can [check out the demo](http://geo-pusher.herokuapp.com) and if you get stuck at any point you can always refer to the [completed code](http://github.com/adambutler/geo-pusher).

### Preface

This tutorial assumes basic HTML, CSS and JavaScript ability as well as familiarity with Git and Node.js. If you are not familiar with these I recommend following these tutorials first -

- [HTML/CSS - Code Academy](http://www.codecademy.com/en/tracks/web)
- [Git - tryGit](https://try.github.io/levels/1/challenges/1)
- [Node.js - Node.js for beginners](http://code.tutsplus.com/tutorials/nodejs-for-beginners--net-26314)

### Setup

Lets start by getting the application bootstrapped. By cloning this repo you'll be setup with an empty AngularJS project served by Node express.

```bash
# Note: not yet setup
$ git clone -b starter git@github.com:adambutler/geo-pusher.git
$ cd geo-pusher
$ npm install
```
Great... lets checkout what we've got!

### `/src/app/index.js`

This is where the Angular module is defined & where we list our application routes.

### `/src/app/main/main.controller.js`

This is our main controller we'll use this file to control what happens in our view.

### `/src/app/main/main.html`

This is our main view. We'll use this file to show the map and a form so the user can post up their own messages.

#### Setting up the Pusher app

We need to setup our Pusher app to allow us to authenticate users as well as send & receive messages.

1. Sign up for a [free Pusher account](https://pusher.com/signup).
2. Create a new app called `geopusher`, make sure to **enable client events**.
3. Make a note of your **APP ID, Key & Secret**

![A gifcast showing the steps for creating a Pusher account](https://pusher-geopusher.s3.amazonaws.com/pusher.gif)

#### Setting up the Google developer project

Google keep tight control over who used their API, we therefor need to get a key to use the Google Maps JavaScript API from the developer console.

1. Go to [Google Developers Console](https://console.developers.google.com) and sign in.
2. Create a new project called `geopusher`, and give it a unique project ID.
3. Click create and wait a few seconds whilst your project is created.
4. Go to API's & auth > API's then Google Maps JavaScript API
5. Click Enable API
6. Go to API's & auth > Credentials and then Create a new Key
7. Click Browser key and set the referrer to localhost
8. Make a note of your **API Key**

![A gifcast showing the steps for creating a Google API Key](https://pusher-geopusher.s3-eu-west-1.amazonaws.com/google.gif)

#### Setting up the environment file

We use these keys in a few places and you should avoid committing them into source control. We'll add these keys into an environment file that gets referenced in various parts of the app.

1. Copy the file `.env.example` to `.env`
2. Edit the new `.env` file by populating the values with the ones you have taken notes of.

### Adding Google Maps

First of all we need to add Google Maps to our application. Google provide the JavaScript that we’ll need to include in the `<head>` of our site.

#####`/SRC/INDEX.HTML`

```html
<script src="https://maps.googleapis.com/maps/api/js?key={{ GOOGLE_API_KEY }}"></script>
```

Don’t worry about changing the `GOOGLE_API_KEY` block this will get injected when we the page

We also need a container to render the map to.

#####`/SRC/APP/MAIN/MAIN.HTML`

```html
<div id="map-canvas"></div>
```

We're going to initiate the map with the following options -

#####`/SRC/APP/MAIN/MAIN.CONTROLLER.JS`
```javascript
var mapOptions = {
  zoom: 14,
  center: {
    lat: 51.536208,
    lng: -0.07873
  }
};

var map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
```

Finally we want to make sure we’re using all of the available space in the browser window so we’ll set the following css –

#####`/SRC/APP/INDEX.SCSS`
```css
#map-canvas {
  height: 100%;
  margin: 0;
  padding: 0;
}
```

Now all we have to do is launch the server -

```
$ gulp serve
```

This should automatically launch the browser and you should now see something like this -


![A screenshot showing a browser window with full screen Google Maps](https://pusher-geopusher.s3.amazonaws.com/screenshots/01-google-maps.png)

### Getting GeoLocation

Next up we need to get the users location to do this we will use the GeoLocation API which is well supported across most devices and browsers. The `getCurrentPosition` method will provide us with the latitude and longitude which we’ll use to set the map location.

It sometime takes a few seconds to get the location so it's a good idea to let the user know something is happening in the meantime. To do this we'll use an alert which is shown on load and then will be hidden once the location is known.

Add this code to the end of the controller body -

#####`/SRC/APP/MAIN/MAIN.CONTROLLER.JS`

```javascript
alert = $mdDialog.alert({
  title: 'Getting your location',
  content: 'You may need to allow GeoLocation. Hit accept at the top of your screen.'
});

$mdDialog.show(alert);

navigator.geolocation.getCurrentPosition(function(position) {
  $scope.position = position;
  latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
  map.setCenter(latLng);
  $mdDialog.hide();
});
```

Messages are only going to be available to people who are nearby. A simple way to do this is to use a channel name that contains the geolocation. This channel name should be the same for everybody nearby and is unique to the location. The latitude and longitude values are numbers so we can simply round these numbers to one decimal point, making the closest distance between two points about 11km.

Later on we’ll also want to show messages near to the actors location but for safety we should conceal their exact location. Since we need this functionality in two places we’ll abstract it into a method so we can use it for both, this will also give you the flexibility to adjust the distance to your preference.

#####`/SRC/APP/MAIN/MAIN.CONTROLLER.JS`

```javascript
$scope.getPositionToDegreeOfAccuracy = function(accuracy) {
  return {
    latitude: $scope.position.coords.latitude.toFixed(accuracy),
    longitude: $scope.position.coords.longitude.toFixed(accuracy)
  };
};

$scope.channelName = function() {
  var position = $scope.getPositionToDegreeOfAccuracy(1);
  return "" + position.latitude + position.longitude;
};
```

### Receiving events

Next up we’re going to setup the functionality to receive events. Since the events are going to be coming from users instead of a server we’ll be using private channels. This requires us to authenticate users, which we’ll do with Express.js.

To start we’ll write the client side connection -

#####`/SRC/APP/MAIN/MAIN.CONTROLLER.JS`

```javascript
var client = new Pusher("{{ PUSHER_APP_KEY }}", {
authEndpoint: "{{ HOST_NAME }}/pusher/auth"
});

var pusher = $pusher(client);
```

On the server side we’ll keep things simple by unconditionally accepting clients.

Add the following route -

#####`/SERVER.JS`

```javascript
app.post("/pusher/auth", function(req, res) {
  var socketId = req.body.socket_id;
  var channel = req.body.channel_name;
  var auth = pusher.authenticate(socketId, channel);
  res.send(auth);
});
```

Now launch the server -

```
node index.js
```

Now we’re all setup to be able to receive events in the call to getCurrentPosition lets create a method called subscribeToLocalRoom and call it once the location is known.

```
navigator.geolocation.getCurrentPosition(function(position){
  // code from the last section
  $scope.subscribeToLocalRoom();
});

$scope.subscribeToLocalRoom = function(){
  // to do
}
```

The subscribeToLocalRoom method is going to be handling incoming events and adding them to the map -

#####`/SRC/APP/MAIN/MAIN.CONTROLLER.JS`

```javascript
$scope.subscribeToLocalRoom = function(){
  $scope.channel = pusher.subscribe("private-location-" + $scope.roomName());

  $scope.channel.bind("pusher:subscription_succeeded", function(){
    $scope.state.pusherSubscription.active = true;
  });

  $scope.onMessage = function(data) {
    var position = new google.maps.LatLng(data.position.latitude, data.position.longitude);
    new google.maps.InfoWindow({
      map: map,
      position: position,
      content: data.message
    });
  };

  $scope.channel.bind("client-message-event", $scope.onMessage);
};
```

### Sending events

All that’s left to do is to let users post up their messages, lets start out with the script -

#####`/SRC/APP/MAIN/MAIN.CONTROLLER.JS`

```javascript
$scope.message = {};

$scope.shouldShowNewMessageForm = function() {
  return $scope.state.pusherSubscription.active
};

$scope.post = function() {
  $scope.channel.trigger("client-message-event", {
    message: $scope.message.body,
    position: $scope.getPositionToDegreeOfAccuracy()
  });
};
```

Next we'll create the HTML form -

#####`/SRC/APP/MAIN/MAIN.HTML`

```html
<md-card class="form" ng-show="shouldShowNewMessageForm()">
  <md-card-content>
    <md-input-container flex="">
      <label>Message</label>
      <textarea ng-model="message.body" columns="1" md-maxlength="150"></textarea>
    </md-input-container>
    <md-button class="align-right" ng-click="post()">Send</md-button>
  </md-card-content>
</md-card>
```

The very last thing to do is to position the form in the bottom right corner -

#####`/SRC/APP/INDEX.SCSS`

```css
.form {
  background: #fff;
  position: absolute;
  bottom: 30px;
  right: 30px;
  width: 60%;
  min-width: 600px;

  @media all and (max-width: 670px) {
    right: 0; bottom: 0; left: 0;
    width: auto;
    min-width: 0px;
  }
}
```

If you've done everything right it should look something like this -

![A screenshot of the final result](https://pusher-geopusher.s3.amazonaws.com/screenshots/02-final.png)

If your code isn't running correctly you can refer to the [final code](http://github.com/adambutler/geo-pusher).

## Conclusion

Lets take a look back over what has been built here –

- First we bootstrapped out application with the configuration that we required to use Google Maps & Pusher.
- We then setup our user interface providing a simple but elegant single page view.
- Using the geolocation API we requested the users location and set the map accordingly
- We setup channels deriving their names from the location
- We authenticated users to use private channels and subscribed them to the channel for their location.
- Finally we allowed users to compose their own messages and post them to other people

![A graphic that shows how people & services are connected](https://pusher-geopusher.s3.amazonaws.com/map.png)

The application works well but is quite limited right now here are some things that could make the application a little better –

#### We only get the location once.
To fix this you could instead use the watchPosition method instead of getCurrentPosition to give a better experience to mobile users.

#### You can only see somebody else’s message.
It would probably be a good idea if when you published a message it would come up in your own steam.

#### The messages stay on the map.
To keep the map clear it might be a good idea to remove the messages from the map after a few seconds, perhaps even make them bubbles that pop!

#### There is no stream.
You could push all of the messages into an array and then use angulars ng-repeat functionality to show a nice chat stream.

