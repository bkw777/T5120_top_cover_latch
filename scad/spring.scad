
// modified from: https://gist.github.com/pschatzmann/1bf4617ff8543016333a3881d6522912

module line(start, end, d) {
  hull() {
    node(start,d);
    node(end,d);
  }      
}

module node(pos, d) {
    translate(pos) sphere(d=d);
}

module spring(od=10, c=25, l=50, wd=1, step=18, $fn=12) {
    r = (od-wd)/2;    
    ld = (l-wd)/c/360;
    
    translate([0,0,wd/2]) for ( angle = [step : step : 360*c] ) {
        x0=r*cos(angle-step);
        y0=r*sin(angle-step);
        z0=(angle-step)*ld;
        x=r*cos(angle);
        y=r*sin(angle);
        z=angle*ld;

        line([x0,y0,z0],[x,y,z],d=wd);
    }
}