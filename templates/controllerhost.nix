{ ... }: {
  myFeatures.hardware.controllers = {
    enable = true;
    xbox = true;        # For your main controller
    playstation = true; # For when friends come over
    nintendo = false;
  };
}
