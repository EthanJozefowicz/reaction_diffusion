import controlP5.*;
import processing.event.MouseEvent;

ControlP5 cp5;

PImage mapImage;
boolean simulation = false;

float F, k;
float[][] A, B, Anext, Bnext;

float Da = 1;
float Db = 0.5;
float dt = 1;

float wCardinal = 0.2;
float wDiagonal = 0.05;

int scale = 5;
int rows, cols;

int iterationsPerFrame = 10;
float seedDensity = 0.05;

int MAP_W = 600;
int SIM_W = 600;
int WIN_H = 600;

// Zoom state
float zoom = 1.0;
float zoomX = 0;
float zoomY = 0;
float zoomMax = 8.0;


void settings() {
  size(MAP_W + SIM_W, WIN_H);
}


void setup() {

  mapImage = loadImage("xmorphia.jpg");

  noStroke();
  textSize(16);

  rows = WIN_H / scale;
  cols = SIM_W / scale;

  A     = new float[rows][cols];
  B     = new float[rows][cols];
  Anext = new float[rows][cols];
  Bnext = new float[rows][cols];

  cp5 = new ControlP5(this);

  cp5.addSlider("dt")
    .setPosition(MAP_W + 20, 20)
    .setSize(150, 15)
    .setRange(0.1, 1.2)
    .setValue(1.0)
    .setLabel("dt")
    .setNumberOfTickMarks(23)
    .setDecimalPrecision(2)
    .setColorLabel(color(255))
    .setColorBackground(color(40, 40, 60))
    .setColorForeground(color(70, 110, 170))
    .setColorActive(color(100, 160, 230));
}


void draw() {

  drawMap();

  if (simulation) {

    drawSimulation();

    for (int i = 0; i < iterationsPerFrame; i++) {
      updateSimulation();
    }

  } else {

    fill(20);
    rect(MAP_W, 0, SIM_W, WIN_H);

    fill(150);
    textAlign(CENTER, CENTER);
    text(
      "Click on the map to start",
      MAP_W + SIM_W / 2,
      WIN_H / 2
    );

    textAlign(LEFT);
  }
}


void drawMap() {

  // clip so the zoomed image doesn't spill onto the simulation panel
  clip(0, 0, MAP_W, WIN_H);

  pushMatrix();

  translate(zoomX, zoomY);
  scale(zoom);

  if (mapImage != null) {
    image(mapImage, 0, 0, MAP_W, WIN_H);
  }

  popMatrix();

  noClip();

  if (mouseX >= 0 && mouseX < MAP_W &&
      mouseY >= 0 && mouseY < WIN_H) {

    float[] fk = getFK();

    fill(255, 240);
    rect(10, 10, 180, 78);

    fill(0);
    text("F = " + nf(fk[0], 1, 5), 20, 30);
    text("k = " + nf(fk[1], 1, 5), 20, 52);
    text("Zoom : x" + nf(zoom, 1, 2), 20, 74);
  }

  if (simulation) {

    fill(0, 200);
    rect(10, WIN_H - 60, 180, 50);

    fill(255);
    text("F = " + nf(F, 1, 5), 20, WIN_H - 40);
    text("k = " + nf(k, 1, 5), 20, WIN_H - 18);
  }
}


void drawSimulation() {

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {

      fill(
        A[r][c] * 255,
        B[r][c] * 255,
        0
      );

      rect(
        MAP_W + c * scale,
        r * scale,
        scale,
        scale
      );
    }
  }
}


void mousePressed() {

  if (cp5.isMouseOver()) {
    return;
  }

  // left click on the map picks (F, k) and (re)starts the simulation
  if (mouseX >= 0 && mouseX < MAP_W &&
      mouseY >= 0 && mouseY < WIN_H &&
      mouseButton == LEFT) {

    float[] fk = getFK();

    F = fk[0];
    k = fk[1];

    if (!simulation) {
      resetSimulation();
      simulation = true;
    }

    println(
      "F = " + nf(F, 1, 5) +
      " | k = " + nf(k, 1, 5)
    );
  }
}


void mouseDragged() {

  if (cp5.isMouseOver()) {
    return;
  }

  if (simulation && mouseX > MAP_W) {

    int c = (mouseX - MAP_W) / scale;
    int r = mouseY / scale;

    if (r >= 0 && r < rows &&
        c >= 0 && c < cols) {

      A[r][c] = 0;
      B[r][c] = 1;
    }
  }
}


void mouseWheel(MouseEvent event) {

  if (mouseX < 0 || mouseX >= MAP_W ||
      mouseY < 0 || mouseY >= WIN_H) {
    return;
  }

  float delta = event.getCount();

  float oldZoom = zoom;

  // wheel up = zoom in, wheel down = zoom out
  float newZoom = zoom * pow(1.15, -delta);

  newZoom = constrain(newZoom, 1.0, zoomMax);

  float factor = newZoom / oldZoom;

  // keep the point under the cursor fixed while zooming
  zoomX = mouseX - (mouseX - zoomX) * factor;
  zoomY = mouseY - (mouseY - zoomY) * factor;

  zoom = newZoom;

  clampZoom();
}


void keyPressed() {

  if (key == 'c' || key == 'C') {
    simulation = false;
  }

  if ((key == 'r' || key == 'R') && simulation) {
    resetSimulation();
  }

  if ((key == 'g' || key == 'G') && simulation) {
    chooseGeometry();
  }

  if (key == 'z' || key == 'Z') {
    resetZoom();
  }
}


// keep the zoomed image inside the map panel
void clampZoom() {

  float zoomedW = MAP_W * zoom;
  float zoomedH = WIN_H * zoom;

  zoomX = constrain(zoomX, MAP_W - zoomedW, 0);
  zoomY = constrain(zoomY, WIN_H - zoomedH, 0);
}


void resetZoom() {
  zoom = 1.0;
  zoomX = 0;
  zoomY = 0;
}


// maps the mouse position on the phase diagram image to (F, k)
float[] getFK() {

  float xMap = (mouseX - zoomX) / zoom;
  float yMap = (mouseY - zoomY) / zoom;

  float xImg = map(xMap, 0, MAP_W, 0, mapImage.width);
  float yImg = map(yMap, 0, WIN_H, 0, mapImage.height);

  // calibration points on the reference phase-diagram image
  float xRef = 733;
  float yRef = 632;

  float Fref = 0.038;
  float Kref = 0.061;

  float cellSize = 34;

  float dCol = (xImg - xRef) / cellSize;
  float dRow = (yRef - yImg) / cellSize;

  float K  = Kref + dCol * 0.002;
  float FF = Fref + dRow * 0.004;

  return new float[]{FF, K};
}
