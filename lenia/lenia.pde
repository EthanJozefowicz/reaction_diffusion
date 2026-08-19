import controlP5.*;
ControlP5 cp5;

float[][] A;
float[][] Anext;

float[][] kernel;

int scale = 5;
int rows, cols;

int radius = 13;

// Lenia parameters
float mu = 0.15;
float sigma = 0.015;
float dt = 0.1;

int iterationsPerFrame = 1;


float orbiumMu = 0.15;
float orbiumSigma = 0.014;
float orbiumDt = 0.1;
int orbiumRadius = 13;

float[][] orbium = {
  {0f,0f,0f,0f,0f,0f,0.10f,0.14f,0.10f,0f,0f,0.03f,0.03f,0f,0f,0.30f,0f,0f,0f,0f},
  {0f,0f,0f,0f,0f,0.08f,0.24f,0.30f,0.30f,0.18f,0.14f,0.15f,0.16f,0.15f,0.09f,0.20f,0f,0f,0f,0f},
  {0f,0f,0f,0f,0f,0.15f,0.34f,0.44f,0.46f,0.38f,0.18f,0.14f,0.11f,0.13f,0.19f,0.18f,0.45f,0f,0f,0f},
  {0f,0f,0f,0f,0.06f,0.13f,0.39f,0.50f,0.50f,0.37f,0.06f,0f,0f,0f,0.02f,0.16f,0.68f,0f,0f,0f},
  {0f,0f,0f,0.11f,0.17f,0.17f,0.33f,0.40f,0.38f,0.28f,0.14f,0f,0f,0f,0f,0f,0.18f,0.42f,0f,0f},
  {0f,0f,0.09f,0.18f,0.13f,0.06f,0.08f,0.26f,0.32f,0.32f,0.27f,0f,0f,0f,0f,0f,0f,0.82f,0f,0f},
  {0.27f,0f,0.16f,0.12f,0f,0f,0f,0.25f,0.38f,0.44f,0.45f,0.34f,0f,0f,0f,0f,0f,0.22f,0.17f,0f},
  {0f,0.07f,0.20f,0.02f,0f,0f,0f,0.31f,0.48f,0.57f,0.60f,0.57f,0f,0f,0f,0f,0f,0f,0.49f,0f},
  {0f,0.59f,0.19f,0f,0f,0f,0f,0.20f,0.57f,0.69f,0.76f,0.76f,0.49f,0f,0f,0f,0f,0f,0.36f,0f},
  {0f,0.58f,0.19f,0f,0f,0f,0f,0f,0.67f,0.83f,0.90f,0.92f,0.87f,0.12f,0f,0f,0f,0f,0.22f,0.07f},
  {0f,0f,0.46f,0f,0f,0f,0f,0f,0.70f,0.93f,1f,1f,1f,0.61f,0f,0f,0f,0f,0.18f,0.11f},
  {0f,0f,0.82f,0f,0f,0f,0f,0f,0.47f,1f,1f,0.98f,1f,0.96f,0.27f,0f,0f,0f,0.19f,0.10f},
  {0f,0f,0.46f,0f,0f,0f,0f,0f,0.25f,1f,1f,0.84f,0.92f,0.97f,0.54f,0.14f,0.04f,0.10f,0.21f,0.05f},
  {0f,0f,0f,0.40f,0f,0f,0f,0f,0.09f,0.80f,1f,0.82f,0.80f,0.85f,0.63f,0.31f,0.18f,0.19f,0.20f,0.01f},
  {0f,0f,0f,0.36f,0.10f,0f,0f,0f,0.05f,0.54f,0.86f,0.79f,0.74f,0.72f,0.60f,0.39f,0.28f,0.24f,0.13f,0f},
  {0f,0f,0f,0.01f,0.30f,0.07f,0f,0f,0.08f,0.36f,0.64f,0.70f,0.64f,0.60f,0.51f,0.39f,0.29f,0.19f,0.04f,0f},
  {0f,0f,0f,0f,0.10f,0.24f,0.14f,0.10f,0.15f,0.29f,0.45f,0.53f,0.52f,0.46f,0.40f,0.31f,0.21f,0.08f,0f,0f},
  {0f,0f,0f,0f,0f,0.08f,0.21f,0.21f,0.22f,0.29f,0.36f,0.39f,0.37f,0.33f,0.26f,0.18f,0.09f,0f,0f,0f},
  {0f,0f,0f,0f,0f,0f,0.03f,0.13f,0.19f,0.22f,0.24f,0.24f,0.23f,0.18f,0.13f,0.05f,0f,0f,0f,0f},
  {0f,0f,0f,0f,0f,0f,0f,0f,0.02f,0.06f,0.08f,0.09f,0.07f,0.05f,0.01f,0f,0f,0f,0f,0f}
};


float rotorbiumMu = 0.156f;
float rotorbiumSigma = 0.0224f;
float rotorbiumDt = 0.1f;
int rotorbiumRadius = 13;
float[][] rotorbium = {
  {0f,0f,0f,0f,0f,0f,0f,0f,0.003978f,0.016492f,0.004714f,0f,0f,0f,0f,0f,0f,0f,0f,0f},

  {0f,0f,0f,0f,0f,0.045386f,0.351517f,0.417829f,0.367137f,0.377660f,
   0.426948f,0.431058f,0.282864f,0.081247f,0f,0f,0f,0f,0f,0f},

  {0f,0f,0f,0f,0.325473f,0.450995f,0.121737f,0f,0f,0.003113f,
   0.224278f,0.471010f,0.456459f,0.247231f,0.071609f,0.013126f,0f,0f,0f,0f},

  {0f,0f,0f,0.386337f,0.454077f,0f,0f,0f,0f,0f,
   0f,0f,0.278480f,0.524466f,0.464281f,0.242651f,0.096721f,0.038476f,0f,0f},

  {0f,0f,0.258817f,0.583802f,0.150994f,0f,0f,0f,0f,0f,
   0f,0f,0.226639f,0.548329f,0.550422f,0.334764f,0.153108f,0.087049f,0.042872f,0f},

  {0f,0.008021f,0.502406f,0.524042f,0.059531f,0f,0f,0f,0f,0f,
   0f,0.033946f,0.378866f,0.615467f,0.577527f,0.357306f,0.152872f,0.090425f,0.058275f,0.023345f},

  {0f,0.179756f,0.596317f,0.533619f,0.162612f,0f,0f,0f,0.015021f,0.107673f,
   0.325125f,0.594765f,0.682434f,0.594688f,0.381172f,0.152078f,0.073544f,0.054424f,0.030592f,0f},

  {0f,0.266078f,0.614339f,0.605474f,0.379255f,0.195176f,0.165160f,0.179148f,0.204498f,0.299535f,
   0.760743f,1f,1f,1f,1f,0.490799f,0.237826f,0.069989f,0.043549f,0.022165f},

  {0f,0.333031f,0.640570f,0.686886f,0.606980f,0.509866f,0.450525f,0.389552f,0.434978f,0.859115f,
   0.940970f,1f,1f,1f,1f,1f,0.747866f,0.118317f,0.037712f,0.006271f},

  {0f,0.417887f,0.685600f,0.805342f,0.824229f,0.771553f,0.692510f,0.614328f,0.651704f,0.843665f,
   0.910114f,1f,1f,0.817650f,0.703404f,0.858469f,1f,0.613961f,0.035691f,0f},

  {0.046740f,0.526827f,0.787644f,0.895984f,0.734214f,0.661746f,0.670024f,0.646184f,0.699040f,0.723163f,
   0.682438f,0.618645f,0.589858f,0.374017f,0.306580f,0.404027f,0.746403f,0.852551f,0.031459f,0f},

  {0.130727f,0.658494f,0.899652f,0.508352f,0.065875f,0.009245f,0.232702f,0.419661f,0.461988f,0.470213f,
   0.390198f,0.007773f,0f,0.010182f,0.080666f,0.172310f,0.445880f,0.819878f,0.034815f,0f},

  {0.198532f,0.810417f,0.637250f,0.031385f,0f,0f,0f,0f,0.315842f,0.319248f,
   0.321024f,0f,0f,0f,0f,0.021482f,0.273150f,0.747039f,0f,0f},

  {0.217619f,0.968727f,0.104843f,0f,0f,0f,0f,0f,0.152033f,0.158413f,
   0.114036f,0f,0f,0f,0f,0f,0.224751f,0.647423f,0f,0f},

  {0.138866f,1f,0.093672f,0f,0f,0f,0f,0f,0.000052f,0.015966f,
   0f,0f,0f,0f,0f,0f,0.281471f,0.455713f,0f,0f},

  {0f,1f,0.145606f,0.005319f,0f,0f,0f,0f,0f,0f,
   0f,0f,0f,0f,0f,0.016878f,0.381439f,0.173336f,0f,0f},

  {0f,0.974210f,0.262735f,0.096478f,0f,0f,0f,0f,0f,0f,
   0f,0f,0f,0f,0.013827f,0.217967f,0.287352f,0f,0f,0f},

  {0f,0.593133f,0.298100f,0.251901f,0.167326f,0.088798f,0.041468f,0.013086f,0.002207f,0.009404f,
   0.032743f,0.061718f,0.102995f,0.159500f,0.247210f,0.233961f,0.002389f,0f,0f,0f},

  {0f,0f,0.610166f,0.155450f,0.200204f,0.228209f,0.241863f,0.243451f,0.270572f,0.446258f,
   0.376504f,0.174319f,0.154149f,0.120610f,0.074709f,0f,0f,0f,0f,0f},

  {0f,0f,0.354313f,0.322450f,0f,0f,0f,0.151173f,0.479517f,0.650744f,
   0.392183f,0f,0f,0f,0f,0f,0f,0f,0f,0f},

  {0f,0f,0f,0.329339f,0.328926f,0.176186f,0.198788f,0.335721f,0.534118f,0.549606f,
   0.361315f,0f,0f,0f,0f,0f,0f,0f,0f,0f},

  {0f,0f,0f,0f,0.090407f,0.217992f,0.190592f,0.174636f,0.222482f,0.375871f,
   0.265924f,0f,0f,0f,0f,0f,0f,0f,0f,0f},

  {0f,0f,0f,0f,0f,0f,0f,0f,0f,0.050256f,
   0.235176f,0f,0f,0f,0f,0f,0f,0f,0f,0f},

  {0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,
   0f,0.180145f,0.132616f,0f,0f,0f,0f,0f,0f,0f},

  {0f,0f,0f,0f,0f,0f,0f,0f,0f,0f,
   0f,0f,0f,0.092581f,0.188519f,0.118256f,0f,0f,0f,0f}
};

DropdownList speciesMenu;
boolean patternChosen = false;

void setup() {

  size(800, 800);
  noStroke();

  rows = height / scale;
  cols = width / scale;

  A = new float[rows][cols];
  Anext = new float[rows][cols];

  cp5 = new ControlP5(this);

  cp5.addSlider("mu")
     .setPosition(20, 20)
     .setSize(180, 15)
     .setRange(0.05, 0.50)
     .setValue(0.15)
     .setLabel("mu")
     .setDecimalPrecision(3)
     .setColorLabel(color(255))
     .setColorBackground(color(40,40,60))
     .setColorForeground(color(70,110,170))
     .setColorActive(color(100,160,230));

  cp5.addSlider("sigma")
     .setPosition(20, 50)
     .setSize(180, 15)
     .setRange(0.005, 0.10)
     .setValue(0.025)
     .setLabel("sigma")
     .setDecimalPrecision(3)
     .setColorLabel(color(255))
     .setColorBackground(color(40,40,60))
     .setColorForeground(color(70,110,170))
     .setColorActive(color(100,160,230));

  cp5.addSlider("radius")
     .setPosition(20,80)
     .setSize(150,15)
     .setRange(5,25)
     .setValue(13)
     .setNumberOfTickMarks(21)
     .setLabel("radius")
     .setColorLabel(color(255))
     .setColorBackground(color(40,40,60))
     .setColorForeground(color(70,110,170))
     .setColorActive(color(100,160,230));

  cp5.addSlider("dt")
     .setPosition(20, 110)
     .setSize(150, 15)
     .setRange(0.1, 1)
     .setValue(0.3)
     .setLabel("dt")
     .setNumberOfTickMarks(23)
     .setDecimalPrecision(2)
     .setColorLabel(color(255))
     .setColorBackground(color(40,40,60))
     .setColorForeground(color(70,110,170))
     .setColorActive(color(100,160,230));

  speciesMenu = cp5.addDropdownList("speciesMenu")
    .setPosition(20, 140)
    .setSize(180, 100)
    .setBarHeight(20)
    .setItemHeight(20);

  speciesMenu.addItem("Random", 0);
  speciesMenu.addItem("Orbium", 1);
  speciesMenu.addItem("Rotorbium", 2);
}


void draw() {

  render();
  if (!patternChosen) {
    return;
  }
  for (int i = 0; i < iterationsPerFrame; i++) {
    updateLenia();
  }
}

void controlEvent(ControlEvent event) {
  if (event.isFrom(speciesMenu)) {

    int choice = int(event.getValue());

    switch (choice) {
      case 0:
        initRandom();
        break;
      case 1:
        loadOrbium();
        break;
      case 2:
        loadRotorbium();
        break;
      default:
        return;
    }

    buildKernel();
    patternChosen = true;
  }
}


void initRandom() {
  for (int r = 0; r < rows; r++)
    for (int c = 0; c < cols; c++)
      A[r][c] = 0;

  int cr = rows/2, cc = cols/2;
  int rad = radius; // roughly match the kernel size instead of a fixed blob

  for (int r = -rad; r <= rad; r++) {
    for (int c = -rad; c <= rad; c++) {
      float d = sqrt(r*r + c*c) / rad;
      if (d <= 1 && random(1) < 0.5) {
        A[(cr+r+rows)%rows][(cc+c+cols)%cols] = random(1);
      }
    }
  }
}

void loadPattern(
  float[][] pattern,
  float newMu,
  float newSigma,
  float newDt,
  int newRadius
) {
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      A[r][c] = 0;
      Anext[r][c] = 0;
    }
  }

  int startR = rows/2 - pattern.length/2;
  int startC = cols/2 - pattern[0].length/2;

  for (int r = 0; r < pattern.length; r++) {
    for (int c = 0; c < pattern[r].length; c++) {
      A[startR + r][startC + c] = pattern[r][c];
    }
  }

  mu = newMu;
  sigma = newSigma;
  dt = newDt;
  radius = newRadius;

  cp5.getController("mu").setValue(mu);
  cp5.getController("sigma").setValue(sigma);
  cp5.getController("dt").setValue(dt);
  cp5.getController("radius").setValue(radius);
}


void loadOrbium() {
  loadPattern(
    orbium,
    orbiumMu,
    orbiumSigma,
    orbiumDt,
    orbiumRadius
  );
}

void loadRotorbium() {
  loadPattern(
    rotorbium,
    rotorbiumMu,
    rotorbiumSigma,
    rotorbiumDt,
    rotorbiumRadius
  );
}

void radius(float value) {
  radius = round(value);
  buildKernel();
}

// builds and normalizes the convolution kernel
void buildKernel() {

  int size = 2 * radius + 1;
  kernel = new float[size][size];
  float total = 0;

  for (int kr = -radius; kr <= radius; kr++) {
    for (int kc = -radius; kc <= radius; kc++) {

      float distance = sqrt(kr * kr + kc * kc) / radius;

      float value = 0;

      // ring-shaped kernel
      if (distance <= 1) {
        value = exp(
          -sq(distance - 0.5) / (2 * sq(0.15))
        );
      }
      kernel[kr + radius][kc + radius] = value;
      total += value;
    }
  }

  for (int r = 0; r < size; r++) {
    for (int c = 0; c < size; c++) {
      kernel[r][c] /= total;
    }
  }
}


void updateLenia() {
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {

      float u = convolution(r, c);

      Anext[r][c] = constrain(A[r][c] + dt * growth(u), 0, 1);
    }
  }

  float[][] temp = A;
  A = Anext;
  Anext = temp;
}


float convolution(int r, int c) {

  float total = 0;

  for (int kr = -radius; kr <= radius; kr++) {
    for (int kc = -radius; kc <= radius; kc++) {

      // periodic boundary
      int rr = (r + kr + rows) % rows;
      int cc = (c + kc + cols) % cols;

      total += A[rr][cc] * kernel[kr + radius][kc + radius];
    }
  }
  return total;
}


float growth(float u) {
  return 2 * exp(-sq(u - mu) / (2 * sq(sigma))) - 1;
}


void render() {
  background(0);
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {

      fill(A[r][c] * 255);

      rect(c * scale, r * scale, scale, scale);
    }
  }
}


void keyPressed() {

  if (key == 'r' || key == 'R') {
    buildKernel();
    initRandom();
  }
}

void mouseDragged() { seedAt(mouseX/scale, mouseY/scale); }
void mousePressed()  { seedAt(mouseX/scale, mouseY/scale); }

void seedAt(int c0, int r0) {
  if (cp5.isMouseOver()) return;
  int rad = 4;
  for (int r=-rad; r<=rad; r++)
    for (int c=-rad; c<=rad; c++) {
      float d = sqrt(r*r+c*c)/rad;
      if (d<=1) {
        int rr=(r0+r+rows)%rows, cc=(c0+c+cols)%cols;
        A[rr][cc] = min(1, A[rr][cc] + (1-d*d));
      }
    }
}
