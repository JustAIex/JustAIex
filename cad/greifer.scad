// =====================================================================
//  Ballgreifer fuer die Tennisschlaeger-Spitze  -  Entwurf v0.1
//  Parametrisches OpenSCAD-Modell (alle Masse in mm)
//
//  Koordinaten:  z = Schlaegerachse, +z zeigt vom Schlaeger zum Ball
//                x = entlang des Rahmens (in der Saitenebene)
//                y = senkrecht zur Saitenebene
//  z = 0 ist die Unterseite der Greiferbasis (dort sitzt der Anschlagring).
// =====================================================================

/* [Ansicht] */
// assembly | sattel | gehaeuse | kralle | spule | anschlag | deck | koppel | taster
part      = "assembly";
open_deg  = 0;      // 0 = geschlossen, 20 = offen
show_ball = true;
section   = false;  // Schnittansicht (nur assembly)

/* [Schlaeger - HIER NACHMESSEN] */
frame_beam    = 24.5;  // Rahmenhoehe senkrecht zur Saitenebene (Wilson Clash 100: 24,5)
bumper_extra  = 2.5;   // Zugabe fuer Kopfschutzband (gesamt, beide Seiten)
frame_depth   = 12;    // Rahmenbreite in der Saitenebene (nur fuer die Darstellung)
tip_R         = 105;   // Aussenradius des Rahmens an der Spitze (Schaetzwert)
string_pitch  = 10.5;  // Abstand der mittleren Laengssaiten (Schaetzwert)
n_holes       = 6;     // Anzahl Saitenloecher im Sattel (6 Loecher = 3 Schlaufen)
string_hole_d = 3.4;

/* [Ball] */
ball_r = 33.5;         // Tennisball 65,4 - 68,6 mm Durchmesser

/* [Greifer] */
pivot_R   = 26;        // Abstand Fingergelenk von der Mittelachse
pivot_z   = -11;
arm_len   = 16;        // Innenhebel (Gelenk -> Nase)
arm_h     = 3.6;
nose_d    = 4.6;
hub_r     = 4.5;
finger_w  = 8;
swing     = 20;        // Oeffnungswinkel der Finger
ring_h    = 6;         // Anschlagring
ball_top  = 2;         // z der Balloberkante bei Anschlag
zc        = ball_top + ball_r;

/* [Schieber] */
sp_r        = 13.1;
slot_h      = 4.9;
sp_flange   = 2.2;
sp_h        = slot_h + 2*sp_flange;
sp_slot_w   = finger_w + 0.7;
sp_slot_in  = 7.0;
lug_t       = 2.4;
lug_h       = 7.2;
lug_hole    = 4.0;     // Lochabstand ueber Schieber-Oberkante
lug_x1      = 2.0;     // Aussenflaeche der Lasche (= Aussenflaeche Servohorn)

/* [Gehaeuse] */
wall     = 2.4;
box_w    = 72;         // x
box_d    = 46.1;       // y
box_r    = 4;
base_d   = 64;         // Basis ist in y breiter (Fingergelenke)
base_r   = 10;
base_h   = 19;
cham     = 6;
floor_t  = 2.0;
pocket_r = 13.5;
slot_w   = finger_w + 0.6;
slot_top = -16.2;
in_w     = box_w - 2*wall;
in_d     = box_d - 2*wall;

/* [Servo MG90S] */
sv_L = 22.8; sv_W = 12.2; sv_H = 22.7; sv_off = 6.1;
sv_tab_span = 32.3; sv_tab_z0 = 16; sv_tab_t = 2.5;
horn_R  = 5.5;         // genutztes Loch im Servohorn (Abstand von der Achse)
link_L  = 22;          // Koppelstange Loch-Loch
x_b     = lug_x1 - 34; // Servo-Boden (x), Horn-Aussenflaeche liegt 34 mm darueber
y_s     = -5;
z_s     = pivot_z - sp_h/2 - lug_hole - link_L;   // Servoachse

/* [Elektronik-Ebene / Sattel] */
z_deck0  = -58;        // Auflage Elektroniktraeger
deck_t   = 2;
z_sf     = -69;        // Sattel-Flachseite = Oberkante Stirnwaende
z_skirt  = -81;        // Ende der Seitenschuerzen
z_scr    = -75;        // Schrauben Schuerze -> Sattel
scr_x    = 20;
sad_len  = box_w;
sad_w    = in_d - 0.3;
sad_t0   = 5;          // Dicke ueber dem Rahmen in der Mitte
str_t    = 3;          // Material unter der Saite
groove_w = 3;
seat_w   = frame_beam + bumper_extra;
sad_drop = tip_R - sqrt(tip_R*tip_R - sad_len*sad_len/4);
sad_h    = sad_t0 + sad_drop + 10;

$fn = 48;
eps = 0.05;

// ---------------------------------------------------------------- Helfer
module zbox(x0,x1,y0,y1,z0,z1) translate([x0,y0,z0]) cube([x1-x0,y1-y0,z1-z0]);
module rrect(w,d,r) hull() for(sx=[-1,1], sy=[-1,1]) translate([sx*(w/2-r), sy*(d/2-r)]) circle(r=r);
module chain(p) for(i=[0:len(p)-2]) hull(){
    translate([p[i][0],p[i][1]]) circle(r=p[i][2]);
    translate([p[i+1][0],p[i+1][1]]) circle(r=p[i+1][2]);
}

// ---------------------------------------------------------------- Kralle
// Profil in der (r,z)-Ebene, geschlossene Stellung
rr_tab  = [[-35,1.3],[-28,2.1],[-18,2.8],[-5,3.4],[10,3.8],[25,4.0],[40,4.0]];
gap_tab = [[-35,0],[-28,0],[-18,0.6],[-5,1.0],[40,1.0]];
arc_pts = [for(a=[40:-2.5:-35]) let(rr=lookup(a,rr_tab), g=lookup(a,gap_tab), rho=ball_r+g+rr)
            [rho*cos(a), zc - rho*sin(a), rr]];
body_pts = concat([[pivot_R, pivot_z, hub_r],[29.5, 1, 4.2]], arc_pts);
P  = [pivot_R, pivot_z];
N0 = P + [-arm_len*cos(swing/2), -arm_len*sin(swing/2)];

module kralle_2d() difference(){
    union(){
        chain(body_pts);
        hull(){ translate(P) circle(d=arm_h); translate(N0) circle(d=arm_h); }
        translate(N0) circle(d=nose_d);
        translate(P) circle(r=hub_r);
    }
    translate(P) circle(d=3.3);
}
// Druckteil: flach liegend
module kralle_print() linear_extrude(finger_w) kralle_2d();
// eingebaut, Finger in +x-Richtung, um theta geoeffnet
module kralle(theta=0) rotate([90,0,0]) linear_extrude(finger_w, center=true)
    translate(P) rotate(-theta) translate(-P) kralle_2d();

// ---------------------------------------------------------------- Schieber
module spule() difference(){
    union(){
        translate([0,0,-sp_h/2]) cylinder(r=sp_r, h=sp_h, $fn=72);
        translate([lug_x1-lug_t, -4, -sp_h/2-lug_h]) cube([lug_t, 8, lug_h+eps]);
    }
    for(k=[0:3]) rotate([0,0,90*k])
        translate([sp_slot_in, -sp_slot_w/2, -slot_h/2]) cube([20, sp_slot_w, slot_h]);
    translate([lug_x1-lug_t-1, 0, -sp_h/2-lug_hole]) rotate([0,90,0]) cylinder(d=1.7, h=lug_t+2, $fn=20);
}

// ---------------------------------------------------------------- Koppelstange
module koppel() difference(){
    hull(){ cylinder(d=7,h=2.5); translate([link_L,0,0]) cylinder(d=7,h=2.5); }
    translate([0,0,-1]) cylinder(d=2.3,h=5,$fn=20);
    translate([link_L,0,-1]) cylinder(d=2.3,h=5,$fn=20);
}

// ---------------------------------------------------------------- Anschlagring
module anschlag() difference(){
    cylinder(d=34, h=ring_h, $fn=72);
    translate([0,0,-1]) cylinder(d=20, h=ring_h+2, $fn=72);
    translate([0,0,zc]) sphere(r=ball_r+0.2, $fn=96);
}

// ---------------------------------------------------------------- Gehaeuse
module ledge(sx,sy,lw=6) hull(){
    translate([sx*(in_w/2-lw/2), sy*(in_d/2-lw/2), z_deck0+0.01]) cube([lw,lw,0.02], center=true);
    translate([sx*(in_w/2-0.01), sy*(in_d/2-0.01), z_deck0+lw]) cube(0.02, center=true);
    translate([sx*(in_w/2-0.01), sy*(in_d/2-lw+0.01), z_deck0+0.01]) cube(0.02, center=true);
    translate([sx*(in_w/2-lw+0.01), sy*(in_d/2-0.01), z_deck0+0.01]) cube(0.02, center=true);
}

module gehaeuse_shell() {
    difference(){
        union(){
            // Basis mit Fase zum Kasten
            hull(){
                translate([0,0,-base_h+cham]) linear_extrude(base_h-cham) rrect(box_w, base_d, base_r);
                translate([0,0,-base_h]) linear_extrude(0.01) rrect(box_w, box_d, box_r);
            }
            // Kasten
            translate([0,0,z_sf]) linear_extrude(-z_sf-base_h+eps) rrect(box_w, box_d, box_r);
            // Seitenschuerzen (greifen ueber den Sattel)
            difference(){
                translate([0,0,z_skirt]) linear_extrude(z_sf-z_skirt+eps) rrect(box_w, box_d, box_r);
                zbox(-box_w, box_w, -in_d/2, in_d/2, z_skirt-1, z_sf+1);
            }
        }
        // Innenraum
        translate([0,0,z_sf-1]) linear_extrude(-z_sf-base_h+1) rrect(in_w, in_d, box_r-wall);
    }
}

module gehaeuse_internals() {
    zl = z_s + sv_W/2;                     // Servo-Auflage
    // Servobett
    zbox(-in_w/2-eps, -14.5, y_s-sv_off, y_s-sv_off+sv_L, zl, -base_h+eps);
    // Pfosten mit Nuten fuer die Servolaschen
    zbox(-19.5, -10, -in_d/2-eps, y_s-sv_off-0.2, z_s-sv_W/2, -base_h+eps);
    zbox(-19.5, -10, y_s-sv_off+sv_L+0.2, in_d/2+eps, z_s-sv_W/2, -base_h+eps);
    // Auflagen fuer den Elektroniktraeger
    for(sx=[-1,1], sy=[-1,1]) ledge(sx,sy);
}

module pin_cut() translate([pivot_R,0,pivot_z]) rotate([-90,0,0]) {
    translate([0,0,-slot_w/2-12]) cylinder(d=2.7, h=12+eps, $fn=20);   // Gewinde in Kunststoff
    translate([0,0,-slot_w/2]) cylinder(d=3.3, h=slot_w/2+10, $fn=20); // Durchgang
    translate([0,0,10]) cylinder(d=6.4, h=40, $fn=28);                 // Kanal fuer Schraubenkopf
}

module gehaeuse() difference(){
    union(){ gehaeuse_shell(); gehaeuse_internals(); }
    // Tasche fuer den Schieber
    translate([0,0,-base_h-1]) cylinder(r=pocket_r, h=base_h-floor_t+1, $fn=72);
    // Fingerschlitze + Gelenkbolzen
    for(k=[0:3]) rotate([0,0,90*k]) {
        zbox(12, 60, -slot_w/2, slot_w/2, slot_top, 1);
        pin_cut();
    }
    // Nuten fuer Servolaschen
    zbox(x_b+sv_tab_z0-0.25, x_b+sv_tab_z0+sv_tab_t+0.25,
         y_s-sv_off+sv_L/2-sv_tab_span/2-0.5, y_s-sv_off+sv_L/2+sv_tab_span/2+0.5,
         z_s-sv_W/2-1, z_s+sv_W/2);
    // Schlitz fuer Kabelbinder (haelt den Servo)
    zbox(-27, -23.5, y_s-sv_off-1, y_s-sv_off+sv_L+1, z_s+sv_W/2+2, z_s+sv_W/2+4);
    // USB-Ausschnitte (+x): Pico (Micro-USB) und Lademodul (USB-C)
    zbox(in_w/2-1, box_w/2+1, -15.7, -4.1, z_sf-1, -59.5);
    zbox(in_w/2-1, box_w/2+1,   5.6, 18.2, z_sf-1, -59.5);
    // Schiebeschalter + Kabelausgang (-x)
    zbox(-box_w/2-1, -in_w/2+1, -9.5, -0.7, -66.6, -62.4);
    zbox(-box_w/2-1, -in_w/2+1, -18, -14.5, z_sf-1, -65);
    // Schrauben Schuerze -> Sattel
    for(sx=[-1,1]) translate([sx*scr_x, 0, z_scr]) rotate([90,0,0]) cylinder(d=3.4, h=box_d+2, center=true, $fn=20);
}

// ---------------------------------------------------------------- Sattel
function hole_x(i) = (i-(n_holes-1)/2)*string_pitch;
module sattel() {
    zcf = z_sf - sad_t0 - tip_R;           // Kruemmungsmittelpunkt des Rahmens
    difference(){
        zbox(-sad_len/2, sad_len/2, -sad_w/2, sad_w/2, z_sf-sad_h, z_sf);
        // Rahmenkanal
        translate([0,0,zcf]) rotate([90,0,0]) cylinder(r=tip_R, h=seat_w, center=true, $fn=240);
        // Saitennut auf der Aussenseite (Saitenschlaufen liegen versenkt)
        difference(){
            zbox(-sad_len, sad_len, -groove_w/2, groove_w/2, z_sf-sad_h-1, z_sf+1);
            translate([0,0,zcf]) rotate([90,0,0]) cylinder(r=tip_R+str_t, h=groove_w+2, center=true, $fn=240);
        }
        // Saitenloecher (parallel zur Schlaegerachse)
        for(i=[0:n_holes-1]) translate([hole_x(i),0,z_sf-sad_h-1]) cylinder(d=string_hole_d, h=sad_h+2, $fn=24);
        // Schrauben + Mutterntaschen (M3)
        for(sx=[-1,1], sy=[-1,1]) {
            translate([sx*scr_x, sy*(sad_w/2-3), z_scr]) rotate([90,0,0]) cylinder(d=3.4, h=6.2, center=true, $fn=20);
            zbox(sx*scr_x-2.9, sx*scr_x+2.9, sy*(sad_w/2-3.5)-1.4, sy*(sad_w/2-3.5)+1.4, z_sf-sad_h-1, z_scr+3.3);
        }
    }
}

// ---------------------------------------------------------------- Elektroniktraeger
module deck() difference(){
    translate([0,0,z_deck0-deck_t]) linear_extrude(deck_t) rrect(in_w-0.6, in_d-0.5, 2);
    zbox(-31, -20, -in_d/2-1, -in_d/2+5, z_deck0-deck_t-1, z_deck0+1);   // Kabeldurchfuehrung
    zbox(-10, 0, in_d/2-4, in_d/2+1, z_deck0-deck_t-1, z_deck0+1);
}

// ---------------------------------------------------------------- Tasterhalter (am Griff)
module taster() difference(){
    translate([-11,-10,0]) cube([22,20,9]);
    translate([0,0,-14+3]) rotate([0,90,0]) cylinder(r=14, h=30, center=true, $fn=96);  // liegt auf Griff/Herz
    translate([-6.3,-6.3,5.2]) cube([12.6,12.6,5]);                                     // Taster 12x12
    translate([-12,-2,5.2]) cube([8,4,5]);                                              // Kabel
    for(sx=[-1,1]) translate([sx*8.6-1.6,-11,2.8]) cube([3.2,22,1.6]);                  // Kabelbinder
}

// ---------------------------------------------------------------- Dummies fuer die Montageansicht
module servo_dummy() multmatrix([[0,0,1,x_b],[1,0,0,y_s],[0,1,0,z_s],[0,0,0,1]]) {
    color("RoyalBlue") {
        translate([-sv_off,-sv_W/2,0]) cube([sv_L,sv_W,sv_H]);
        translate([sv_L/2-sv_off-sv_tab_span/2,-sv_W/2,sv_tab_z0]) cube([sv_tab_span,sv_W,sv_tab_t]);
        cylinder(d=11.8,h=28.5);
    }
    color("Gold") cylinder(d=4.8,h=32);
}
function clamp(v) = max(-1,min(1,v));
module antrieb(theta) {
    zsp = pivot_z + arm_len*sin(theta - swing/2);
    zl  = zsp - sp_h/2 - lug_hole;
    phi = asin(clamp((z_s - (zl - link_L))/horn_R));
    py  = y_s + horn_R*cos(phi);  pz = z_s - horn_R*sin(phi);
    color("Orange") translate([0,0,zsp]) spule();
    // Servohorn
    color("White") hull(){
        translate([lug_x1-1.6, y_s, z_s]) rotate([0,90,0]) cylinder(d=7,h=1.6);
        translate([lug_x1-1.6, y_s+12*cos(phi), z_s-12*sin(phi)]) rotate([0,90,0]) cylinder(d=4,h=1.6);
    }
    // Koppelstange
    color("Crimson") hull(){
        translate([lug_x1, py, pz]) rotate([0,90,0]) cylinder(d=7,h=2.5);
        translate([lug_x1, 0, zl]) rotate([0,90,0]) cylinder(d=7,h=2.5);
    }
}
module elektronik_dummy() {
    color("Silver")      zbox(-18,18,-15,15, z_deck0, z_deck0+6);                 // LiPo
    color("ForestGreen") zbox(in_w/2-51.2,in_w/2-0.2,-20.4,0.6, -61.2,-60);       // Pico
    color("DodgerBlue")  zbox(in_w/2-28.2,in_w/2-0.2,3.4,20.4, -61.2,-60);        // TP4056
    color("Purple")      zbox(-32,-9,3.4,20.4, -61.2,-60);                        // Step-Up
}
module rahmen_dummy() {
    zcf = z_sf - sad_t0 - tip_R;
    color("DimGray") translate([0,0,zcf]) rotate([90,0,0]) linear_extrude(frame_beam, center=true)
        intersection(){
            difference(){ circle(r=tip_R-0.2,$fn=240); circle(r=tip_R-frame_depth,$fn=240); }
            polygon([[0,0],[-tip_R*1.2,tip_R*0.75],[-tip_R*1.2,tip_R*1.3],[tip_R*1.2,tip_R*1.3],[tip_R*1.2,tip_R*0.75]]);
        }
    color("Yellow") for(i=[0:n_holes-1]) translate([hole_x(i),0,zcf+tip_R*0.72]) cylinder(d=1.3,h=tip_R*0.28+str_t,$fn=12);
}

// Schnitt: jedes Teil einzeln schneiden, damit die Farben erhalten bleiben
module sec() { if(section) intersection(){ children(); translate([-300+lug_x1+2.6,-300,-300]) cube([300,600,600]); } else children(); }
module assembly(theta=0) {
    color("SlateGray") sec() gehaeuse();
    color("DarkSlateGray") sec() sattel();
    color("Tan") sec() deck();
    color("Tomato") sec() for(k=[0:3]) rotate([0,0,90*k]) kralle(theta);
    color("Black") sec() anschlag();
    antrieb(theta);
    servo_dummy();
    sec() elektronik_dummy();
    sec() rahmen_dummy();
    if(show_ball) color("GreenYellow", section ? 0.35 : 0.9) sec() translate([0,0,zc]) sphere(r=ball_r, $fn=64);
}

// ---------------------------------------------------------------- Kollisionspruefung (part="check")
chk = 0; chk_theta = 0;
module finger4(t) for(k=[0:3]) rotate([0,0,90*k]) kralle(t);
module horn_link(theta) {
    zsp = pivot_z + arm_len*sin(theta - swing/2);
    zl  = zsp - sp_h/2 - lug_hole;
    phi = asin(clamp((z_s - (zl - link_L))/horn_R));
    py  = y_s + horn_R*cos(phi);  pz = z_s - horn_R*sin(phi);
    hull(){
        translate([lug_x1-1.6, y_s, z_s]) rotate([0,90,0]) cylinder(d=7,h=1.6);
        translate([lug_x1-1.6, y_s+12*cos(phi), z_s-12*sin(phi)]) rotate([0,90,0]) cylinder(d=4,h=1.6);
    }
    hull(){
        translate([lug_x1, py, pz]) rotate([0,90,0]) cylinder(d=7,h=2.5);
        translate([lug_x1, 0, zl]) rotate([0,90,0]) cylinder(d=7,h=2.5);
    }
}
module spule_at(t) translate([0,0,pivot_z + arm_len*sin(t - swing/2)]) spule();
module check() {
    t = chk_theta;
    if(chk==0) intersection(){ gehaeuse(); finger4(t); }
    if(chk==1) intersection(){ gehaeuse(); spule_at(t); }
    if(chk==2) intersection(){ gehaeuse(); servo_dummy(); }
    if(chk==3) intersection(){ gehaeuse(); horn_link(t); }
    if(chk==4) intersection(){ finger4(t); spule_at(t); }
    if(chk==5) intersection(){ finger4(t); union(){ anschlag(); translate([0,0,zc]) sphere(r=ball_r-0.3,$fn=64); } }
    if(chk==6) intersection(){ gehaeuse(); union(){ sattel(); deck(); } }
    if(chk==7) intersection(){ union(){ servo_dummy(); elektronik_dummy(); } union(){ horn_link(t); spule_at(t); } }
    if(chk==8) intersection(){ gehaeuse(); elektronik_dummy(); }
    if(chk==9) intersection(){ sattel(); rahmen_dummy(); }
}
if(part=="check") check();

// ---------------------------------------------------------------- Ausgabe
if(part=="assembly") rotate([180,0,0]) {
    assembly(open_deg);
}
if(part=="sattel")   translate([0,0,z_sf]) rotate([180,0,0]) sattel();   // Flachseite aufs Druckbett
if(part=="gehaeuse") rotate([180,0,0]) gehaeuse();                        // Basis aufs Druckbett
if(part=="kralle")   kralle_print();                                      // 4x drucken
if(part=="spule")    translate([0,0,sp_h/2]) rotate([180,0,0]) spule();
if(part=="anschlag") anschlag();
if(part=="deck")     translate([0,0,-z_deck0+deck_t]) deck();
if(part=="koppel")   koppel();
if(part=="taster")   taster();

// ---------------------------------------------------------------- Teile in Einbaulage fuer die 3D-Ansicht (viewer/build.py)
if(part=="v_sattel")   sattel();
if(part=="v_gehaeuse") gehaeuse();
if(part=="v_kralle")   kralle(0);
if(part=="v_spule")    spule();
if(part=="v_koppel")   translate([2.5,0,0]) rotate([0,-90,0]) koppel();
if(part=="v_anschlag") anschlag();
if(part=="v_deck")     deck();
if(part=="v_taster")   taster();
if(part=="v_servo")    servo_dummy();
if(part=="v_horn")     hull(){ rotate([0,90,0]) cylinder(d=7,h=1.6); translate([0,12,0]) rotate([0,90,0]) cylinder(d=4,h=1.6); }
