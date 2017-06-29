const eyeGazeOverlay = document.createElement('div');
eyeGazeOverlay.id = 'eyegaze-overlay';
eyeGazeOverlay.style.position  ='fixed';
var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
eyeGazeOverlay.style.width = w;
eyeGazeOverlay.style.height = h;
eyeGazeOverlay.style['z-index'] = 9999999;

document.body.appendChild(eyeGazeOverlay);

const app = Elm.Main.embed(eyeGazeOverlay);
app.ports.screenSize.send({width: screen.width, height: screen.height})
