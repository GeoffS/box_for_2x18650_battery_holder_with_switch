include <../OpenSCADdesigns/MakeInclude.scad>
include <../OpenSCADdesigns/chamferedCylinders.scad>
use <../OpenSCADdesigns/torus.scad>

mm_per_inch = 25.4;

makeTop = false;
makeBottom = false;
makeBoardMountTestPiece = false;

boardX = 30;
boardY = 70;
echo(str("boardX, boardY = ", boardX, ", ", boardY));

batteryHolderX = 42.7;
batteryHolderY = 92;

batteryHolderHole1X = 33.2;
batteryHolderHole1Y = 60.5;

batteryHolderHole2X = 9.23;
batteryHolderHole2Y = 20.6;

holeInsetOnBoardXY = 0.15  * mm_per_inch;
holeDia = 2.4;
supportOD = 4.5; //0.3 * mm_per_inch;
supportZ = 4;

holeCtrsOnBoardX = 26;
holeCtrsOnBoardY = 66;

boxWallXY = 3;
boxWallZ = 3;
boxExteriorRadius = 3;
boxExteriorTopClip = boxExteriorRadius * 0.3;
boxExteriorBottomClip = boxExteriorRadius * 0.3;

boardInsetXY = 0.5;
holeInsetXY = boardInsetXY + holeInsetOnBoardXY;

boardBatteryHolderSeparation = 3;

boxOutsideX = batteryHolderX; //boxInsideX + 2*boxWallXY;
boxOutsideY = batteryHolderY; //boxInsideY + 2*boxWallXY;

boxInsideX = boxOutsideX - 2*boxWallXY;
boxInsideY = boxOutsideY - 2*boxWallXY; //boardInsetXY + boardY + boardBatteryHolderSeparation + batteryHolderY;
boxInsideZ = supportZ + 21;


boxOutsideZ = boxInsideZ + 2*boxWallZ;
echo(str("boxOutsideX, boxOutsideZ = ", boxOutsideX, ", ", boxOutsideZ));

topLipZ = 1.5;

bottomOffset = boxOutsideZ-boxExteriorRadius;

extX1 = 0;
extY1 = 0;
extZ1 = 0 - boxExteriorBottomClip;
extX2 = boxOutsideX;
extY2 = boxOutsideY;
extZ2 = boxOutsideZ + boxExteriorTopClip;

mntInsetXY = boxWallXY + holeInsetXY;
mntX1 = boxOutsideX/2 - holeCtrsOnBoardX/2;
mntY1 = extY1 + mntInsetXY;
mntX2 = boxOutsideX/2 + holeCtrsOnBoardX/2;
mntY2 = mntY1 + holeCtrsOnBoardY;

batterySlotX = 6.3;

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
  difference()
  {
    union()
    {
      hull()
      {
        translate([extX1+boxWallXY, extY1+boxWallXY, 0]) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
        translate([extX1+boxWallXY, extY2-boxWallXY, 0]) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
        translate([extX2-boxWallXY, extY1+boxWallXY, 0]) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
        translate([extX2-boxWallXY, extY2-boxWallXY, 0]) simpleChamferedCylinderDoubleEnded(boxExteriorDia, boxOutsideZ, boxExteriorCZ);
      }

      // Crazy complex guide for the battery wires:
      minkowski() 
      {
        difference()
        {
          d = 5;
          y = boxOutsideY - 1.3;
          union()
          {
            hull()
            {
              z = d/2+boxExteriorCZ-1.78;
              tsp([batterySlotX, y, z], d=d);
              tsp([batterySlotX, y-10, z], d=d);
              tsp([batterySlotX, y, 10], d=d);
            }
            hull()
            {
              tsp([batterySlotX, y, 16], d=d);
              tsp([batterySlotX, y, 21], d=d);
            }
          }
          d1 = 2.9;
          tcy([batterySlotX, boxOutsideY+d1/2-0.25, -10], d=d1, h=100);
        }
        sphere(d=0.5);
      }
    }

    // Trim the bottom just in case something is sticking down:
    tcu([-10, -10, -400], 400);
  }
}

module interior()
{
  tc([boxWallXY, boxWallXY, boxWallZ], [boxInsideX, boxInsideY, boxInsideZ]);
}

module boardMount(x, y, a=0)
{
  translate([x, y, boxWallZ])
  {
    cylinder(d=supportOD, h=supportZ);
    cylinder(d2=supportOD, d1=supportOD+4, h=supportZ-0.8);
  }
}

boardMountNutZ = 3.5;
boardMountNutDia = 4.65;
layerThickness = 0.2;
module boardMountHole(x, y)
{
  translate([x, y, -100]) cylinder(d=holeDia, h=200);
  translate([x, y, -10+boardMountNutZ]) cylinder(d=boardMountNutDia, h=10, $fn=6);
}

module boardMountSacrificialLayer(x, y)
{
  translate([x, y, boardMountNutZ]) cylinder(d=6, h=layerThickness);
}

module wireOpening(x, y, dia)
{
  wireOpeningOffsetZ =  bottomOffset - (dia/2 + topLipZ + 1);

  tt = boxWallXY/2+dia/2;
  translate([x, y-boxWallXY/2, wireOpeningOffsetZ-dia]) rotate(90,[0,1,0]) 
  {
    difference()
    {
      torus2a(dia/2, tt);
      tcu([0, -200, -200], 400);
    }
    difference()
    {
      tcu([-20-0, -10, -dia/2], [20, 20, dia]);
      tcy([0, 0, -dia/2], d=2*tt, h=dia);
    }
  }
}

module boxBottom()
{
  difference()
  {
    union()
    {
      box();
      // Make the mounts:
      boardMount(mntX1, mntY1, 0);
      boardMount(mntX1, mntY2, -90);
      boardMount(mntX2, mntY1, 90);
      boardMount(mntX2, mntY2, 180);
    }

    // Trim off the top:
    tc([-200, -200, boxOutsideZ-boxExteriorRadius-nothing], 400);

    // Make the board mounting holes:
    boardMountHole(mntX1, mntY1);
    boardMountHole(mntX1, mntY2);
    boardMountHole(mntX2, mntY1);
    boardMountHole(mntX2, mntY2);

    // Make the holes to mount the battery holder:
    batteryHolderHoleDia = 2.9;
    tcy([batteryHolderHole1X, batteryHolderHole1Y, -5], d=batteryHolderHoleDia, h=10);
    tcy([batteryHolderHole2X, batteryHolderHole2Y, -5], d=batteryHolderHoleDia, h=10);

    // Make the wire holes/slots for the LED stips:
    dx = 6;
    wireOpening(x=boxOutsideX/2-dx, y=boxOutsideY, dia=3.5);
    wireOpening(x=boxOutsideX/2+dx, y=boxOutsideY, dia=3.5);

    // Make the wire holes/slots for the battery:
    wireOpening(x=batterySlotX, y=boxOutsideY, dia=2.5);

    // Holes for the battery wires zip-tie:
    translate([batterySlotX, boxOutsideY-boxWallXY/2, 13]) torus2a(1, 2.9);
  }

    // Make the board mounting sacrifical layers:
    boardMountSacrificialLayer(mntX1, mntY1);
    boardMountSacrificialLayer(mntX1, mntY2);
    boardMountSacrificialLayer(mntX2, mntY1);
    boardMountSacrificialLayer(mntX2, mntY2);
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

module boardMountTestPiece()
{
  intersection() 
  {
    boxBottom();
    tcy([mntX1, mntY2], d=10.7, h=100);
  }
}

module clip(d=0)
{
	// tc([-200, boxOutsideY/2-d, -200], [400, 400, 400]);
  // tc([mntX1, -200, -200], [400, 400, 400]);
  // tc([boxOutsideX/2-6,-200,-200], 400);
  // tc([6.3,-200,-200], 400);
  // tcu([-200, mntY1, -200], 400);
  // tcu([-200, mntY2, -200], 400);
}

if(developmentRender)
{
	display() boxBottom();
  // displayGhost() boxTop();
  // display() boardMountTestPiece();

  displayGhost() boardGhost();
  displayGhost() tcy([mntX1, mntY1, 0.6], d=2, h=8);
}
else
{
	if(makeTop) rotate([0,0,90]) rotate(180, [0,1,0]) translate([0,0,-boxOutsideZ]) boxTop();
  if(makeBottom) rotate([0,0,90]) boxBottom();
  if(makeBoardMountTestPiece) boardMountTestPiece();
}

module boardGhost()
{
  translate([boxOutsideX/2-15, mntY1-2, boxWallZ+supportZ]) difference()
  {
    tcu([0,0,0], [30, 70, 1.6]);

    tcy([ 2,  2, -5], d=2.5, h=10);
    tcy([ 2, 68, -5], d=2.5, h=10);
    tcy([28,  2, -5], d=2.5, h=10);
    tcy([28, 68, -5], d=2.5, h=10);
  }
}
