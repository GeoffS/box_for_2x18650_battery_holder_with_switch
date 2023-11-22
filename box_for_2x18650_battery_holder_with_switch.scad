include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

batteryHolderX = 42.7;
batteryHolderY = 92;

batteryHolderHole1X = 33.2;
batteryHolderHole1Y = 60.5;

batteryHolderHole2X = 9.23;
batteryHolderHole2Y = 20.6;

boxWallXY = 3;
boxWallZ = 3;
boxExteriorRadius = 8;
boxInteriorRadius = boxExteriorRadius - boxWallXY;
boxTopZ = 3;
boxExteriorTopClip = boxExteriorRadius * 0.3;
boxExteriorBottomClip = boxExteriorRadius * 0.3;

boxOutsideX = batteryHolderX;
boxOutsideY = batteryHolderY;

boxInsideX = boxOutsideX - 2*boxWallXY;
boxInsideY = boxOutsideY - 2*boxWallXY;
boxInsideZ = 10; // Overridden by external user code.

echo(str("boxInsideZ = ", boxInsideZ));


boxOutsideZ = boxInsideZ + 2*boxWallZ;
echo(str("boxOutsideX, boxOutsideY, boxOutsideZ = ", boxOutsideX, ", ", boxOutsideY, ", ", boxOutsideZ));

topLipZ = 1.5;

bottomOffset = boxOutsideZ-boxExteriorRadius;

cornerX1 = boxExteriorRadius;
cornerY1 = boxExteriorRadius;
cornerX2 = boxOutsideX - boxExteriorRadius;
cornerY2 = boxOutsideY - boxExteriorRadius;

cornerXY1 = [cornerX1, cornerY1, 0];
cornerXY2 = [cornerX2, cornerY1, 0];
cornerXY3 = [cornerX1, cornerY2, 0];
cornerXY4 = [cornerX2, cornerY2, 0];


module box()
{
  difference()
  {
    exterior();
    interior();
  }
}

boxExteriorDia = 2*boxExteriorRadius;
boxExteriorCZ = 2;
module exterior()
{
  hull()
  {
    translate(cornerXY1) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
    translate(cornerXY2) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
    translate(cornerXY3) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
    translate(cornerXY4) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
  }
}

boxInteriorDia = 2*boxInteriorRadius;
module interior()
{
  hull()
  {
    x1 = boxWallXY + boxInteriorRadius;
    y1 = boxWallXY + boxInteriorRadius;

    x2 = x1 + boxInsideX - boxInteriorDia;
    y2 = y1 + boxInsideY - boxInteriorDia;

    boxInteriorCorner(x1, y1);
    boxInteriorCorner(x2, y1);
    boxInteriorCorner(x1, y2);
    boxInteriorCorner(x2, y2);
  }
}

module boxInteriorCorner(x, y)
{
    z1 = boxWallZ + boxInteriorRadius;

    tsp([x, y, z1], d=boxInteriorDia);
    tsp([x, y, 100], d=boxInteriorDia);
}

module boxBottom()
{
  difference()
  {
    box();

    // Trim off the top:
    tc([-200, -200, boxOutsideZ-boxTopZ-nothing], 400);

    // Make the holes to mount the battery holder:
    batteryHolderHoleDia = 2.9;
    tcy([batteryHolderHole1X, batteryHolderHole1Y, -5], d=batteryHolderHoleDia, h=10);
    tcy([batteryHolderHole2X, batteryHolderHole2Y, -5], d=batteryHolderHoleDia, h=10);
  }
}

module boxTop()
{
  difference()
  {
    exterior();
    tc([-200, -200, bottomOffset-400], 400);
  }
  // Add the lip to fit inside the lower section:
  oXY = 0.1;
  tc([boxWallXY+oXY, boxWallXY+oXY, bottomOffset-topLipZ], [boxInsideX-2*oXY, boxInsideY-2*oXY, topLipZ]);
}