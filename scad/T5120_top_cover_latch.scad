// Brian K. White
// top cover door latch for SUN / Oracle Sparc server T5120
// CC BY-SA
//
// frame and bolt both compatible with the original parts
//
// common pen springs work in place of the original springs
// (4.5mm od x 20-25mm length x 0.5mm wire)
//
// screws are M3 x 6mm

// several of these dimensions are fixed
// to keep the parts compatible with the original parts

PRINT = "frame"; // [frame,bolt]
SCREW_POCKET = "flat"; // [flat,cone]

fitment_clearance = 0.1; // 0.01
fc = fitment_clearance ;
fc_threshold = 0.15; // fc above this switches to the jawstec (shit tolerances) model
jawstec = (fc>=fc_threshold);

screw_flange_thickness = 2;

DEBUG_BISECT_HEIGHT = "none"; // [none,finger pull,bolt flange,mid]
PREVIEW_BOLT_POSITION = "exploded"; // [relaxed,compressed,exploded]

flange_fillet_radius = 4;
fr = flange_fillet_radius;

// -1 = auto = fitment_clearance*3
chamfer_size = -1; // 0.1
_cs = (chamfer_size<0) ? (fc*3) : chamfer_size ;
cs = (_cs>0.1) ? sqrt((_cs+fc*2)^2*2) : 0;
echo ("_cs",_cs);
echo ("cs",cs);

/* [Hidden] */
// not configurable - server case mounting site dimensions
mpcc = 41;   // mount posts center to center
mpod = 5.4;  // mount post od
mph = 4.8;   // mount post height
mpy = 13.8;  // mount post Y (center to front edge)
swid = 18;   // slot width
slen = 15.5; // slot length
cst = 1;     // case sheet thickness

fbw = mpcc-fr-fr; // frame body outside width

// original parts reference dimensions
// configurable if you don't care about
// compatibility with the original parts
sz = 4.7;  // spring z position
spcc = 23; // spring posts center to center
spw = 29;  // spring plate width (the front face)
bfw = 21;  // bolt flange width (the top plate)
lpw = 2.5; // limit pin width
lpd = 6;   // limit pin depth
lpy = 3;   // limit pin Y end to edge

sid = 3+fc;  // screw hole id
shpid = 6+fc*2; // screw head pocket id

/* [Global] */
throw = 3;   // latch throw distance
pawl_throw_clearance = 0.5;
pawld = throw - pawl_throw_clearance ;   // pawl depth
pawl_top_clearance = 0.5;
pawlc = pawl_top_clearance;
pawl_width = 8;
pawlw = pawl_width;

wall_thickness = 1.5;
wt = wall_thickness;

spring_diameter = 4.5; // 0.1
swd = spring_diameter + fc*2; // spring way id
spd = spring_diameter - 1; // spring post od

gusset_covers_gap = !jawstec;
gusset_ext = gusset_covers_gap ? throw : 0;

/* [Hidden] */
bbw = 17;      // bolt body width
bbd = mpy+fr;  // bolt body depth
bbh = 8;       // bolt body height

e = 0.001;
$fn=72;

bt = fc + bbh + fc + wt; // body thickness
btd = slen-throw-fc;     // bolt top depth
wc = (spcc-bbw-swd)/2;   // wing chamfer

/////////////////////////////////////////////////////////////////////////////////

module mirror_copy (v = [1, 0, 0]) {
  children();
  mirror(v) children();
}

module spring (od=10, c=25, l=50, wd=1, s=18, $fn=12) {
    r = (od-wd)/2;    
    ld = (l-wd)/c/360;
    
    translate([0,0,wd/2]) for ( a = [s:s:360*c] ) {
        xa=r*cos(a-s);
        ya=r*sin(a-s);
        za=(a-s)*ld;

        xb=r*cos(a);
        yb=r*sin(a);
        zb=a*ld;

        hull() {
          translate([xa,ya,za]) sphere(d=wd);
          translate([xb,yb,zb]) sphere(d=wd);
        }
    }
}

module springs () {
  od = spring_diameter;        // OD
  wd = 0.5;        // wire diameter
  el = 25;         // exploded length
  rl = bbd-wt-wt;  // relaxed length
  cl = rl-throw;   // compressed length
  c = el/2;   // coils

  l =
    PREVIEW_BOLT_POSITION == "compressed" ? cl :
    PREVIEW_BOLT_POSITION == "relaxed" ? rl :
    el;

  mirror_copy([1,0,0]) translate([spcc/2,fr-wt,sz]) rotate([90,0,0]) spring(od=od,c=c,l=l,wd=wd);
}

module spring_pins () {
  da = spd-0.5;
  db = spd-1;
  gap = fc; // 0, fc, 1
  h = (mpy+fr-wt*2-throw)/2-(db/2)-gap;
  mirror_copy([1,0,0]) translate([spcc/2,0,0]) {
    cylinder(d1=da,d2=db,h=h);
    translate([0,0,h]) sphere(d=db);
  }
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
      if (SCREW_POCKET=="cone") hull() {
        // 45 deg overhang for FDM printing
        ch = (shpid-sid)/2; // chamfer height
        translate([0,0,mph+wt+ch]) cylinder(h=bt,d=shpid);
        translate([0,0,mph+wt]) cylinder(h=ch,d1=sid,d2=shpid);
      } else {
        // flat overhang for MJF/SLS printing
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
    lpl = lpd+throw;
    translate([-lpw/2-fc,-mpy+lpy-fc,bbh]) cube([fc+lpw+fc,fc+lpl+fc,wt*2]);
    //chamfers
    if (cs && !jawstec) {
      // bolt body-flange chamfer
      mirror_copy([1,0,0]) translate([bbw/2,0,fc+wt]) rotate([0,45,0]) cube([cs,mpy*3,cs],center=true);
      // top of spring way
      translate([0,-mpy+wt+throw-fc,wt+fc+fc-e]) rotate([0,45,90]) cube([cs,fc+spw+fc,cs],center=true);
      // spring way mouth
      mirror_copy([1,0,0]) translate([spcc/2,-mpy+wt+throw+fc+cs/2,sz]) rotate([90,0,0]) cylinder(d1=swd,d2=swd+cs+cs,h=cs);
      // limit pin slot chamfer
      s = _cs+fc;
      hull() {
        translate([0,lpl/2-mpy+lpy,s/2+bbh+fc+fc]) cube([lpw,lpl,s],center=true);
        translate([0,lpl/2-mpy+lpy,-1/2+bbh+fc]) cube([s+fc+lpw+fc+s,lpl+s*2+fc*2,1],center=true);
      }
    }

    // spring way
      // flange & gusset way
      wl = (spw-bfw)/2+fc+e;
      translate([-spw/2-fc,-mpy-e,-fc]) cube([fc+spw+fc,wt+throw+fc+e,bbh+fc+fc+fc]);
      mirror_copy([1,0,0]) {
       translate([bfw/2-e,-mpy+wt+throw+fc-e-e,-fc]) linear_extrude(fc+wt+fc+fc) polygon(points = [
        [0, 0],
        [0, wl+gusset_ext],
        [wl, gusset_ext],
        [wl, 0]
       ]);
    }
    if (jawstec) {
      // spring way
      wh = bbh-wt+fc;
      //hull() mirror_copy([1,0,0]) translate([spw/2-wh/2+fc,fr-wt,wh/2+wt+fc]) rotate([90,0,0]) cylinder(d=wh,h=mpy+fr-wt);
      translate([-spw/2-fc,-mpy-e,wt+fc]) cube([fc+spw+fc,mpy+fr-wt,wh]);
    } else {
      mirror_copy([1,0,0]) {
        translate([spcc/2,fr-wt,sz]) rotate([90,0,0]) cylinder(d=swd,h=mpy+fr+1);
        translate([bbw/2+fc/2,-mpy+wt+throw+fc-e,fc-e]) linear_extrude(bbh+fc+e) polygon(points = [
          [0, 0],
          [0, wc],
          [wc, 0]
         ]);
      }
    }

  }

 }

 // spring pins
 if (jawstec) translate([0,fr-wt+e,sz]) rotate([90,0,0]) spring_pins();

}

module bolt () {
  wl = (spw-bfw)/2+e; // flange gusset size
  zadj = fc;
  translate([0,0,zadj]) difference() {
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
      // spring pins
      translate([0,-mpy+wt-e,sz-zadj]) rotate([-90,0,0]) spring_pins();

      // pawl
      hull(){
        translate([-pawlw/2,-mpy-pawld,pawlc]) cube([pawlw,pawld+wt-e,1]);
        translate([-pawlw/2,-mpy,bbh-1]) cube([pawlw,wt-e,1]);
      }

      // gusset
      mirror_copy([1,0,0]) translate([0,-mpy+wt-e,0]) {
        translate([bfw/2-e,0,0]) linear_extrude(wt) polygon(points = [
          [0, 0],
          [0, wl+gusset_ext],
          [wl, gusset_ext],
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
      // chamfers
      if (cs && !jawstec) {
        mirror_copy([1,0,0]) {
          // key
          kh = wt+fc+1;
          translate([0,-mpy+lpy+lpd/2,0]) mirror_copy([0,1,0]) translate([lpw/2+fc,lpd/2+fc,kh/2+bbh]) rotate([0,0,45]) cube([cs,cs,kh],center=true);
          hull() {
            // body
            translate([bbw/2+fc,bbd/2-mpy+wt+wc,bbh+fc]) rotate([0,45,0]) cube([cs,bbd,cs],center=true);
            // spring plate top
            cl = (spw-bbw)/2;
            translate([cl/2+bbw/2+wc,-mpy+wt+fc,bbh+fc]) rotate([0,90,0]) rotate([0,0,45]) cube([cs,cs,cl],center=true);
          }
          // flange
          hull() {
            translate([bfw/2+fc,bbd/2-mpy+wt+wl-e-e+gusset_ext,wt+fc]) rotate([0,45,0]) cube([cs,bbd,cs],center=true);
            translate([1+spw/2+e,-mpy+wt+fc+fc+gusset_ext,wt]) rotate([0,90,0]) rotate([0,0,45]) cube([cs,cs,2],center=true);
          }
          translate([spw/2+fc,-mpy+gusset_ext,wt+fc]) rotate([0,45,0]) cube([cs,gusset_ext,cs],center=true);
          _cs=cs*1.418;
          translate([spw/2+fc+fc-e,-mpy+wt+e+e,wt+e+e]) rotate([90,0,-90]) cylinder(h=_cs/2,d1=_cs,d2=0);

          // face corner
          translate([spw/2+fc,wt/2-mpy,bbh+fc]) rotate([0,45,0]) cube([cs,fc+wt+fc,cs],center=true);
          // spring plate end
          translate([spw/2+fc,-mpy+wt+fc,bbh/2+wt]) rotate([0,0,45]) cube([cs,cs,bbh],center=true);
        }
      }

      // hollow interior
      translate([-bbw/2+wt,-mpy+wt,wt]) cube([bbw-wt-wt,bbd,bbh-wt-wt]);

      // finger pull
      hull () {
        w=bbw-wt-wt;
        t=e+wt+fc+cst+e;
        translate([-bbw/2+wt,-mpy+wt,-fc-cst-e]) cube([w,wt,t]);
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
    PREVIEW_BOLT_POSITION == "compressed" ? throw :
    PREVIEW_BOLT_POSITION == "exploded" ? -bbd-2 :
    0;
  cutz =
    DEBUG_BISECT_HEIGHT == "finger pull" ? -cst/2 :
    DEBUG_BISECT_HEIGHT == "bolt flange" ? fc+wt/2 :
    DEBUG_BISECT_HEIGHT == "mid" ? sz :
    bt+1;

  %springs();
  difference() {
    group() {
      frame();
      translate([0,bolty,0]) bolt();
    }
    // debug bisect cut cube
    bw=mpcc+fr*2+2;
    bd=bbd*1.25-bolty+throw+1;
    translate([-bw/2,-bd+fr+throw+1,cutz]) cube([bw,bd,bt+cst]);
  }
} else {
    if (PRINT=="frame") translate([0,0,bt]) rotate([180,0,0]) frame();
    if (PRINT=="bolt") translate([0,bt/2,mpy+pawld]) rotate([90,0,0]) bolt();
}
