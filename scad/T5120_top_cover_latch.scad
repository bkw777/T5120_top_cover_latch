// Brian K. White
// top cover door latch for SUN / Oracle Sparc server T5120
// CC BY-SA
//
// frame and bolt both compatible with the original parts
//
// common pen springs work in place of the original springs
//
// screws are M3 x 6mm

// several of these dimensions are fixed
// to keep the parts compatible with the original parts

PRINT = "bolt"; // "frame", "bolt", "both"
FDM = false;    // adjust for FDM printing

// preview options
//CUT_HEIGHT = "finger_pull";
//CUT_HEIGHT = "bolt_flange";
//CUT_HEIGHT = "mid";
//BOLT_POSITION = "compressed";
//BOLT_POSITION = "exploded";

// not configurable - server case mounting site dimensions
mpcc = 41;   // mount posts center to center
mpod = 5.4;  // mount post od
mph = 4.8;   // mount post height
mpy = 13.8;  // mount post Y (center to front edge)
swid = 18;   // slot width
slen = 15.5; // slot length
cst = 1;     // case sheet thickness
// slightly configurable - must clear rf shield sponges
fr = 4;      // flange radius
fbw = mpcc-fr-fr; // frame body outside width

// original parts reference features
sz = 4.7;  // spring z position
spcc = 23; // spring posts center to center
spw = 29;  // spring plate width (the front face) 
bfw = 21;  // bolt flange width (the top plate)
lpw = 2.5; // limit pin width
lpd = 6;   // limit pin depth
lpy = 3;   // limit pin Y end to edge

// configuration
fc = FDM ? 0.3 : 0.2 ;  // fitment clearance

sid = 3+fc;  // screw hole id
shpid = 6+fc*2; // screw head pocket id
throw = 3;   // latch throw distance

pawlw = 8;   // pawl width
pawld = 2;   // pawl depth
pawlc = 0.5; // pawl top clearance

bbw = 17;  // bolt body width
bbd = 16;  // bolt body depth
bbh = 8;   // bolt body height

wt = 1.5;  // wall thickness
//screw_flange_thickness = wt;
screw_flange_thickness = 2;

swd = fc+4.5+fc; // spring way id
spd = 3;   // spring post od

e = 0.001;
$fn=72;

bt = fc + bbh + fc + wt; // body thickness
btd = slen-throw-fc;     // bolt top depth
wc = (spcc-bbw-swd)/2;   // wing chamfer

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
        // FDM printing needs 45 deg overhang to omit supports
        ch = (shpid-sid)/2; // chamfer height
        translate([0,0,mph+wt+ch]) cylinder(h=bt,d=shpid);
        translate([0,0,mph+wt]) cylinder(h=ch,d1=sid,d2=shpid);
      } else {
        // SLS printing can print it flat
        translate([0,0,mph+screw_flange_thickness]) cylinder(h=bt,d=shpid);
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

    // gusset way
    wl = (spw-bfw)/2+fc+e;
    mirror_copy([1,0,0]) {
     translate([bfw/2-e,-mpy+wt+throw+fc-e-e,-e]) linear_extrude(fc+wt+fc+e) polygon(points = [
      [0, 0],
      [0, wl],
      [wl, 0]
     ]);
     translate([bbw/2-e,-mpy+wt+throw+fc-e,fc-e]) linear_extrude(bbh+fc+e) polygon(points = [
      [0, 0],
      [0, wc],
      [wc, 0]
     ]);
    }

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
      mirror_copy([1,0,0]) translate([spcc/2,-mpy+e,sz]) {
        rotate([-90,0,0]) cylinder(d1=spd,d2=spd-1,h=wt+throw);
        translate([0,wt+throw,0]) sphere(d=spd-1);
      }
      // pawl
      hull(){
        translate([-pawlw/2,-mpy-pawld,pawlc]) cube([pawlw,pawld+wt-e,1]);
        translate([-pawlw/2,-mpy,bbh-1]) cube([pawlw,wt-e,1]);
      }

      // gusset
      wl = (spw-bfw)/2+e;
      mirror_copy([1,0,0]) translate([0,-mpy+wt-e,0]) {
        translate([bfw/2-e,0,0]) linear_extrude(wt) polygon(points = [
          [0, 0],
          [0, wl],
          [wl, 0]
        ]);
        translate([bbw/2-e,0,wt/2]) linear_extrude(bbh-wt/2) polygon(points = [
          [0, 0],
          [0,wc],
          [wc, 0]
        ]);
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

  bolty =
    is_undef(BOLT_POSITION) ? 0 :
    BOLT_POSITION == "compressed" ? throw :
    BOLT_POSITION == "exploded" ? -bbd-2 :
    0;
  cutz = 
    is_undef(CUT_HEIGHT) ? bt+1 :
    CUT_HEIGHT == "finger_pull" ? -cst/2 :
    CUT_HEIGHT == "bolt_flange" ? fc+wt/2 :
    CUT_HEIGHT == "mid" ? sz :
    bt+1;
    
  difference() {
    group() {
      frame();
      translate([0,bolty,0]) bolt();
    }
    translate([-mpcc/2-fr-1,-mpy-throw,cutz]) cube([mpcc+fr*2+2,mpy*2,bt+cst]);
  }
} else {
  o = (PRINT=="both") ? 10 : 0; 
  if (PRINT=="frame" || PRINT=="both") translate([0,o,bt]) rotate([180,0,0]) frame();
  if (PRINT=="bolt" || PRINT=="both") translate([0,bt/2-o,mpy+pawld]) rotate([90,0,0]) bolt();
}