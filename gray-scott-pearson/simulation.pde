import javax.swing.JOptionPane;

int RECTANGLE = 0;
int TORUS     = 1;
int CYLINDER  = 2;
int MOBIUS    = 3;
int KLEIN     = 4;
int geometry  = TORUS;

void startSimulation() {
  resetSimulation();
  simulation = true;
  println("F=" + nf(F, 1, 4) + " k=" + nf(k, 1, 4));
}

void resetSimulation() {
  for (int r = 0; r < rows; r++)
    for (int c = 0; c < cols; c++) {
      A[r][c] = 1;
      B[r][c] = 0;
      if (random(1) < seedDensity) {
        A[r][c] = 0;
        B[r][c] = 1;
      }
    }
}

void updateSimulation() {
  float wCenter = 4 * wCardinal + 4 * wDiagonal;

  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {

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

      float a = A[r][c], b = B[r][c], reaction = a * b * b;
      Anext[r][c] = constrain(a + dt * (Da * lapA - reaction + F * (1 - a)), 0, 1);
      Bnext[r][c] = constrain(b + dt * (Db * lapB + reaction - (F + k) * b), 0, 1);
    }
  }

  float[][] tmp;
  tmp = A; A = Anext; Anext = tmp;
  tmp = B; B = Bnext; Bnext = tmp;
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
    if (c < 0 || c >= cols) { r = rows - 1 - r; }
    if (r < 0 || r >= rows) { c = cols - 1 - c; }
    c = (c + cols) % cols;
    r = (r + rows) % rows;
  }

  return new int[]{r, c};
}

float valueAt(float[][] Z, int r, int c) {
  int[] p = wrap(r, c);
  return Z[p[0]][p[1]];
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
    options[geometry]
  );

  if (choice == null) return;
  if (choice.equals("Rectangle")) {
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
