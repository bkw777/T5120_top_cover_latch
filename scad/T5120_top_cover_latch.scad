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

// "flat" for SLS/MJF, "cone" for FDM without supports
SCREW_POCKET = "flat"; // [flat,cone]

fitment_clearance = 0.1; // 0.01
fc = fitment_clearance ;
/* [ Hidden ] */
e = 0.001;

/* [ Global ] */
// If fitement_clearance is greater than this,
// then switch to the alternate JawsTec shit-tolerances shape
// to avoid unprintable thin walls
fc_threshold = 0.15; // 0.01
jawstec = (fc-e>fc_threshold);

screw_flange_thickness = 2.5;

DEBUG_BISECT_Z = "none"; // [none,flange,springs,full]
DEBUG_BISECT_Y = "none"; // [none,screws]
PREVIEW_BOLT_POSITION = "relaxed"; // [compressed,relaxed,exploded]

main_fillet_radius = 4;
fr = main_fillet_radius;

// -1 = auto
chamfer_size = -1; // 0.01

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
pawld = throw;   // pawl depth
pawl_top_extra_clearance = 0; // 0.01
pawlc = pawl_top_extra_clearance;
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

bt = fc + bbh + fc + wt; // body thickness
btd = slen-throw-fc;     // bolt top depth
wc = (spcc-bbw-swd)/2;   // wing chamfer
wl = (spw-bfw)/2+e; // wing length or big flange gusset size

cs = (chamfer_size<0) ? (wt/4) : chamfer_size ;
//_cs = (chamfer_size<0) ? (wt/4) : chamfer_size ;
//cs = (_cs>0.1) ? sqrt((_cs+fc*2)^2*2) : 0;
//echo ("_cs",_cs);
echo ("cs",cs);

$fn=72;

/////////////////////////////////////////////////////////////////////////////////

module mirror_copy (v = [1, 0, 0]) {
  children();
  mirror(v) children();
}

// square cylinder
// without r1 & r2 = same as rcube without rv & t
// r1 & r2 makes cones / rounded pyramid
module sqyl (w=0,d=0,h=0,r=0,r1=-1,r2=-1) {
 ra = (r1<0) ? r : r1 ;
 rb = (r2<0) ? r : r2 ;
 R = max(ra,rb);
 hull()
   mirror_copy([0,1,0])
     mirror_copy([1,0,0])
       translate([w/2-R,d/2-R,0])
         cylinder(h=h,r1=ra,r2=rb,center=true);
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
  rl = bbd-wt-wt-fc;  // relaxed length
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
  mirror_copy([1,0,0]) translate([mpcc/2,0,0]) {
    sd = 3;
    sl = 6;
    hd = 6;
    ht = 2.4;
    // screw
    translate([0,0,-sl+mph+screw_flange_thickness]) cylinder(d=3,h=sl+e);
    translate([0,0,mph+screw_flange_thickness]) intersection() {
      cylinder(d=hd,h=ht);
      translate([0,0,-hd+ht]) sphere(r=hd);
    }
    // boss
    cylinder(h=mph,d=mpod);
  }
  translate([0,e-mpy,-cst]) difference() {
    // case sheet
    translate([-50,0,0]) cube([100,50,cst]);
    // slot
    translate([-swid/2,-1,-cst/2]) cube([swid,slen+1,cst*2]);
  }
}

module frame () {

 difference() {

  group () {

    // main body
    // post to post
    hull() mirror_copy([1,0,0]) translate([mpcc/2,0,0]) cylinder(h=bt,r=fr);
    // bolt surround
    translate([-fbw/2,-mpy+fc,0]) cube([fbw,mpy-fc,bt]);
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
    translate([-lpw/2-fc,-mpy+lpy-fc,bbh-1]) cube([fc+lpw+fc,fc+lpl+fc,wt+2]);
    //chamfers
    if (cs && !jawstec) {
      // bolt body-flange chamfer
      mirror_copy([1,0,0]) translate([bbw/2+fc-e,fr-bbd-1,wt+fc+fc+cs]) rotate([0,135,0]) cube([cs*2,bbd+2,cs*2]);
      
      // top of spring way
      translate([spw/2+fc,-mpy+fc+wt+throw-e,wt+fc+fc+cs]) rotate([0,135,90]) cube([cs*2,fc+spw+fc,cs*2]);

      // spring way mouth
      mirror_copy([1,0,0]) translate([spcc/2,-mpy+wt+throw+fc+cs-e,sz]) rotate([90,0,0]) cylinder(d1=swd,d2=swd+cs*2,h=cs);
      // limit pin slot chamfer
      translate([0,lpl/2-mpy+lpy,bbh+cs-e]) sqyl(w=lpw+cs*2+fc*2,d=lpl+cs*2+fc*2,h=cs,r1=cs,r2=0);
    }

    // spring way
      // flange & gusset way
      translate([-spw/2-fc,-mpy-e,-fc-e]) cube([fc+spw+fc,wt+throw+fc+e,bbh+fc+fc+fc+e]);
      // big top flange gusset
      mirror_copy([1,0,0]) {
       translate([bfw/2+fc-e,-mpy+wt+throw+fc-e,-fc-e]) linear_extrude(fc+wt+fc+fc+e) polygon(points = [
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
        translate([bbw/2+fc/2-e,-mpy+wt+throw+fc-e,fc+fc]) linear_extrude(bbh) polygon(points = [
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
  zadj = fc;
  translate([0,0,zadj]) difference() {
    group() {
      // body
      translate([-bbw/2,-mpy+fc,e]) cube([bbw,bbd-fc,bbh-e]);
      // flange
      translate([-bfw/2,-mpy+fc,e]) cube([bfw,bbd-fc,wt-e]);
      // key
      translate([0,-mpy+lpy+lpd/2,bbh+fc]) sqyl(w=lpw,d=lpd,h=wt*2,r=cs);
      // top
      th = cst+fc;
      td = btd-fc;
      //translate([-swid/2+fc,-mpy+fc,-cst+e]) %cube([swid-fc-fc,btd-fc,cst]);
      translate([0,-mpy+fc+td/2,-th/2+fc+e]) sqyl(w=swid-fc-fc,d=td,h=th,r=cs);
      // spring plate
      translate([-spw/2,-mpy+fc,e]) cube([spw,wt,bbh-e]);
      // spring pins
      translate([0,-mpy+wt-e,sz-zadj]) rotate([-90,0,0]) spring_pins();

      // pawl
      hull(){
        //translate([-pawlw/2,-mpy-pawld+fc,e+pawlc]) #cube([pawlw,pawld+wt-fc-pawlc-e,1]);
        da = pawld-pawlc+cs;
        translate([0,-mpy-da/2+fc+cs,e+pawlc+0.5]) sqyl(w=pawlw,d=da,h=1,r=cs);
        //translate([-pawlw/2,-mpy+fc,bbh-1]) #cube([pawlw,wt-fc-e,1]);
        db = wt-fc-e;
        translate([0,-mpy+db/2+fc,bbh-1+0.5]) sqyl(w=pawlw,d=wt-fc-e,h=1,r=cs);
      }

      // big top flange gusset
      mirror_copy([1,0,0]) translate([0,-mpy+wt+fc-e,0]) {
        translate([bfw/2-e,0,e]) linear_extrude(wt-e) polygon(points = [
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
           translate([spw/2+e,-mpy-1,bbh-cs]) rotate([0,-45,0]) cube([cs*2,wt+2,cs*2]);
           translate([spw/2+e-cs/2,-mpy+fc+wt+throw,bbh/2+wt]) rotate([0,-90,0])
             sqyl(w=bbh+cs+cs,d=throw*2+cs+cs,h=cs,r1=cs,r2=0);
           translate([spw/2+e+e,fr+e,wt-cs+e])
             hull () {
               cylinder(h=cs,r1=0,r2=cs);
               translate([0,-bbd+fc-e-e+wt+throw-e-e,0]) cylinder(h=cs,r1=0,r2=cs);
               translate([-wl-e,-bbd-e-e+fc+wt+throw+wl-e,0]) cylinder(h=cs,r1=0,r2=cs);
               translate([-wl-e,0,0]) cylinder(h=cs,r1=0,r2=cs);
           }
           hull () {
             translate([bbw/2,fr+e,bbh-cs+e]) cylinder(h=cs,r1=0,r2=cs);
             translate([bbw/2,-mpy+fc+wt+wc-e-e,bbh-cs+e]) cylinder(h=cs,r1=0,r2=cs);
             translate([bbw/2+wc-e-e,-mpy+fc+wt,bbh-cs+e]) cylinder(h=cs,r1=0,r2=cs);
             translate([spw/2+e,-mpy+fc+wt,bbh-cs+e]) cylinder(h=cs,r1=0,r2=cs);
           }
         }
      }

      // hollow interior
      translate([-bbw/2+wt,-mpy+wt+fc,wt+e]) cube([bbw-wt-wt,bbd,bbh-wt-wt-e]);

      // finger pull
      hull () {
        w=bbw-wt-wt;
        t=e+wt+fc+cst+e;
        translate([-bbw/2+wt,-mpy+wt+fc,-fc-cst-e]) cube([w,1,t]);
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

  cw = mpcc+fr*2+2;
  ct = bt+cst+2;

  bolty =
    PREVIEW_BOLT_POSITION == "compressed" ? throw-e :
    PREVIEW_BOLT_POSITION == "exploded" ? -bbd-2 :
    0;
  cutz =
    DEBUG_BISECT_Z == "flange" ? fc+wt/2 :
    DEBUG_BISECT_Z == "springs" ? sz :
    DEBUG_BISECT_Z == "full" ? -cst-1 :
    bt+1;

  cd = bbd*1.25-bolty+throw+1;

  cuty = DEBUG_BISECT_Y == "screws" ? 0 :
  -cd+fr+throw+1 ;

  %springs();
  difference() {
    group() {
      frame();
      translate([0,bolty,0]) bolt();
    }
    // debug bisect cut cube
    translate([-cw/2,cuty,cutz]) cube([cw,cd,ct]);
  }
} else {
    if (PRINT=="frame") translate([0,0,bt]) rotate([180,0,0]) frame();
    if (PRINT=="bolt") translate([0,bt/2,mpy+pawld]) rotate([90,0,0]) bolt();
}
