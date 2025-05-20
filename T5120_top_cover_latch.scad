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

// server case mounting site features
mpcc = 41;   // mount posts center to center
mpod = 5.4;  // mount post od
mph = 4.8;   // mount post height
mpy = 13.8;  // mount post Y (center to front edge)
swid = 18;   // slot width
slen = 15.5; // slot length
cst = 1;     // case sheet thickness

// original parts reference features
sz = 4.7;  // spring z position
spcc = 23; // spring posts center to center


sid = 3.2;   // screw hole id
shpid = 6.2; // screw head pocket id
fr = 4;      // flange radius
fbw = mpcc-fr-fr; // frame body outside width
throw = 3;   // latch throw distance

pawlw = 8;   // pawl width
pawld = 2;   // pawl depth
pawlc = 0.5; // pawl clearance

bbw = 17;  // bolt body width
bbd = 16;  // bolt body depth
btd = slen-throw;  // bolt top depth
bbh = 8;   // bolt body height
bfw = 21;  // bolt flange width (the top plate)
lpw = 2.5; // limit pin width
lpd = 6;   // limit pin depth
lpy = 3;   // limit pin Y end to edge

wt = 1.5; // wall thickness

swd = 5;   // spring way id
spd = 3;   // spring post od
spw = 29;  // spring plate width (the front face) 
 
fc = FDM ? 0.25 : 0.15 ;  // fitment clearance
e = 0.001;
$fn=72;

bt = fc + bbh + fc + wt; // body thickness

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

 difference() {

  group () {

   // main body
   // post to post
   hull() mirror_copy([1,0,0]) translate([mpcc/2,0,0]) cylinder(h=bt,r=fr);
   // bolt surround
   translate([-fbw/2,-mpy,0]) cube([fbw,mpy,bt]);
   // fillets
   mirror_copy([1,0,0]) translate([-fbw/2+e,-fr+e,0]) difference() {
    r=2;
    translate([-r,-r,0]) cube([r,r,bt]);
    translate([-r,-r,-1]) cylinder(r=r,h=bt+2);
   }


 }

  group() {
   mirror_copy([1,0,0]) translate([mpcc/2,0,0]) {
    // mount post pocket
    translate([0,0,-e]) cylinder(h=mph,d=fc+mpod+fc);
    // screw head pocket
    if (FDM) hull() {
     // FDM printing needs 45 deg overhang
     ch = (shpid-sid)/2; // chamfer height
     translate([0,0,mph+wt+ch]) cylinder(h=bt,d=shpid);
     translate([0,0,mph+wt]) cylinder(h=ch,d1=sid,d2=shpid);
    } else {
     // SLS printing can print it flat
     translate([0,0,mph+wt]) cylinder(h=bt,d=shpid);
    }
    // screw hole
    cylinder(h=bt*2,d=sid);
   }
   // bolt body way
   translate([0,0,-bt/2+fc+bbh+fc]) cube([fc+bbw+fc,mpy*3,bt],center=true);
   // bolt flange way
   translate([0,0,wt/2+fc-e]) cube([fc+bfw+fc,mpy*3,fc+wt+fc+e*2],center=true);
   // limit pin slot
   translate([-lpw/2-fc,-mpy+lpy-fc,bbh]) cube([fc+lpw+fc,fc+lpd+throw+fc,wt*2]);
   
   // spring way
   mirror_copy([1,0,0]) translate([spcc/2,fr-wt,sz]) rotate([90,0,0]) cylinder(d=swd,h=mpy+fr+1);
   // spring plate way
   translate([-spw/2-fc,-mpy-e,-e]) cube([fc+spw+fc,wt+throw+fc+e,bbh+fc+fc+e]);

  }

 }
}

module bolt () {
 translate([0,0,fc]) difference() {
  group() {
   // body
   translate([-bbw/2,-mpy,0]) cube([bbw,bbd,bbh]);
   // flange
   translate([-bfw/2,-mpy,0]) cube([bfw,bbd,wt]);
   // key
   translate([-lpw/2,-mpy+lpy,bbh-e]) cube([lpw,lpd,wt+fc+e]);
   // top
   translate([-swid/2+fc,-mpy,-cst-fc]) cube([swid-fc-fc,btd,cst+fc+e]);
   // spring plate
   translate([-spw/2,-mpy,0]) cube([spw,wt,bbh]);
   // spring post
   mirror_copy([1,0,0]) translate([spcc/2,-mpy+e,sz]) rotate([-90,0,0]) cylinder(d1=spd,d2=spd-1,h=wt+throw+1);
   // pawl
   hull(){
    translate([-pawlw/2,-mpy-pawld,pawlc]) cube([pawlw,pawld+wt-e,1]);
    translate([-pawlw/2,-mpy,bbh-1]) cube([pawlw,wt-e,1]);
   }
 
 
  }

  group() {
   // hollow interior
   translate([-bbw/2+wt,-mpy+wt,wt]) cube([bbw-wt-wt,bbd,bbh-wt-wt]);

   // finger pull
   hull () {
    w=bbw-wt-wt;
    t=wt+cst+fc;
    translate([-bbw/2+wt,-mpy+wt,-cst]) cube([w,wt,t]);
     translate([0,-w/2-mpy+btd-wt,-fc-cst-1])
     difference() {
      cylinder(d=w,h=t+2);
      translate([-w/2-1,-w,-1]) cube([w+2,w,t+4]);
     }
   }
  }
 }

}

/////////////////////////////////////////////////////////////////////////////////

if ($preview) {
 %site();
 frame();
 //translate([0,throw,0]) // move bolt to compresed position
  bolt();
} else {
 if (PRINT=="frame") frame();
 if (PRINT=="bolt") bolt();
}