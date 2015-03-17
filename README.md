# GeoPusher

A location aware chat application that uses [Pusher](http://pusher.com).

![A gifcast showing sending a test message from one browser to another, it appears on a map of the connected browser at the location that it was sent from.](https://cloud.githubusercontent.com/assets/1238468/6698098/a32176ce-cced-11e4-9dbb-4b07169669f0.gif)

### Dependencies

- [Node.js](http://nodejs.org/)
- [Gulp](http://gulpjs.com/)

### Setup

```bash
$ git clone git@github.com:adambutler/geo-pusher.git
$ cd geo-pusher
$ npm install
$ bower install
$ cp .env.example .env
```

Create a [Pusher](http://pusher.com) account and application and add the application details to -

- `.env`
- `/src/app/main/main.controller.coffee`

### Running in development mode

```bash
$ gulp serve
```

This will launch the browser pointed to http://localhost:3000

### Build the application

```bash
$ gulp build
```

## Contributing

Contributions are welcome, please follow [GitHub Flow](https://guides.github.com/introduction/flow/index.html)
