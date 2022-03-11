/*****************************************************************************************************
 *  ITS JUST WORDLE
 * BUT IN PROCESSING
 * WOW SO COOL
 * Credits:
 *   kelvin for doing some stuf
 *   vin for doing other stuff
 *   jeylnfish for the font source
 *
 * TO DO:
 *        Add animations for:
 *          - Invalid word
 *          - Revealing tiles, one at a time
 *          - "bounce in" for when a character is added to a tile
 *        How are you supposed to format headers like this?
 ******************************************************************************************************/

public enum GameState {
  ONGOING,
  DEFEAT,
  VICTORY;
}

int tileSideLength, guessNum, charNum, invalidCount, padding;
String ans;
color bgColor, correctColor, closeColor, incorrectColor, keyColor;
String[] inputWords, answerWords;
String[] qwerty = {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P", "A", "S", "D", "F", "G", "H", "J", "K", "L", "ENTER", "Z", "X", "C", "V", "B", "N", "M", "BACKSPACE"};
Tile[][] tiles;
GameState gState;
PFont text, title;
Key[] keyboard;

void setup() {
  background(bgColor);
  size(750, 1050);
  frameRate(144);
  inputWords = loadStrings("input-words.txt");
  answerWords = loadStrings("answer-words.txt");
  guessNum = 0;
  charNum = 0;
  invalidCount = 0;
  ans = answerWords[int(random(answerWords.length))];
  bgColor = color(19);
  correctColor = color(83, 141, 78);
  closeColor = color(181, 159, 59);
  incorrectColor = color(60);
  keyColor = color(129, 131, 132);
  
  text = createFont("Arial Bold", 30);
  title = createFont("karnakcondensed-normal-700.ttf", 60);
  
  //Creates tiles
  tiles = new Tile[6][5];
  int y = 90; //starting ypos
  padding = 10; //padding of tiles
  tileSideLength = (width - 6 * padding)/(tiles[0].length + 2);
  for (Tile[] tRow : tiles) {
    int x = padding + tileSideLength;
    for (int j = 0; j < tRow.length; j++) {
      tRow[j] = new Tile(x, y, tileSideLength);
      x += tileSideLength + padding;
    }
    y += tileSideLength + padding;
  }
  
  //initialize keyboard
  keyboard = new Key[28];
  initKb();
  

  //displays tiles
  for (Tile[] tRow : tiles) for (Tile t : tRow) t.display();
  
  gState = GameState.ONGOING;
  
  println("Press space to print the answer");
  printTitle();
}

void draw() {
  background(bgColor);
  printTitle();
  for (Tile[] tRow : tiles) for (Tile t : tRow) t.display();
  for(Key k : keyboard) k.display();
  if (gState == GameState.VICTORY) displayVictory();
  if (gState == GameState.DEFEAT) displayDefeat();
}

void mouseReleased(){
  kbPressed();
}
void keyPressed() {
  checkInputKey(key);
}


//Prints the title;
void printTitle() {
  stroke(50);
  strokeWeight(2);
  line(30, 70, width-30, 70);
  textFont(title);
  textAlign(CENTER);
  fill(255);
  text("Wordle", width / 2, 60);
}

//Displays victory screen
void displayVictory() {
  //Using ? as intended, to make code impossibly confusing to read. here it's only being used to be grammatically accurate
  textBox(guessNum == 1 ? "Nice, you did it in " + guessNum + " attempt" : "Nice, you did it in " + guessNum + " attempts", 150, height / 3, width - 300, 100);
}

//Displays defeat screen
void displayDefeat() {
  textBox("Correct answer: \"" + Character.toUpperCase(ans.charAt(0)) + ans.substring(1, ans.length()) + "\"", 150, height / 3, width - 300, 100);
}

void initKb(){
  int gap = 8;
  int w = (width - (11 * gap)) / 10;
  int h = 80;
  int x = gap;
  int y = 90 + (6 * (tileSideLength + padding)) + 25;
  int i = 0;
  
  for (; i < 10; i++) {
    keyboard[i] = new Key(x, y, w, h, qwerty[i]);
    x += w + gap;
  }
  
  // second row
  x = gap * 2 + (w / 2);
  y += h + 1.5 * gap;
  for (; i < 19; i++) {
    keyboard[i] = new Key(x, y, w, h, qwerty[i]);
    x += w + gap;
  }
  
  //third row
  x = gap;
  y += h + 1.5 * gap;
  //enter
  keyboard[i] = new Key(x, y, int(gap + 1.5 * w), h, qwerty[i]);
  x += gap;
  i++;
  x += (3 * w) / 2 + gap;
  for (; i < 27; i++) {
    keyboard[i] = new Key(x, y, w, h, qwerty[i]);
    x += w + gap;
  }
  //backspace
  keyboard[i] = new Key(x, y, int(1.5 * w), h, qwerty[i]);

}

void kbPressed() {
  //if the game isn't running, dont check for keyboard inputs
  if (gState != GameState.ONGOING) return;

  //if enter key is pressed, make sure the input is valid before checking it.
  String kPressed = " ";
  for (Key i : keyboard) {
    if (i.isPressed()) {
      kPressed = i.k;
      break;
    }
  }
  
  //if no key was pressed, stop
  if (kPressed.equals(" ")) return;
  
  if(kPressed.equals("ENTER")) checkInputKey('\n');
  else if(kPressed.equals("BACKSPACE")) checkInputKey('\b');
  else checkInputKey(kPressed.charAt(0));
  println("\"" + kPressed+ "\"");
}

void checkInputKey(char c){
  //if the game isn't running, dont check for keyboard inputs
  if (gState != GameState.ONGOING) return;

  //if enter key is pressed, make sure the input is valid before checking it.
  if (c == '\n') {
    if (charNum < 5) return;
    if (checkGuess()) {
      guessNum++;
      gState = GameState.VICTORY;
      return;
    }
    guessNum++;
    charNum = 0;
    if (guessNum == 6) {
      gState = GameState.DEFEAT;
      return;
    }

  } else if (c == '\b') {  //removes the current character and backs up a tile
    if (charNum == 0) return;
    tiles[guessNum][charNum-1].ch = ' ';
    tiles[guessNum][charNum-1].tState = TileState.NOT_GUESSED;
    charNum--;
  } else if (c == ' ') { //shows the answer
    println("Answer: " + ans);
  } else {
    //Ensures the inputted key is from A-Z, then inputs that into the tile
    if ((Character.toLowerCase(c) >= 97 && Character.toLowerCase(c) <= 122) && charNum < 5) {
      tiles[guessNum][charNum].ch = Character.toUpperCase(c);
      tiles[guessNum][charNum].tState = TileState.GUESSING;
      charNum++;
    }
  }
}

void textBox(String msg, int x, int y, int w, int h){
  fill(255, 255, 255, 210);
  noStroke();
  rect(x, y, w, h, 10);
  textFont(text);
  fill(0);
  textAlign(CENTER);
  text(msg, (2 * x + w) / 2, y + 0.6 * h);
}

//Checks the inputted guess
boolean checkGuess() {
  String guess = "";
  for (int i = 0; i < tiles[guessNum].length; i++) guess += tiles[guessNum][i].ch;
  guess = guess.toLowerCase();

  //checks if guess was valid, based on input-words.txt
  boolean valid = false;
  for (String s : inputWords) {
    if (s.equals(guess)) {
      valid = true;
      break;
    }
  }
  if (!valid) {
    invalidCount++;
    println("Not a valid input: " + guess);
    for (Tile t : tiles[guessNum]) {
      t.ch = ' ';
      t.c = color(100);
      t.tState = TileState.NOT_GUESSED;
      t.display();
    }
    guessNum--;
    return false;
  }

  //now checks each character with answer, starting by marking each tile as wrong before updating the correct ones
  
  for (int i = 0; i < tiles[0].length; i++) tiles[guessNum][i].tState = TileState.GUESSED;
  //Marks characters in the correct location, and keeps a counter for keeping track of characters.
  int[] count = new int[26];
  for (int i = 0; i < ans.length(); i++) {
    count[(ans.charAt(i))-97]++;
    if (ans.charAt(i) == guess.charAt(i)) {
      tiles[guessNum][i].tState = TileState.CORRECT_PLACE;
      count[(ans.charAt(i))-97]--;
    }
  }

  //Now uses the counter to mark tiles that are in the wrong place
  for (int i = 0; i < ans.length(); i++) {
    for (int j = 0; j < guess.length(); j++) {
      //tiles[guessNum][j].tState != State.CORRECT_PLACE
      if (ans.charAt(i) == guess.charAt(j) && tiles[guessNum][j].tState != TileState.CORRECT_PLACE && count[(ans.charAt(i))-97] > 0) {
        tiles[guessNum][j].tState = TileState.CORRECT_LETTER;
        count[ans.charAt(i)-97]--;
      }
    }
  }
  
  //now adds those states to the onscreen keyboard
  for(int i = 0; i < guess.length(); i++){
    if(tiles[guessNum][i].tState == TileState.CORRECT_PLACE) {
      //find corresponding key
      for(Key ky : keyboard){
        if(ky.k.length() > 1) continue; //makes sure "ENTER" and "BACKSPACE" aren't used
        if(ky.k.charAt(0) == tiles[guessNum][i].ch){
          ky.kState = KeyState.CORRECT_PLACE;
          break;
        }
      }
    } else if(tiles[guessNum][i].tState == TileState.CORRECT_LETTER) {
      for(Key ky : keyboard){
        if(ky.k.length() > 1) continue; //makes sure "ENTER" and "BACKSPACE" aren't used
        if(ky.k.charAt(0) == tiles[guessNum][i].ch && ky.kState != KeyState.CORRECT_PLACE){
          ky.kState = KeyState.CORRECT_LETTER;
          break;
        }
      }
    } else {
      for(Key ky : keyboard){
        if(ky.k.length() > 1) continue; //makes sure "ENTER" and "BACKSPACE" aren't used
        if(ky.k.charAt(0) == tiles[guessNum][i].ch && ky.kState == KeyState.NOT_GUESSED){
          ky.kState = KeyState.GUESSED;
          break;
        }
      }
    }
  }
  

  //displays the tiles
  for (Tile t : tiles[guessNum]) t.display();
  return guess.equals(ans);
}
