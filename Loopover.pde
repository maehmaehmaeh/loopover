final int shuffleMoves = 100;

int squareSize = 100;
int size = 5;

int[][] board = new int[size][size];

int selectedX = -1;
int selectedY = -1;

boolean startFlag = false;
boolean gameRunning = false;

int startTime = -1;
int winTime = -1;
int highscore = -1;

int mod(int i) {
  int n = i;
  while (true) {
    if (n < 0) n+=size;
    else if (n < size) return n;
    else n-=size;
  }
}

void shuffleBoard() {
  if (gameRunning) return;
  startFlag = false;

  for (int i = 0; i < shuffleMoves; i++) {
    if (random(1) < 0.5) {
      moveRow((int) floor(random(size)), (int) floor(random(size-1)));
    } else {
      moveCol((int) floor(random(size)), (int) floor(random(size-1)));
    }
  }

  startFlag = true;
}

void moveRow(int row, int dist) {
  int[] oldRow = new int[size];
  for (int index = 0; index < size; index++) {
    oldRow[index] = board[index][mod(row)];
  }

  for (int index = 0; index < size; index++) {
    board[index][mod(row)] = oldRow[mod(index - dist)];
  }

  if (startFlag) startGame();
  testFinish();
}

void moveCol(int col, int dist) {
  int[] oldCol = new int[size];
  for (int index = 0; index < size; index++) {
    oldCol[index] = board[mod(col)][index];
  }

  for (int index = 0; index < size; index++) {
    board[mod(col)][index] = oldCol[mod(index - dist)];
  }

  if (startFlag) startGame();
  testFinish();
}

void startGame() {
  startFlag = false;
  gameRunning = true;
  startTime = millis();
}

void testFinish() {
  if(!gameRunning) return;
  
  for (int i = 0; i < size*size; i++) {
    if (board[i%size][i/size] != i) return;
  }
  System.out.println("game won");

  gameRunning = false;
  winTime = millis() - startTime;
  
  if(winTime < highscore || highscore == -1) {
    highscore = winTime;
    writeHighscore();
  }
  else writeAttempt(winTime);
}

void writeHighscore() {
  String[] old = loadStrings("highscores_" + size + ".txt");
  String[] newS;
  
  if(old == null) newS = new String[3];
  else newS = new String[old.length+3];
  
  newS[0] = "" + highscore;
  newS[1] = "" + day() + "." + month() + "." + year() + " " + hour() + ":" + minute();
  newS[2] = " ";
  
  if(old != null) {
    for(int i = 0; i < old.length; i++) {
      newS[i+3] = old[i];
    }
  }
  saveStrings("highscores_" + size + ".txt", newS);
}
void writeAttempt(int millis) {
  String[] old = loadStrings("attempts_" + size + ".txt");
  String[] newS;
  
  if(old == null) newS = new String[3];
  else newS = new String[old.length+3];
  
  newS[0] = "" + millis;
  newS[1] = "" + day() + "." + month() + "." + year() + " " + hour() + ":" + minute();
  newS[2] = " ";
  
  if(old != null) {
    for(int i = 0; i < old.length; i++) {
      newS[i+3] = old[i];
    }
  }
  saveStrings("attempts_" + size + ".txt", newS);
}

void keyPressed() {
  if(key == 'f') save("screenshot.png");
  if (key == 's') {
    shuffleBoard();
  }
  if(key == '+') {
    if(!gameRunning) {
      size++;
      squareSize = 500/size;
      
      setVars();
      background(#F0F0F0);
    } 
  }
  if(key == '-') {
    if(!gameRunning) {
      size = max(2, size-1);
      squareSize = 500/size;
      
      setVars();
      background(#F0F0F0);
    }
  }
  if(key == 'r') {
    setVars();
  }
}

void mouseReleased() {
  selectedX = selectedY = -1;
}
void mousePressed() {
  selectedX = mouseX / squareSize;
  selectedY = mouseY / squareSize;
}
void mouseDragged() {
  if (selectedX != mouseX / squareSize) {
    moveRow(selectedY, mouseX / squareSize - selectedX);
    selectedX = mouseX / squareSize;
  }
  if (selectedY != mouseY / squareSize) {
    moveCol(selectedX, mouseY / squareSize - selectedY);
    selectedY = mouseY / squareSize;
  }
}

void setVars() {
  board = new int[size][size];

  selectedX = -1;
  selectedY = -1;

  startFlag = false;
  gameRunning = false;

  startTime = -1;
  winTime = -1;
  try {
    highscore = Integer.valueOf(loadStrings("highscores_" + size + ".txt")[0]);
  }
  catch(Exception e) {
    highscore = -1;
  }

  for (int i = 0; i < size*size; i++) {
    board[i%size][i/size] = i;
  }
}

String toCorrespondingString(int i) {
  if (size <= 5) return "" + (char) ('A' + i);
  else return "" + i;
}

String toSecondString(int millis) {
  return "" + (((float) millis) / 1000) + "s";
}

void setup() {
  size(500, 600);
  setVars();
}

void draw() {
  for (int i = 0; i < size; i++) {
    for (int j = 0; j < size; j++) {
      fill(255 - (board[i][j] % size) * 255 / size, (board[i][j] / size) * 255 / size, (board[i][j] % size) * 255 / size);
      rect(i*squareSize, j*squareSize, squareSize, squareSize);

      fill(0);
      text(toCorrespondingString(board[i][j]), i*squareSize+squareSize/2, j*squareSize+squareSize/2);
    }
  }
  
  fill(#F0F0F0);
  rect(0, squareSize*size, squareSize*size, 100);
  
  fill(0);
  if(gameRunning) text("Zeit: " + toSecondString(millis() - startTime), squareSize*(size-1)/2, squareSize*size + squareSize/2 - 5);
  else if(winTime != -1) text("Zeit: " + toSecondString(winTime), squareSize*(size-1)/2, squareSize*size + squareSize/2 - 5);
  
  if(highscore != -1) text("Rekord: " + toSecondString(highscore), squareSize*(size-1)/2, squareSize*size + squareSize/2 + 10);
}
