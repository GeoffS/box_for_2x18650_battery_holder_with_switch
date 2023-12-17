include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

batteryHolderX = 42.7;
batteryHolderY = 92;

batteryHolderHole1X = 33.5;
batteryHolderHole1Y = 61;

batteryHolderHole2X = 9.23;
batteryHolderHole2Y = 20.6;

topLipZ = 2;

boxWallXY = 3;
boxWallZ = 3;
boxExteriorRadius = 8;
boxInteriorRadius = boxExteriorRadius - boxWallXY;
boxExteriorCZ = 3;
boxTopZ = boxExteriorCZ + 1;
boxExteriorTopClip = boxExteriorRadius * 0.3;
boxExteriorBottomClip = boxExteriorRadius * 0.3;

boxOutsideX = batteryHolderX;
boxOutsideY = batteryHolderY;

boxInsideX = boxOutsideX - 2*boxWallXY;
boxInsideY = boxOutsideY - 2*boxWallXY;
boxInsideZ = 10; // Overridden by external user code.

echo(str("boxInsideZ = ", boxInsideZ));

boxBottomTopZ = boxWallZ + boxInsideZ + topLipZ;
echo(str("boxBottomTopZ = ", boxBottomTopZ));

boxOutsideZ = boxBottomTopZ + boxTopZ;

echo(str("boxOutsideX, boxOutsideY, boxOutsideZ = ", boxOutsideX, ", ", boxOutsideY, ", ", boxOutsideZ));

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
boxInteriorX1 = boxWallXY + boxInteriorRadius;
boxInteriorY1 = boxWallXY + boxInteriorRadius;

boxInteriorX2 = boxInteriorX1 + boxInsideX - boxInteriorDia;
boxInteriorY2 = boxInteriorY1 + boxInsideY - boxInteriorDia;

module interior()
{
  hull()
  {
    boxInteriorCorner(boxInteriorX1, boxInteriorY1);
    boxInteriorCorner(boxInteriorX2, boxInteriorY1);
    boxInteriorCorner(boxInteriorX1, boxInteriorY2);
    boxInteriorCorner(boxInteriorX2, boxInteriorY2);
  }
}

module boxInteriorCorner(x, y)
{
    z1 = boxWallZ + boxInteriorRadius;

    tsp([x, y, z1], d=boxInteriorDia);
    tsp([x, y, 100], d=boxInteriorDia);
}

batteryLeadsHoleDia = 3;
batteryLeadsHoleX = 6.3;

module boxBottomWithSideLeads()
{
  difference()
  {
    basicBoxBottom();

    sideBatteryLeadsHole();
  }
}

module boxBottomWithBottomLeads()
{
  difference()
  {
    basicBoxBottom();

    bottomBatteryLeadsHole();
  }
}

module basicBoxBottom()
{
  difference()
  {
    box();

    // Trim off the top:
    tc([-200, -200, boxBottomTopZ], 400);

    // Make the holes to mount the battery holder:
    batteryHolderHoleDia = 2.8;

    tcy([batteryHolderHole1X, batteryHolderHole1Y, -5], d=batteryHolderHoleDia, h=10);
    tcy([batteryHolderHole2X, batteryHolderHole2Y, -5], d=batteryHolderHoleDia, h=10);
  }
}

module sideBatteryLeadsHole()
{
    // Hole for the battery leads to enter from the side, just above the exit
    // in the battery-box.
    batteryLeadsHoleY = boxOutsideY-boxWallXY/2; 
    batteryLeadsHoleZ = boxWallZ+batteryLeadsHoleDia/2+boxInteriorDia/2;

    translate([batteryLeadsHoleX, batteryLeadsHoleY, batteryLeadsHoleZ]) 
    {
      quarterTorus(torusOffset=2.85);
      rotate([0, -45, 0]) mirror([0,1,0]) quarterTorus(torusOffset=3.07);
    }
}

module bottomBatteryLeadsHole()
{
  translate([boxOutsideX-15.5, boxOutsideY-7.75, 0])
  {
    // Hole for the battery leads to enter from below:
    d = (3/16)*mm_per_inch;
    tcy([0,0, -10], d=d, h=100);

    // Chamfering in box:
    cz = 3.7;
    cd = cz*2;
    translate([0,0, boxWallZ-d/2-1.5]) 
    {
      cylinder(d1=0, d2=cd, h=cz);
      tcy([0,0,cz-nothing], d=cd, h=10);
    }
  }
}

module quarterTorus(torusOffset)
{
  translate([0, 0, -torusOffset]) rotate([0,90,0]) difference()
  {
    torus2a(batteryLeadsHoleDia/2, torusOffset);
    tcu([nothing, -50, -50], 100);
    tcu([-50, -100-nothing, -50], 100);
  }
}

boxTopLipOffsetXY = 0.1;
module boxTop()
{
  difference()
  {
    exterior();
    tc([-200, -200, boxBottomTopZ-400], 400);
  }
  // Add the lip to fit inside the lower section:
  // %tc([boxWallXY+boxTopLipOffsetXY, boxWallXY+boxTopLipOffsetXY, boxBottomTopZ-topLipZ], [boxInsideX-2*boxTopLipOffsetXY, boxInsideY-2*boxTopLipOffsetXY, topLipZ]);
  hull()
  {
    boxTopLipCorner(boxInteriorX1, boxInteriorY1);
    boxTopLipCorner(boxInteriorX2, boxInteriorY1);
    boxTopLipCorner(boxInteriorX1, boxInteriorY2);
    boxTopLipCorner(boxInteriorX2, boxInteriorY2);
  }
}

module boxTopLipCorner(x, y)
{
  translate([x, y, boxBottomTopZ]) mirror([0,0,1]) simpleChamferedCylinder(d=boxInteriorDia-2*boxTopLipOffsetXY, h=topLipZ, cz=0.6);
}