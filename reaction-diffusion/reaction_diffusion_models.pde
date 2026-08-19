import javax.swing.JOptionPane;

float[][] A;
float[][] B;
float[][] Anext;
float[][] Bnext;

float Da = 1;     // ref: 1
float Db = 0.5;   // ref: 0.5
float f  = 0.035; // ref: 0.035
float k  = 0.06;  // ref: 0.058
float wCardinal = 0.2;  // ref: 0.2
float wDiagonal = 0.05; // ref: 0.05
float dt = 1;     // ref: 1

int scale = 5;
int rows, cols;

int stepsPerFrame = 10;
int initMode;
int model;
float seedDensity;

int RECTANGLE = 0;
int TORUS     = 1;
int CYLINDER  = 2;
int MOBIUS    = 3;
int KLEIN     = 4;
int geometry  = TORUS;


void setup() {
  size(1280, 1280);
  pixelDensity(1);
  rows = height / scale;
  cols = width / scale;
  A     = new float[rows][cols];
  B     = new float[rows][cols];
  Anext = new float[rows][cols];
  Bnext = new float[rows][cols];

  String m = JOptionPane.showInputDialog("Model:\n0 = Gray-Scott\n1 = Lotka-Volterra\n2 = FitzHugh-Nagumo");
  model = int(m);

  if (model == 0) { Da = 1.0; Db = 0.5; dt = 1.0; }
  else if (model == 1) { Da = 0.5; Db = 0.1; dt = 0.1; }
  else { Da = 1.0; Db = 0.0; dt = 0.05; }

  String choice = JOptionPane.showInputDialog("Initial condition:\n0 = seed in the center\n1 = random noise");
  initMode = int(choice);
  initGrid();
  chooseGeometry();
  noStroke();
}

void initGrid() {
  for (int r = 0; r < rows; r++)
    for (int c = 0; c < cols; c++) {
      if (model == 2) { A[r][c] = 0; B[r][c] = 0; }  // FitzHugh-Nagumo: resting state
      else             { A[r][c] = 1; B[r][c] = 0; }  // Gray-Scott / Lotka-Volterra
    }

  if (initMode == 0) {
    for (int r = rows/2-3; r < rows/2+3; r++)
      for (int c = cols/2-3; c < cols/2+3; c++) {
        if      (model == 0) { A[r][c] = 0; B[r][c] = 1; }  // Gray-Scott
        else if (model == 1) {              B[r][c] = 1; }  // Lotka-Volterra keeps A = 1
        else                  { A[r][c] = 1; B[r][c] = 0; }  // FitzHugh-Nagumo excitation
      }
  } else {
    String d = JOptionPane.showInputDialog("Density (e.g. 0.05):");
    seedDensity = float(d);
    for (int r = 0; r < rows; r++)
      for (int c = 0; c < cols; c++)
        if (random(1) < seedDensity) {
          if      (model == 0) { A[r][c] = 0; B[r][c] = 1; }
          else if (model == 1) { B[r][c] = 1; }
          else                  { A[r][c] = 1; B[r][c] = 0; }
        }
  }
}

void draw() {
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      fill(A[r][c] * 255, B[r][c] * 255, 0);
      rect(c * scale, r * scale, scale, scale);
    }
  }
  for (int i = 0; i < stepsPerFrame; i++) update();
}

void update() {
  float wCenter = 4 * wCardinal + 4 * wDiagonal;

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {

      // 9-point stencil Laplacian, periodic/geometry-aware boundaries
      float lapA =
        valueAt(A, r-1, c-1) * wDiagonal +
        valueAt(A, r+1, c-1) * wDiagonal +
        valueAt(A, r-1, c+1) * wDiagonal +
        valueAt(A, r+1, c+1) * wDiagonal +
        valueAt(A, r-1, c)   * wCardinal +
        valueAt(A, r+1, c)   * wCardinal +
        valueAt(A, r, c-1)   * wCardinal +
        valueAt(A, r, c+1)   * wCardinal -
        A[r][c] * wCenter;

      float lapB =
        valueAt(B, r-1, c-1) * wDiagonal +
        valueAt(B, r+1, c-1) * wDiagonal +
        valueAt(B, r-1, c+1) * wDiagonal +
        valueAt(B, r+1, c+1) * wDiagonal +
        valueAt(B, r-1, c)   * wCardinal +
        valueAt(B, r+1, c)   * wCardinal +
        valueAt(B, r, c-1)   * wCardinal +
        valueAt(B, r, c+1)   * wCardinal -
        B[r][c] * wCenter;

      float a = A[r][c];
      float b = B[r][c];

      float[] res;
      if      (model == 0) res = grayScott(a, b, lapA, lapB);
      else if (model == 1) res = lotkaVolterra(a, b, lapA, lapB);
      else res = fitzHughNagumo(a, b, lapA, lapB);

      Anext[r][c] = res[0];
      Bnext[r][c] = res[1];
    }
  }

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      A[r][c] = Anext[r][c];
      B[r][c] = Bnext[r][c];
    }
  }
}

void chooseGeometry() {
  String[] options = {
    "Rectangle",
    "Torus",
    "Cylinder",
    "Mobius strip",
    "Klein bottle"
  };

  String choice = (String) JOptionPane.showInputDialog(
    null,
    "Choose a boundary geometry:",
    "Geometry",
    JOptionPane.QUESTION_MESSAGE,
    null,
    options,
    options[1]
  );

  if (choice == null) {
    geometry = TORUS;
  } else if (choice.equals("Rectangle")) {
    geometry = RECTANGLE;
  } else if (choice.equals("Torus")) {
    geometry = TORUS;
  } else if (choice.equals("Cylinder")) {
    geometry = CYLINDER;
  } else if (choice.equals("Mobius strip")) {
    geometry = MOBIUS;
  } else if (choice.equals("Klein bottle")) {
    geometry = KLEIN;
  }

  println("Geometry: " + choice);
}

float[] grayScott(float a, float b, float lapA, float lapB) {
  float reaction = a * b * b;
  float newA = a + dt * (Da * lapA - reaction + f * (1 - a));
  float newB = b + dt * (Db * lapB + reaction - (f + k) * b);
  return new float[]{newA, newB};
}

float[] lotkaVolterra(float a, float b, float lapA, float lapB) {
  float Da = 1.0;
  float Db = 5.0;

  float alpha = 1.0;
  float beta  = 1.0;
  float gamma = 0.2;
  float delta = 0.4;

  float newA = a + dt * (Da * lapA + alpha * a * (1 - a) - beta * a * b);
  float newB = b + dt * (Db * lapB + delta * a * b - gamma * b);
  return new float[]{newA, newB};
}

float[] fitzHughNagumo(float a, float b, float lapA, float lapB) {
  float eps = 0.05;
  float p   = 0.1;
  float q   = 1;
  float newA = a + dt * (Da * lapA + a - a*a*a - b);
  float newB = b + dt * (Db * lapB + eps * (a + p - q*b));
  return new float[]{newA, newB};
}


void mouseDragged() {
  int c = mouseX / scale;
  int r = mouseY / scale;

  if (r >= 0 && r < rows && c >= 0 && c < cols) {
    if (model == 1) {        // Lotka-Volterra: add predators
      B[r][c] = 1.0;
    } else if (model == 2) { // FitzHugh-Nagumo: local excitation
      A[r][c] = 1.0;
    } else {                  // Gray-Scott
      A[r][c] = 0.0;
      B[r][c] = 1.0;
    }
  }
}

void mousePressed() {
  mouseDragged();
}


// applies the current boundary geometry to a grid index
int[] wrap(int r, int c) {
  if (geometry == TORUS) {
    r = (r + rows) % rows;
    c = (c + cols) % cols;
  }
  else if (geometry == RECTANGLE) {
    r = constrain(r, 0, rows - 1);
    c = constrain(c, 0, cols - 1);
  }
  else if (geometry == CYLINDER) {
    r = constrain(r, 0, rows - 1);
    c = (c + cols) % cols;
  }
  else if (geometry == MOBIUS) {
    if (c < 0 || c >= cols) {
      r = rows - 1 - r;
    }
    c = (c + cols) % cols;
    r = constrain(r, 0, rows - 1);
  }
  else if (geometry == KLEIN) {
    if (c < 0 || c >= cols) {
      r = rows - 1 - r;
    }
    c = (c + cols) % cols;
    r = (r + rows) % rows;
  }

  return new int[]{r, c};
}

float valueAt(float[][] Z, int r, int c) {
  int[] p = wrap(r, c);
  return Z[p[0]][p[1]];
}

void keyPressed() {
  if (key == 'g' || key == 'G') {
    chooseGeometry();
  }
}
