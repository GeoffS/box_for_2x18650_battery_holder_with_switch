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
boxExteriorRadius = 3;
boxExteriorTopClip = boxExteriorRadius * 0.3;
boxExteriorBottomClip = boxExteriorRadius * 0.3;

boxOutsideX = batteryHolderX;
boxOutsideY = batteryHolderY;

boxInsideX = boxOutsideX - 2*boxWallXY;
boxInsideY = boxOutsideY - 2*boxWallXY;
boxInsideZ = 10;

echo(str("boxInsideZ = ", boxInsideZ));


boxOutsideZ = boxInsideZ + 2*boxWallZ;
echo(str("boxOutsideX, boxOutsideY, boxOutsideZ = ", boxOutsideX, ", ", boxOutsideY, ", ", boxOutsideZ));

topLipZ = 1.5;

bottomOffset = boxOutsideZ-boxExteriorRadius;

extX1 = 0;
extY1 = 0;
extZ1 = 0 - boxExteriorBottomClip;
extX2 = boxOutsideX;
extY2 = boxOutsideY;
extZ2 = boxOutsideZ + boxExteriorTopClip;

module box()
{
  difference()
  {
    exterior();
    interior();
  }
}

boxExteriorDia = 2*boxWallXY;
boxExteriorCZ = 2;
module exterior()
{
  hull()
  {
    translate([extX1+boxWallXY, extY1+boxWallXY, 0]) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
    translate([extX1+boxWallXY, extY2-boxWallXY, 0]) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
    translate([extX2-boxWallXY, extY1+boxWallXY, 0]) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
    translate([extX2-boxWallXY, extY2-boxWallXY, 0]) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
  }
}

module interior()
{
  tc([boxWallXY, boxWallXY, boxWallZ], [boxInsideX, boxInsideY, boxInsideZ]);
}

module boxBottom()
{
  difference()
  {
    box();

    // Trim off the top:
    tc([-200, -200, boxOutsideZ-boxExteriorRadius-nothing], 400);

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
    box();
    tc([-200, -200, bottomOffset-400], 400);
  }
  // Add the lip to fit inside the lower section:
  oXY = 0.1;
  tc([boxWallXY+oXY, boxWallXY+oXY, bottomOffset-topLipZ], [boxInsideX-2*oXY, boxInsideY-2*oXY, topLipZ]);
}