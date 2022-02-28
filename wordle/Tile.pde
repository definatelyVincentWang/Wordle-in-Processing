public enum State {
  NOT_GUESSED,
  GUESSING,
  GUESSED,
  CORRECT_LETTER,
  CORRECT_PLACE;
}

class Tile {
  color c;
  int x,y;
  char ch;
  State STATE;
  
  Tile(int x, int y) {
    this.x = x;
    this.y = y;
    c = color(100);
    STATE = State.NOT_GUESSED;
    ch = ' ';
  }
  
  void display() {
    //displays boxes
    strokeWeight(3);
    if(STATE == State.NOT_GUESSED){
      stroke(100);
      c = color(200);
    } else if(STATE == State.GUESSED){
      strokeWeight(4);
      stroke(0);
      c = color(100);
    } else if (STATE == State.CORRECT_LETTER) {
      strokeWeight(4);
      stroke(0);
      c = color(255,255,0);
    } else if (STATE == State.CORRECT_PLACE) {
      strokeWeight(4);
      stroke(0);
      c = color(0,255,0);
    } else {
      stroke(255);
      strokeWeight(4);
    }
    fill(c);
    rect(x,y,tileWidth, tileHeight);
    
    //Then displays the characters
    textFont(createFont("Calisto MT", tileHeight - 10));
    textAlign(LEFT);
    if(STATE != State.NOT_GUESSED){
      fill(0);
      text(ch, x + tileWidth / 4, y + tileHeight - 15);
    }
  }
}
