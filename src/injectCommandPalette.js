const eyeGazeOverlay = document.createElement('div');
eyeGazeOverlay.id = 'eyegaze-overlay';
eyeGazeOverlay.style.position  ='fixed';
var w = Math.max(document.documentElement.clientWidth, window.innerWidth || 0);
var h = Math.max(document.documentElement.clientHeight, window.innerHeight || 0);
eyeGazeOverlay.style.width = w;
eyeGazeOverlay.style.height = h;
eyeGazeOverlay.style['z-index'] = 2000000001;

document.body.appendChild(eyeGazeOverlay);

const CommandPalette = Elm.Main.embed(eyeGazeOverlay);
CommandPalette.ports.screenSize.send({width: screen.width, height: screen.height});

var TreeNavigation = TreeNavigation || undefined;
CommandPalette.ports.commandFired.subscribe(direction => {
  switch (direction) {
    case "North":
      // something
      if (TreeNavigation) {
        TreeNavigation.ports.receiveExternalCmd.send('Up');
      }
      break;
    case "East":
      if (TreeNavigation) {
        TreeNavigation.ports.receiveExternalCmd.send('Next');
      }
      break;

    case "South":
      if (TreeNavigation) {
        TreeNavigation.ports.receiveExternalCmd.send('Select');
      }
      break;

    case "West":
      if (TreeNavigation) {
        TreeNavigation.ports.receiveExternalCmd.send('Previous');
      }
      break;
  }
})
