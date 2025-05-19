// Brian K. White
// top cover door latch for SUN / Oracle Sparc server T5120
// CC BY-SA
//
// frame and bolt both compatible with the original parts
//
// common pen springs work in place of the original springs
//
// screws are M3 x 6mm

FDM = false; // adjust for FDM printing
PRINT = "frame"; // "frame", "bolt"

fr = 4; // flange radius
mpcc = 41; // mount posts center to center
fccc = mpcc-fr*4; // front corner center to center
mpod = 5.4;  // mount post od
mph = 4.8; // mount post height
mpy = 13.8; // mount post Y from edge
swid = 18; // slot width
throw = 3; // latch throw distance
slen = 15.5;   // slot len
cst = 1; // case sheet thickness

bbw = 17; // bolt body width
bbd = 16; // bolt body depth
btd = 13; // bolt top depth
bbh = 8; // bolt body height
bfw = 21; // bolt flange width
lpw = 2.5; // limit pin width
lpd = 6; // limit pin depth
lpy = 3; // limit pin Y end to edge

wt = 1.5; // wall thickness (& flanges)
bt = bbh + wt; // body thickness

swd = 5; // spring way id
spd = 3; // spring post od
spw = 29; // spring plate width
spcc = 23; // spring posts center to center
sz = 4.7; // spring z position
 
e = 0.01;
$fn=72;

/////////////////////////////////////////////////////////////////////////////////

module mirror_copy(v = [1, 0, 0]) {
 children();
 mirror(v) children();
}

// the site on the server case where the latch mounts
module site () {
 mirror_copy([1,0,0])
  translate([mpcc/2,0,0])
   cylinder(h=mph,d=mpod);
  translate([0,-mpy,-cst]) difference() {
   translate([-50,0,0]) cube([100,50,cst]);
   translate([-swid/2,-e,-cst/2]) cube([swid,slen+e,cst*2]);
 }
}

module frame () {

 sid = 3; // screw hole id
 spd = 6.2; // screw head pocket id

 difference() {

  group () {
   hull() mirror_copy([1,0,0]) translate([mpcc/2,0,0]) cylinder(h=bt,r=fr);
   *translate([0,-mpy/2,0]) hull() mirror_copy([0,1,0]) mirror_copy([1,0,0]) translate([fccc/2,-mpy/2+fr,0]) cylinder(h=bt,r=fr);
   translate([-fccc/2-fr,-mpy,0]) cube([fccc+fr+fr,mpy,bt]);
  }

  group() {
   mirror_copy([1,0,0]) translate([mpcc/2,0,0]) {
    // mount post pocket
    translate([0,0,-e]) cylinder(h=mph,d=mpod+0.5);
    // screw head pocket
    if (FDM) hull() {
     // FDM printing needs 45 deg overhang
     ch = (spd-sid)/2; // chamfer height
     *translate([0,0,mph+wt+ch/2]) cylinder(h=bt,d=spd);
     *translate([0,0,mph+wt-ch/2]) cylinder(h=ch,d1=sid,d2=spd);
     translate([0,0,mph+wt+ch]) cylinder(h=bt,d=spd);
     translate([0,0,mph+wt]) cylinder(h=ch,d1=sid,d2=spd);
    } else {
     // SLS printing can print it flat
     translate([0,0,mph+wt]) cylinder(h=bt,d=spd);
    }
    // screw hole
    cylinder(h=bt*2,d=sid);
   }
   // bolt body way
   translate([0,0,-bt/2+bbh+0.2]) cube([bbw+0.4,50,bt],center=true);
   // bolt flange way
   translate([0,0,wt/2]) cube([bfw+0.4,50,wt+0.4],center=true);
   // limit pin slot
   translate([-lpw/2-0.1,-mpy+lpy-0.1,bbh]) cube([lpw+0.2,lpd+throw+0.2,wt*2]);
   
   // spring way
   mirror_copy([1,0,0]) translate([spcc/2,fr-wt,sz]) rotate([90,0,0]) cylinder(d=swd,h=mpy+fr+1);
   // spring plate way
   translate([-spw/2-0.2,-mpy-e,-e]) cube([spw+0.4,wt+throw,bbh+0.2]);

  }

 }
}

module bolt () {
 difference() {
  group() {
   // body
   translate([-bbw/2,-mpy,0]) cube([bbw,bbd,bbh]);
   // flange
   translate([-bfw/2,-mpy,0]) cube([bfw,bbd,wt]);
   // key
   translate([-lpw/2,-mpy+lpy,bbh-1]) cube([lpw,lpd,wt+1]);
   // top
   translate([-bbw/2,-mpy,-cst+e]) cube([bbw,btd,cst+1]);
   // spring plate
   translate([-spw/2,-mpy,0]) cube([spw,wt,bbh]);
   // spring post
   mirror_copy([1,0,0]) translate([spcc/2,-mpy+e,sz]) rotate([-90,0,0]) cylinder(d=3,h=wt+throw+1);
   // pawl
   hull(){
    w=8;
    d=2;
    translate([-w/2,-mpy-d,0.5]) cube([w,d+wt-e,1]);
    translate([-w/2,-mpy,bbh-1]) cube([w,wt-e,1]);
   }
 
 
  }

  group() {
   // hollow interior
   translate([-bbw/2+wt,-mpy+wt,wt]) cube([bbw-wt-wt,bbd,bbh-wt-wt]);

   // finger pull
   hull () {
    w=bbw-wt-wt;
    t=wt+cst+1;
    translate([-bbw/2+wt,-mpy+wt,-cst-e]) cube([w,wt,t]);
     translate([0,-w/2-mpy+btd-wt,-cst-e])
     difference() {
      cylinder(d=w,h=t);
      translate([-w/2-1,-w,-1]) cube([w+2,w,t+2]);
     }
   }
  }
 }

}

/////////////////////////////////////////////////////////////////////////////////

if ($preview) {
 %site();
 frame();
 bolt();
} else {
 if (PRINT=="frame") frame();
 if (PRINT=="bolt") bolt();
}