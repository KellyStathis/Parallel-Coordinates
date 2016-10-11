// Data
Table table;
String path = "weather-by-state.csv";
int[][] tableData;
int numRows, numCols;
String[] rowNames, colNames;
int[] colMins, colMaxes;

// Window dimensions
int leftOffset = 40;
int rightOffset = 40;
int topOffset = 50;
int bottomOffset = 60;
int distanceBetweenAxes;

// Highlighted lines
boolean[] highlightedRows;
boolean[] highlightedCols;
color[] gradientColors;
int highlightedColumn = -1;
boolean highlighted = false;
color[] currentColors;

// Axis orientations
boolean[] positiveAxisBottom; // true -> maximum at bottom, false -> maximum at top

// Drawing rectangle
int mouseXCoord, mouseYCoord, rectWidth, rectHeight;
boolean drawRectangle = false;

void setup() {
  // Open the data file
  table = loadTable(path);
  // Get number of rows and columns
  numRows = table.getRowCount() - 1;
  numCols = table.getColumnCount() - 1;
  // Store data info
  tableData = new int[numRows][numCols];
  rowNames = new String[numRows];
  colNames = new String[numCols];
  colMins = new int[numCols];
  colMaxes = new int[numCols];
  // Initialize arrays for highlighting lines and axis orientation
  highlightedRows = new boolean[numRows];
  highlightedCols = new boolean[numCols];
  gradientColors = new color[numRows];
  currentColors = new color[numRows];
  positiveAxisBottom = new boolean[numCols];
  
  // Get column headers and initialize colMins, colMaxes, and positiveAxis (orientation) arrays
  for (int j = 0; j < numCols; j++) {
    colNames[j] = table.getString(0, j+1);
    colMins[j] = Integer.MAX_VALUE; // until min is found
    colMaxes[j] = Integer.MIN_VALUE; // until max is found
    positiveAxisBottom[j] = false; // maximum at top
    highlightedCols[j] = false; // no highlighted cols to start
  }
  
  // Initialize highlighted rows array to 0s; initialize gradient colors
  int r = 0;
  int b = 255;
  int interval = 255/(numRows-1);
  println("interval: " + interval);
  for (int i = 0; i < numRows; i++) {
    highlightedRows[i] = false;
    gradientColors[i] = color(r, 0, b);
    r += interval;
    b -= interval;
  }
  
  // Get numerical (integer) data and populate colMins and colMaxes arrays
  for (int i = 0; i < numRows; i++) {
    // Get row names
    rowNames[i] = table.getString(i+1, 0);
    // Get table data
    for (int j = 0;  j < numCols; j++) {
      tableData[i][j] = table.getInt(i+1, j+1); 
      // Update column mins and maxes
      if (tableData[i][j] < colMins[j]) {
        colMins[j] = tableData[i][j];
      }
      if (tableData[i][j] > colMaxes[j]) {
        colMaxes[j] = tableData[i][j];
      }
    }
  }
 
  // Configure surface
  size(1200,600);
  surface.setResizable(true); // allows you to resize the canvas
}

void draw() {
  background(255, 255, 255); // white background
  drawAxes();
  drawLines();
  if (drawRectangle) {
     drawRectangle();
  }
}

void drawAxes() {
  distanceBetweenAxes = (width - leftOffset - rightOffset) / (numCols-1);
  int axisX = leftOffset;
  int axisLeftEdge = axisX - 5;
  int axisRightEdge = axisX + 5;
  strokeWeight(1);
  
  for (int j = 0; j < numCols; j++) {
    // Draw axis
    stroke(128,128,128);
    line(axisX, topOffset, axisX, height-bottomOffset);
    // Draw rectangle axes
    if (highlightedCols[j]) {
      fill(240,230,140,100); // fill yellow if highlihgted
    }
    else {  
      fill(211,211,211,100); // fill grey if not highlihgted
    }
    stroke(255,255,255);
    rectMode(CORNER);
    rect(axisLeftEdge, topOffset, axisRightEdge - axisLeftEdge, height-bottomOffset-topOffset);
    
    // Label axis with name
    textAlign(CENTER);
    textSize(10);
    fill(0,0,0);
    text(colNames[j], axisX, height-bottomOffset+30);
    
    // Label axis with max and min values
    if (positiveAxisBottom[j]) { // if positive is on bottom
      text(colMins[j], axisX, topOffset-5);
      text(colMaxes[j], axisX, height-bottomOffset+15);
    }
    else { // if positive is on top
      text(colMaxes[j], axisX, topOffset-5);
      text(colMins[j], axisX, height-bottomOffset+15);
    }
    
    // Draw +/- button
    rectMode(CENTER);
    stroke(105,105,105);
    fill(240,240,240);
    rect(axisX, height-bottomOffset+40, 12, 12, 5);
    String buttonText;
    if (positiveAxisBottom[j]) {
      buttonText = "+";
    }
    else {
      buttonText = "-";
    }
    textAlign(CENTER);
    fill(0,0,0);
    text(buttonText, axisX, height-bottomOffset+43);
    
    // Move forward to next column
    axisX += distanceBetweenAxes;
    axisLeftEdge += distanceBetweenAxes;
    axisRightEdge += distanceBetweenAxes;
  }
}

void drawLines() {
  // Initialize highlighted rows array to 0s
  for (int i = 0; i < numRows; i++) {
    highlightedRows[i] = false;
  }

  // Draw lines
  for (int i = 0; i < numRows; i++) {
    float Px = leftOffset;
    float Qx = leftOffset + distanceBetweenAxes;
    float Py, Qy = 0;
    for (int j = 0; j < numCols-1; j++) {
      // Calculate Py
      if (j == 0) { // first column, need to initialize Py
        float Pfrac = ((float)tableData[i][j] - colMins[j]) / (colMaxes[j]- colMins[j]);
        if (positiveAxisBottom[j]) {
          Py = Pfrac * (height - bottomOffset - topOffset) + topOffset;
        }
        else {
          Py = height - bottomOffset - (Pfrac * (height - bottomOffset - topOffset));
        }
      }
      else { // use previous Qy as Py
        Py = Qy;
      }
      // Calculate Qy
      float Qfrac = ((float)tableData[i][j+1] - colMins[j+1]) / (colMaxes[j+1] - colMins[j+1]);
      if (positiveAxisBottom[j+1]) {
        Qy = Qfrac * (height - bottomOffset - topOffset) + topOffset;
      }
      else {
        Qy = height - bottomOffset -(Qfrac * (height - bottomOffset - topOffset));
      }
      if (highlightedRows[i]) {
        strokeWeight(2);
      }
      else {
        strokeWeight(1);
      }
      
      // Use highlighted color if applicable
      if (highlighted) {
        stroke(currentColors[i]);
      }
      else {
        stroke(0,0,0);
      }
      
      // Draw line
      line(Px, Py, Qx, Qy);
      
      // Detemine highlighted rows - initial boolean for highlighting
      boolean highlight = false;
      
      // Highlighting from hovering:
      float m = (float)(Py-Qy)/(Px-Qx);
      float b = Py-m*Px;
      if ((Math.abs(mouseY - ((m*mouseX)+b)) < 3) && ((Qy <= Py && mouseY <= Py && mouseY >= Qy) || (Py <= Qy && mouseY <= Qy && mouseY >= Py)) && 
        ((Qx <= Px && mouseX <= Px && mouseX >= Qx) || (Px <= Qx && mouseX <= Qx && mouseX >= Px))) {
        highlight = true;
      }
      
      // Highlighting from box intersection:
      // Equation of line: y = mx+b
      // Equations from box; y = mouseXCoord, y = mouseXCoord + rectWidth, x = mouseYCoord, x = mouseYCoord + rectHeight
      if (drawRectangle) {
        boolean intersect = false;
        if (!intersect) {
          // Line: y = mouseYCoord
          float yTest1 = mouseYCoord;
          float xResult1 = (yTest1 - b)/m;
          intersect = checkPointRange(mouseXCoord, mouseXCoord + rectWidth, xResult1) && checkSegmentRange(Px, Py, Qx, Qy, xResult1, yTest1);
        }
        if (!intersect) {
          // Line: y = mouseYCoord + rectHeight
          float yTest2 = mouseYCoord + rectHeight;
          float xResult2 = (yTest2 - b)/m;
          intersect = checkPointRange(mouseXCoord, mouseXCoord + rectWidth, xResult2) && checkSegmentRange(Px, Py, Qx, Qy, xResult2, yTest2);
        }
        if (!intersect) {
          // Line: x = mouseXCoord
          float xTest1 = mouseXCoord;
          float yResult1 = xTest1*m + b;
          intersect = checkPointRange(mouseYCoord, mouseYCoord + rectHeight, yResult1) && checkSegmentRange(Px, Py, Qx, Qy, xTest1, yResult1);
        }
        if (!intersect) {
          // Line: x = mouseXCoord + rectWidth
          float xTest2 = mouseXCoord + rectWidth;
          float yResult2 = xTest2*m + b;
          intersect = checkPointRange(mouseYCoord, mouseYCoord + rectHeight, yResult2) && checkSegmentRange(Px, Py, Qx, Qy, xTest2, yResult2);
        }
        if (intersect) {
          highlight = true;
        }
      }
      
      // If row should be highlighted
      if (highlight) {
        highlightedRows[i] = true; // will highlight everything going forward
        drawHighlightedLinesSubset(i, 0, j-1); // go back and highlight segments from previous columns
        strokeWeight(2);
        line(Px, Py, Qx, Qy);
      }

      // Move forward to next column
      Px = Qx;
      Qx += distanceBetweenAxes;
    }
  }
  
  // Add label for highlighted line
  if (!drawRectangle) { // don't label everything highlighted by rectangle
    int count = 0;
    String labelText = "";
    for (int i = 0; i < numRows; i++) {
      if (highlightedRows[i]) { // Add to label text
        if (count != 0) {
          labelText += "; ";
        }
        labelText += rowNames[i];
        count++;
      }
    }
    text(labelText, mouseX, mouseY);
  }
}

void drawHighlightedLinesSubset(int i, int first, int last) {
  float Py, Qy = 0;
  for (int j = first; j < last+1; j++) {
      float Px = leftOffset + j*distanceBetweenAxes;
      float Qx = Px + distanceBetweenAxes;
      if (j == 0) {
        float Pfrac = ((float)tableData[i][j] - colMins[j]) / (colMaxes[j]- colMins[j]);
        if (positiveAxisBottom[j]) {
          Py = Pfrac * (height - bottomOffset - topOffset) + topOffset;
        }
        else {
          Py = height - bottomOffset - (Pfrac * (height - bottomOffset - topOffset));
        }
      }
      else {
        Py = Qy;
      }
      float Qfrac = ((float)tableData[i][j+1] - colMins[j+1]) / (colMaxes[j+1] - colMins[j+1]);
      if (positiveAxisBottom[j+1]) {
        Qy = Qfrac * (height - bottomOffset - topOffset) + topOffset;
      }
      else {
        Qy = height - bottomOffset -(Qfrac * (height - bottomOffset - topOffset));
      }
      strokeWeight(2);
      line(Px, Py, Qx, Qy);
  }
}

void drawRectangle() {
  // User-created rectangle (click and drag)
  rectMode(CORNER);
  strokeWeight(1);
  fill(255,255,255, 0);
  stroke(0,0,0);
  rect(mouseXCoord, mouseYCoord, rectWidth, rectHeight);
}

void mouseClicked() {
  // Switch axis orientation
  if (Math.abs(mouseY - (height-bottomOffset+40)) <= 12/2) {
    for (int j = 0; j < numCols; j++) {
      int axisX = leftOffset + j*distanceBetweenAxes;
      if (Math.abs(mouseX - axisX) <= 12/2) {
        positiveAxisBottom[j] = !positiveAxisBottom[j];
      }
    }
  }
  
  // Detect selected column (axis)
  if (topOffset <= mouseY && mouseY <= height-bottomOffset) {
    int j = 0;
    int foundAt = -1;
    boolean found = false;
    while (j < numCols && !found) {
      int axisCenter = leftOffset+(j*distanceBetweenAxes);
      if (axisCenter-5 <= mouseX && mouseX <= axisCenter+5) {
        found = true;
        foundAt = j;
      }
      j++;
    }
    if (found) {
      for (j = 0; j < numCols; j++) {
        highlightedCols[j] = false;
      }
      if (foundAt != highlightedColumn) {
        highlightedCols[foundAt]= true;
        highlighted = true;
        highlightedColumn = foundAt;
        
        // Rearrange colors
        // Make temp arrays used to assign colors
        int[] tempIndex = new int[numRows];
        int[] tempData = new int[numRows];
        for (int i = 0; i < numRows; i++) {
          tempIndex[i] = i;
          tempData[i] = tableData[i][foundAt];
        }
        for (int i = 1; i < numRows; i++) {
          int k = i;
          while (k > 0 && tempData[k-1] > tempData[k]) {
            int tempIndexK = tempIndex[k];
            int tempDataK = tempData[k];
            tempIndex[k] = tempIndex[k-1];
            tempIndex[k-1] = tempIndexK;
            tempData[k] = tempData[k-1];
            tempData[k-1] = tempDataK;
            k -= 1;
          }
        }
        // Assign the colors
        for (int i = 0; i < numRows; i++) {
          currentColors[tempIndex[i]] = gradientColors[i];
        }
      }
      else {
        highlighted = false;
        highlightedColumn = -1;
      }
    }
  }
}

void mousePressed() {
  // Capture current mouseX and mouseY for starting rectangle coordinate
  mouseXCoord = mouseX;
  mouseYCoord = mouseY;
  // Clicking again after mouse was dragged clears rectangle
  if (drawRectangle) {
    drawRectangle = false;
  }
}

void mouseDragged() 
{
  // Only called while mouse is being moved, even if still pressed
  drawRectangle = true;
  rectWidth = mouseX-mouseXCoord;
  rectHeight = mouseY-mouseYCoord;
}

boolean checkSegmentRange(float Px, float Py, float Qx, float Qy, float x, float y) {
  // Checks that line segment from (Px, Py) to (Qx, Qy) is in range from x to y
  boolean xInRange = false, yInRange = false;
  if (Px <= Qx && x >= Px && x <= Qx) {
      xInRange = true;
  }
  else if (Px >= Qx && x <= Px && x >= Qx) {
    xInRange = true;
  }
  if (Py <= Qy && y >= Py && y <= Qy) {
    yInRange = true;
  }
  else if (Py >= Qy && y <= Py && y >= Qy) {
    yInRange = true;
  }
  return (xInRange && yInRange);
}

boolean checkPointRange(float a, float b, float value) {
  // Check that value is between a and b
  if (a <= b) {
    if (value >= a && value <= b) {
      return true;
    }
    else {
      return false;
    }
  }
  else {
    if (value < a && value > b) {
      return true;
    }
    else {
      return false;
    }
  }
}