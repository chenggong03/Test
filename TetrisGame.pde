// Cheng Gong
// Dec 17, 2016
// Beat the Tetris

Tetris cur;
int prevId;
ArrayList<Tetris> arr = new ArrayList<Tetris>();
boolean gameOn = true;
int count = 0;
int columns, rows;
int[] rowArray;
int linesCleared;

// difficulty level: more downSpeed, faster going down
int downSpeed = 50;
//

// size of boxes:
int size = 25;
// size of strokes:
int strokeW = 15;


void setup() {
  size(400,600);
  columns = width/size;
  rows = height/size;
  
  // the array of num of boxes in each row
  rowArray = new int[rows];
  strokeWeight(strokeW);
  background(0,0,0);
  cur = new Tetris();
  prevId = cur.getId();
}

void draw() {
  background(0,0,0);
  
  if (gameOn) {
    textSize(20);
    text("Beat the Tetris ", width*.05, 30);
    textSize(14);
    text("Lines Cleared: " + linesCleared, width*.7, 27.5);
    textSize(10);
    text("Created by Cheng Gong, beta version",width*.05, 15);
    
    if (count >= downSpeed) {
      
      // auto shift down
      if (canGoDown(cur, arr)) {
        cur.shiftDown();
      } else {
        arr.add(cur);
        cur = new Tetris();
        prevId = cur.getId();
        
        // check for lose condition
        for (Tetris t : arr) {
          if (cur.overlap(t, "on")) {
            gameOn = false;
          }
        }
      }
      
      // clear row test: clear possible filled rows
      for (int i = 0; i < arr.size(); i++) {
        for (int k = 0; k < 4; k++) {
          
          // increase the count of the boxes in each row
          int rowNum = arr.get(i).getY(k) / size;
          boolean rkActive = arr.get(i).isKActive(k);
          if (rowNum < rows && rkActive) {
            rowArray[ rowNum ]++;
          }
          
        }
      }
      
      /* test for num of boxes in each row
      for (int i = 0; i < rowArray.length; i++) {
        println(i + ": " + rowArray[i]);
      }
      println("==============");
      */
      
      for (int i = 0; i < rowArray.length; i++) {
        
        // find all the full rows
        if (rowArray[i] == columns) {
          
          // clear that row
          for (Tetris t : arr) {
            t.clearRow(i*size); // arg is the y needed to be cleared
          }
          linesCleared++;
        }
        
        // reset rowArray to all 0s for the next clear row test
        rowArray[i] = 0;
      }
      
      count = 0;
    } else {
      count++;
    }
  
  } else {
    text("Game Over", width*.35, 30);
  }
  
  // display all Tetrises
  for (int i = 0; i < arr.size(); i++) {
    arr.get(i).place();
  }
  
  if (gameOn) {
    cur.place();
    
    /* // draw two hori/vert lines
    strokeWeight( (size-strokeW)/4 );
    stroke(cur.getColorR(), cur.getColorG(), cur.getColorB());
    for (int i = 0; i <= cur.getwBoxNum(); i++) {
      line(cur.getX() + size*i, 0, cur.getX() + size*i, height);
    }
    */
    strokeWeight(strokeW);
    stroke(0);
  }
}

boolean canGoDown(Tetris cur, ArrayList<Tetris> arr) {
  boolean go = true;
  
  // if cur is on any existing tetris, don't go
  for (Tetris t : arr) {
    if (cur.overlap(t, "top")) {
      go = false;
    }
  }
  
  // or if cur reaches the bottom/floor, don't go
  if (cur.onFloor()) {
    go = false;
  }
  
  return go;
}

void keyPressed() {
  if (keyCode == LEFT) {
    
    boolean canShiftLeft = true;
    for (Tetris t : arr) {
      if (cur.overlap(t, "right")) {
        canShiftLeft = false;
      }
    }
    if (canShiftLeft) {
      cur.shiftRight(-1);
    }
    
  } else if (keyCode == RIGHT) {

    boolean canShiftRight = true;
    for (Tetris t : arr) {
      if (cur.overlap(t, "left")) {
        canShiftRight = false;
      }
    }
    if (canShiftRight) {
      cur.shiftRight(1);
    }
    
  } else if (keyCode == DOWN) {
    if (canGoDown(cur, arr)) {
      cur.shiftDown();
    }
    
  } else if (keyCode == UP) {
    cur.turn();
    
    boolean canTurn = true;
    for (Tetris t : arr) {
      
      // if turn the tetris would overlap with other tetris
      if (cur.overlap(t, "on")) {
        canTurn = false;
      }
      
      // if turn the tetris would exceed the display's sides
      if (cur.exceedSide()) {
        canTurn = false;
      }
    }
    
    // stop the turn by turn the tetris 3-times
    if (!canTurn) {
      cur.turn();
      cur.turn();
      cur.turn();
    }
  } else if (keyCode == SHIFT) {
    if (gameOn) {
      cur.drop();
      arr.add(cur);
      cur = new Tetris();
      prevId = cur.getId();
      
      // check for lose condition
      for (Tetris t : arr) {
        if (cur.overlap(t, "on")) {
          gameOn = false;
        }
      }
    }
  }
}









class Tetris {
  
  // width and height of each box
  int w = size;
  int h = size;
  
  int x, y; // top left displacement to the top left of the map
  
  int x1d, y1d; // 1,2,3,4 boxes' displacement to top left
  int x2d, y2d;
  int x3d, y3d;
  int x4d, y4d;
  
  int wBoxNum = 1; // shape's width in box number, for shifting
  
  int id; // type
    
  int r, g, b; // color

  boolean turned = false;
  
  // for chinese up, l, not l only
  // f f: 0, f t: 1, t f: 2, t t: 3.
  boolean turned2 = false;

  boolean active = true;
  boolean r1Active = true;
  boolean r2Active = true;
  boolean r3Active = true;
  boolean r4Active = true;
  
  
/* constructor */
  Tetris() {
    
    // assign a type
    id = genType(-1);
    
    /* test for creating different ids from the last ones
    print("id: "+id);
    println("; prevId: "+prevId);
    */
    
    // start from the middle top
    x = width/2 - w;
    y = h;
    
    // assign a color
    r = (int) random(150,255);
    g = (int) random(150,255);
    b = (int) random(150,255);
    
    place();
  }


/* accessing data */
  int getId() { return id; }
  int getX() { return x; }
  int getY() { return y; }
  int getColorR() { return r; }
  int getColorG() { return g; }
  int getColorB() { return b; }
  int getwBoxNum() { return wBoxNum; }
  // get coordinates of each box
  int getX(int i) {
    if (i == 0) { return x+x1d; }
    else if (i == 1) { return x+x2d; }
    else if (i == 2) { return x+x3d; }
    else if (i == 3) { return x+x4d; }
    return -1;
  }
  
  int getY(int i) {
    if (i == 0) { return y+y1d; }
    else if (i == 1) { return y+y2d; }
    else if (i == 2) { return y+y3d; }
    else if (i == 3) { return y+y4d; }
    return -1;
  }
  
  // char a is to determine which operation to do
  // on: overlap
  // top: this on Top of t
  // left: on Left
  // right: on Right
  boolean overlap(Tetris t, String c) {
    
    int xplus, yplus;
    if (c == "top") { xplus = 0; yplus = h; }
    else if (c == "left") { xplus = w; yplus = 0; }
    else if (c == "right") { xplus = -w; yplus = 0; }
    else { xplus = 0; yplus = 0; } // (c == "on")
    
    for (int i = 0; i < 4; i++) { // check each box of this
      for (int k = 0; k < 4; k++) { // check each box of t
        if (   t.isKActive(k)
            && this.getX(i) + xplus == t.getX(k)
            && this.getY(i) + yplus == t.getY(k)) {
              return true;
        }
      }
    }
    return false;
  }
  
  boolean exceedSide() {
    for (int i = 0; i < 4; i++) {
      // if the box exceeds the left or the right display
      // (because I wrote the turn() so that tetris always has the
      // same upper left x,y, the turn won't actually exceed on
      // the left side of the display)
      
      if (this.getX(i) < 0 || this.getX(i) > width - w) {
        return true;
      }
    }
    return false;
  }
  
  boolean onFloor() {
    for (int i = 0; i < 4; i++) {
      if (this.getY(i) == height - h) {
        return true;
      }
    }
    return false;
  }
  
  boolean isKActive(int k) {
    if (k == 0) {
      return r1Active;
    } else if (k == 1) {
      return r2Active;
    } else if (k == 2) {
      return r3Active;
    } else if (k == 3) {
      return r4Active;
    }
    return false;
  }
  
  
/* modifying data */

  int genType(int id) {
    
    if (id == -1) {
      do {
        id = (int) random(0,7);
      } while (id == prevId);
    }
    if (id == 0) { // line
      x1d = 0; y1d = 0;
      x2d = w; y2d = 0;
      x3d = w*2; y3d = 0;
      x4d = w*3; y4d = 0;
      wBoxNum = 4;
    } else if (id == 1) { // z
      x1d = 0; y1d = 0;
      x2d = w; y2d = 0;
      x3d = w; y3d = h;
      x4d = w*2; y4d = h;
      wBoxNum = 3;
    } else if (id == 2) { // not z
      x1d = w; y1d = 0;
      x2d = w*2; y2d = 0;
      x3d = 0; y3d = h;
      x4d = w; y4d = h;
      wBoxNum = 3;
    } else if (id == 3) { // chinese up
      x1d = w; y1d = 0;
      x2d = 0; y2d = h;
      x3d = w; y3d = h;
      x4d = w*2; y4d = h;
      wBoxNum = 3;
    } else if (id == 4) { // l
      x1d = 0; y1d = 0;
      x2d = 0; y2d = h;
      x3d = 0; y3d = h*2;
      x4d = w; y4d = h*2;
      wBoxNum = 2;
    } else if (id == 5) { // not l
      x1d = w; y1d = 0;
      x2d = w; y2d = h;
      x3d = 0; y3d = h*2;
      x4d = w; y4d = h*2;
      wBoxNum = 2;
    } else if (id == 6) { // square
      x1d = 0; y1d = 0;
      x2d = w; y2d = 0;
      x3d = 0; y3d = h;
      x4d = w; y4d = h;
      wBoxNum = 2;
    } 
    return id;
  }
  
  // all clockwise rotation
  void turn() {
    
    if (id == 0 && !turned) { // line
      x1d = 0; y1d = 0;
      x2d = 0; y2d = h;
      x3d = 0; y3d = h*2;
      x4d = 0; y4d = h*3;
      wBoxNum = 1;
      turned = !turned;
      
    } else if (id == 1 && !turned) { // z
      x1d = w; y1d = 0;
      x2d = 0; y2d = h;
      x3d = w; y3d = h;
      x4d = 0; y4d = h*2;
      wBoxNum = 2;
      turned = !turned;
      
    } else if (id == 2 && !turned) { // not z
      x1d = 0; y1d = 0;
      x2d = 0; y2d = h;
      x3d = w; y3d = h;
      x4d = w; y4d = h*2;
      wBoxNum = 2;
      turned = !turned;
    } else if (id == 0 || id == 1 || id == 2) {
      genType(id);
      turned = !turned;
    }
    
    if (id == 3) { // chinese up
      if (!turned && !turned2) { // not rotated
        x1d = 0; y1d = 0;
        x2d = 0; y2d = h;
        x3d = w; y3d = h;
        x4d = 0; y4d = h*2;
        wBoxNum = 2;
        turned2 = !turned2;
      } else if (!turned && turned2) { // rotated once
        x1d = 0; y1d = 0;
        x2d = w; y2d = 0;
        x3d = w*2; y3d = 0;
        x4d = w; y4d = h;
        wBoxNum = 3;
        turned = !turned;
        turned2 = !turned2;
      } else if (turned && !turned2) { // rotated twice
        x1d = w; y1d = 0;
        x2d = 0; y2d = h;
        x3d = w; y3d = h;
        x4d = w; y4d = h*2;
        wBoxNum = 2;
        turned2 = !turned2;
      } else { //(turned && turned2) rotated 3-times
        genType(id);
        turned = !turned;
        turned2 = !turned2;
      }
      
    } else if (id == 4) { // l
      if (!turned && !turned2) { // not rotated
        x1d = 0; y1d = 0;
        x2d = w; y2d = 0;
        x3d = w*2; y3d = 0;
        x4d = 0; y4d = h;
        wBoxNum = 3;
        turned2 = !turned2;
      } else if (!turned && turned2) { // rotated once
        x1d = 0; y1d = 0;
        x2d = w; y2d = 0;
        x3d = w; y3d = h;
        x4d = w; y4d = h*2;
        wBoxNum = 2;
        turned = !turned;
        turned2 = !turned2;
      } else if (turned && !turned2) { // rotated twice
        x1d = w*2; y1d = 0;
        x2d = 0; y2d = h;
        x3d = w; y3d = h;
        x4d = w*2; y4d = h;
        wBoxNum = 3;
        turned2 = !turned2;
      } else { //(turned && turned2) rotated 3rd-times
        genType(id);
        turned = !turned;
        turned2 = !turned2;
      }
    
    } else if (id == 5) { // not l
      if (!turned && !turned2) { // not rotated
        x1d = 0; y1d = 0;
        x2d = 0; y2d = h;
        x3d = w; y3d = h;
        x4d = w*2; y4d = h;
        wBoxNum = 3;
        turned2 = !turned2;
      } else if (!turned && turned2) { // rotated once
        x1d = 0; y1d = 0;
        x2d = w; y2d = 0;
        x3d = 0; y3d = h*2;
        x4d = 0; y4d = h;
        wBoxNum = 2;
        turned = !turned;
        turned2 = !turned2;
      } else if (turned && !turned2) { // rotated twice
        x1d = 0; y1d = 0;
        x2d = w; y2d = 0;
        x3d = w*2; y3d = 0;
        x4d = w*2; y4d = h;
        wBoxNum = 3;
        turned2 = !turned2;
      } else { //(turned && turned2) rotated 3-times
        genType(id);
        turned = !turned;
        turned2 = !turned2;
      }
    }
    // else if (id == 6) { ...do nothing... }
  }
  
  void shiftRight(int dir) {
    if (active) {
      x = constrain(x + w * dir, 0, width - w * wBoxNum);
    }
  }
  
  void drop() {
    while (canGoDown(this, arr)) {
      this.shiftDown();
    }
    active = false;
  }
  
  void shiftDown() {
    if (active) {
      y = y + h;
    }
  }
  
  void clearRow(int y_clear) {
    
    // deactivate the boxes in that row
    if (y_clear == y+y1d) {
      r1Active = false;
    }
    if (y_clear == y+y2d) {
      r2Active = false;
    }
    if (y_clear == y+y3d) {
      r3Active = false;
    }
    if (y_clear == y+y4d) {
      r4Active = false;
    }
    
    // move boxes above that line down
    if (r1Active && y_clear > y+y1d) {
      y1d += size;
    }
    if (r2Active && y_clear > y+y2d) {
      y2d += size;
    }
    if (r3Active && y_clear > y+y3d) {
      y3d += size;
    }
    if (r4Active && y_clear > y+y4d) {
      y4d += size;
    }
  }

  
/* applying data */
  //int count1 = 100;
  void place() {
    
    // place the rect in original pos
    fill (r,g,b);
    if (r1Active) {
      rect(x + x1d, y + y1d, w, h);
    }
    if (r2Active) {
      rect(x + x2d, y + y2d, w, h);
    }
    if (r3Active) {
      rect(x + x3d, y + y3d, w, h);
    }
    if (r4Active) {
      rect(x + x4d, y + y4d, w, h);
    }
    
    /* test for upperleft x,y loc of each tetris
       use this test along with the count var before place() method
    if (count1 >= downSpeed) {
      println("x: " + x + "; y: " + y);
      count1 = 0;
      } else { count1++; }
    */
    
    }
}