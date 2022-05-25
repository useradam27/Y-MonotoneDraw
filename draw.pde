

ArrayList<Vertex> vertices = new ArrayList<Vertex>();
Vertex origin;

Stack myStack = new Stack();
ArrayList<Line> polygon_lines = new ArrayList<Line>();
ArrayList<Line> all_lines = new ArrayList<Line>();
ArrayList<Line> triangulation_lines = new ArrayList<Line>();
Boolean canClose = false;
Boolean closed = false;
Boolean hasIntersection = false;
Boolean pressed = false;
int triangulationDelay = 1;
final String polygonColor = "black";
final Button btnMonotone = new Button(50, 400, 200, 100, ButtonType.Y_MONOTONE);
final Button btnReset = new Button(350, 400, 200, 100, ButtonType.RESET);

class Vertex implements Comparable<Vertex> {
  float xpos, ypos;
  int chain;
  Vertex(float xpos, float ypos) {
    this.xpos = xpos;
    this.ypos = ypos;
    chain = 0;
  }
  void connect(Vertex v) {
    stroke(0);
    line(v.xpos, v.ypos, this.xpos, this.ypos);
  }
  
  int compareTo(Vertex v) {
    return round(ypos - v.ypos);
  }
  
  public String toString()
    {
    return "[ " + xpos + "," + ypos + "]";
  }
}

enum ButtonType {
  Y_MONOTONE,
  RESET
}

class Button {
  float xpos,ypos;
  int sizeX, sizeY;
  ButtonType t;
  Boolean display = false;
  
  Button(float xpos, float ypos, int sizeX, int sizeY, ButtonType t) {
    this.xpos = xpos;
    this.ypos = ypos;
    this.sizeX = sizeX;
    this.sizeY = sizeY;
    this.t = t;
  }
  Boolean isHovered() {
    return(mouseX > xpos && mouseX < xpos + sizeX && mouseY > ypos && mouseY < ypos + sizeY);
  }
  
  void handleClick() {
    if (t ==  ButtonType.Y_MONOTONE) {
      if (isYMonotone()) {
        pressed = true;
        display = false;
        background(255);
        println("is y-monotone");
        ArrayList<Vertex> copy = new ArrayList<Vertex>(vertices);
        for (int i = 0; i < copy.size(); i++)
        {
          println("copy: " + copy.get(i).ypos);
        }
        copy = reorder(copy);
        for (int i = 0; i < copy.size(); i++)
        {
          println("reorder: " + copy.get(i).ypos);
        }
        findChains(copy);
        
        sortPoints(copy);
        for (int i = 0; i < copy.size(); i++)
        {
          println("sort: " + copy.get(i).ypos);
        }
        
        
        triangulate(copy);
        //pressed = false;
        //stroke(color(0,0,255));
        //line(100, 100, 200, 200);
        
      } else {
        println("is NOT y-monotone");
      }
    } else if (t == ButtonType.RESET) {
      println("RESET CLICKED");
      vertices = new ArrayList<Vertex>();
      origin = null;
      myStack = new Stack();
      polygon_lines = new ArrayList<Line>();
      all_lines = new ArrayList<Line>();
      triangulation_lines = new ArrayList<Line>();
      canClose = false;
      closed = false;
      hasIntersection = false;
      pressed = false;
      triangulationDelay = 1;
    }
  }
  
  void draw() {
    if (!isHovered()) {
      stroke(100);
      fill(100, 255);
      
    } else {
      stroke(0);
      fill(0, 100);
    }     
    rect(xpos, ypos, sizeX, sizeY, 10);
    fill(255);
    String buttonText = t ==  ButtonType.Y_MONOTONE ? "Y-Monotone Triangulation" : "Reset";
    textAlign(CENTER, CENTER);
    text(buttonText,xpos + 20,ypos + 20,sizeX - 40,sizeY - 40);   
  }
}

public Vertex intersect(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {
  float m1 = (y2 - y1) / (x2 - x1);
  float m2 = (y4 - y3) / (x4 - x3);
  float b1 = y1 - m1 * x1;
  float b2 = y3 - m2 * x3;
  float circX, circY;
  circX = round((b2 - b1) / (m1 - m2));
  circY = round(m1 * circX + b1);
  if (x2 ==  x1) { // Vertical segment; slope is undefined
    circX = x1;
    circY = round(m2 * circX + b2);
    if (!(circY < max(y1,y2) && circY>min(y1,y2))) return null;
  }
  if (x4 ==  x3) { // Vertical segment; slope is undefined
    circX = x3;
    circY = round(m1 * circX + b1);
    if (!(circY < max(y3,y4) && circY>min(y3,y4))) return null;
  }
  Vertex v = new Vertex(circX, circY);
  if (circX >= max(min(x1, x2), min(x3, x4)) && circX<= min(max(x1, x2), max(x3, x4)) && ((circX!= vertices.get(vertices.size() - 1).xpos) || (circY!= vertices.get(vertices.size() - 1).ypos))) {
    return v; // The intersection point is within the limits of both segments
  }
  return null; // The intersection point is not within both segments
}

Boolean isYMonotone() {
  int mins = 0;
  int size = vertices.size();
  println("VERTICES SIZE = ",size);
  for (int i = 0; i < size; i++) {
    int next = ((i + 1) % size + size) % size;
    int prev = ((i - 1) % size + size) % size;
    if ((vertices.get(i).ypos<vertices.get(next).ypos) && (vertices.get(i).ypos<vertices.get(prev).ypos))  {
      mins++;
    }
  }
  println("Mins = ",mins);
  return mins <= 1;
}

void mousePressed() {
  if (btnReset.isHovered() && btnReset.display) {
    btnReset.handleClick();
  } else {
    if (!closed) {
      if (!hasIntersection) {
        Vertex v;
        if (canClose) {
          closed = true;
          btnMonotone.display = true;
        } else {
          v = new Vertex(mouseX, mouseY);
          vertices.add(v);
          if (vertices.size() ==  1) {
            origin = v;
          }
        }
        if (vertices.size()>= 2) {
          btnReset.display = true;
          if (closed) {
            polygon_lines.add(new Line(vertices.get(vertices.size() - 1),origin, polygonColor));
          } else {
            polygon_lines.add(new Line(vertices.get(vertices.size() - 2), vertices.get(vertices.size() - 1), polygonColor));
          }
        }
      }
    } else {
      if (btnMonotone.isHovered() && btnMonotone.display) {
        btnMonotone.handleClick();
      } 
    } 
  }
}

void setup() {
  size(600, 600);
  background(255);
  frameRate(60);
}

void drawPolygon() {
  // Lambda expression; might need to change to for loop for older versions of Processing
  //polygon_lines.forEach((line) -> line.draw());
  for(Line l : polygon_lines)
  {
    l.draw();
  }
  for (int i = 1; i < vertices.size(); i++) {
    Vertex v1 = vertices.get(i - 1);
    Vertex v2 = vertices.get(i);
    
    if (vertices.size()>2) {
      Vertex lastVertex = vertices.get(vertices.size() - 1);
      Vertex intersect;
      if (!closed && (intersect = intersect(v1.xpos, v1.ypos, v2.xpos, v2.ypos, lastVertex.xpos, lastVertex.ypos, mouseX, mouseY))!= null) {
        if (!((intersect.xpos > origin.xpos - 10 && intersect.xpos < origin.xpos + 10 && intersect.ypos > origin.ypos - 10 && intersect.ypos < origin.ypos + 10) && canClose)) {
          hasIntersection = true;
          fill(255, 100);
          circle(intersect.xpos, intersect.ypos, 20);
        } 
      }
    }
  }
}

void draw() {
  background(255);
  if (btnReset.display) btnReset.draw();
  if (!pressed) {    
    if (btnMonotone.display) btnMonotone.draw();
    hasIntersection = false;
    if (origin!= null) {
      if (!closed) {
        Vertex v = vertices.get(vertices.size() - 1);
        stroke(200);
        //Gray line that follows the mouse
        line(v.xpos, v.ypos, mouseX,mouseY);
      }
      if (vertices.size()>1) {
        //Draw the polygon
        drawPolygon();
        if (vertices.size()>2 && !closed) {
          //Check whether the polygon can be closed
          if (mouseX > origin.xpos - 10 && mouseX < origin.xpos + 10 && mouseY > origin.ypos - 10 && mouseY < origin.ypos + 10) {
            //Draw circle around the origin to indicate that the polygon can be closed
            fill(0, 100);
            noStroke();
            circle(origin.xpos, origin.ypos, 20);
            canClose = true;
          } else {
            canClose = false;
          }
        }
      }
    }
  } else {
    // Lambda expression; might need to change to for loop for older versions of Processing
    //triangulation_lines.forEach((line) -> line.draw());
     //polygon_lines.forEach((line) -> line.draw());
    for(Line l : triangulation_lines)
    {
      l.draw();
    }
  }
}

//finds highest y point
Vertex findMax(ArrayList<Vertex> v)
{
  Vertex max = v.get(0);
  for (int i = 1; i < v.size(); i++)
  {
    if (v.get(i).ypos < max.ypos)
      max = v.get(i);
  }
  
  return max;
}

//finds first x point
Vertex findminX(ArrayList<Vertex> v)
{
  Vertex min = v.get(0);
  for (int i = 1; i < v.size(); i++)
  {
    if (v.get(i).xpos < min.xpos)
      min = v.get(i);
  }
  
  return min;
}


//reorders points to sort clockwise from highest y point
ArrayList<Vertex> reorder(ArrayList<Vertex> v)
{
  ArrayList<Vertex> tempList = new ArrayList<Vertex>();
  Vertex maxV = findMax(v);
  int spot = 0;
  for (int i = 0; i < v.size(); i++)
  {
    if (v.get(i).ypos == maxV.ypos)
    {
      spot = i;
      break;
    }
  }
  
  for (int i = spot; i < v.size(); i++)
  {
    tempList.add(v.get(i));
  }
  for (int i = 0; i < spot; i++)
  {
    tempList.add(v.get(i));
  }
  
  return tempList;
}


//finds chains for Vertex
void findChains(ArrayList<Vertex> v)
{
  
  int spot = 0;
  Vertex start = v.get(0);
  
  for (int i = 1; i < v.size(); i++)
    {
    if (v.get(i).ypos > start.ypos)
      {
      //System.out.println("q=" + start.ypos + " p=" + v.get(i).ypos);
      triangulation_lines.add(new Line(start,v.get(i), "blue"));
      all_lines.add(new Line(start, v.get(i), polygonColor));
      //all_lines.add(new Line(v.get(i), start, polygonColor));
      v.get(i).chain = 1;
      start = v.get(i);
      
    }
    else
      {
      spot = i;
      break;
    }
  }
  
  for (int x = spot; x < v.size(); x++)
    {
    //System.out.println(spot +":"+x);
    System.out.println("q=" + start.ypos + " p=" + v.get(x).ypos);
    triangulation_lines.add(new Line(start, v.get(x), "red"));
    all_lines.add(new Line(start, v.get(x), polygonColor));
    //all_lines.add(new Line(v.get(x), start, polygonColor));
    v.get(x).chain = 0;
    start = v.get(x);
  }
  triangulation_lines.add(new Line(start, v.get(0), "red"));
  all_lines.add(new Line(start, v.get(0), polygonColor));
  //all_lines.add(new Line(v.get(0), start, polygonColor));
  
  //return points;
}

//checks if line is interior
public boolean isInterior(Vertex start, Vertex end, ArrayList<Vertex> v)
{
  
  for (int i = 0; i < all_lines.size(); i++)
  {
    
    if ((start.xpos == all_lines.get(i).start.xpos) && (start.ypos == all_lines.get(i).start.ypos) && (end.xpos == all_lines.get(i).end.xpos) && (end.ypos == all_lines.get(i).end.ypos)) {
      println("fail1: " + all_lines.get(i));
      return false;
    }
    
    if ((start.xpos == all_lines.get(i).end.xpos) && (start.ypos == all_lines.get(i).end.ypos) && (end.xpos == all_lines.get(i).start.xpos) && (end.ypos == all_lines.get(i).start.ypos)) {
      println("fail1: " + all_lines.get(i));
      return false;
    }
  }
  
  float start_x = start.xpos;
  float end_x = end.xpos;
  
  if (start.xpos < end.xpos)
  {
    start_x = start.xpos;
    end_x = end.xpos;
  }
  else
  {
    start_x = end.xpos;
    end_x = start.xpos;
  }
  
  float m = (end.ypos - start.ypos) / (end.xpos - start.xpos);
  float c = start.ypos - (start.xpos * m);
  
  //float xpoints = abs(start-end);
  
  Vertex minX = findminX(v);
  
  
  for (float x = start_x + 1; x < end_x - 1; x++)
  {
    
    int count = 0;
    float y = (m * x) + c;
    Vertex p1 = new Vertex(x,y);
    Vertex p2 = new Vertex(minX.xpos, y);
    
    
    Line temp = new Line(p1,p2, polygonColor);
    
    for (int j = 0; j < all_lines.size(); j++)
    {
      if (temp.intersect(all_lines.get(j)) != null) {
        //print("intersect at " + all_lines.get(j));
        count++;
      }
    }
    
    if (count % 2 == 0)
    {
      println("FALSE");
      return false;
    }
    
    
    
  }
  //for starting x to ending x
  //for every y point
  //create fake Segment to minimum x
  //check for intersections with each segment
  //if even
  //false
  
  println("TRUE");
  return true;
}

public void triangulate(ArrayList<Vertex> v)
{
  
  int lines = 0;
  
  stroke(color(0,0,0));
  //line(100,100,200,200);
  myStack.push(v.get(0));
  myStack.push(v.get(1));
  myStack.print();
  println(myStack.size());
  
  for (int i = 2; i < v.size() - 1; i++)
  {
    //if(
    println("mainloop");
    if (v.get(i).chain != myStack.top().chain)
    {
      println("chain does not match");
      //pop everything
      //draw lines to everthing but bottom
      //push v[i-1] and v[i]
      
      //Segment lastPopped;
      
      while(myStack.size() > 1)
      {
        myStack.print();
        println(myStack.size());
        //println("checking bottom");
        Vertex theTop = myStack.top();      
        Vertex start = new Vertex(theTop.xpos,theTop.ypos);
        Vertex end = new Vertex(v.get(i).xpos, v.get(i).ypos);
        Line testLine = new Line(start,end, polygonColor, triangulationDelay++);
        println("test: " + testLine);
        triangulation_lines.add(testLine);
        lines++;
        myStack.pop();
        
      }
      myStack.pop();
      myStack.push(v.get(i - 1));
      myStack.push(v.get(i));
      myStack.print();
      
    }
    else
    {
      println("match");
      Vertex lastPopped = myStack.pop();
      //pop
      
      //while (vi and top is interior
      //pop and and add diagonal
      
      Vertex theTop = myStack.top();
      
      Vertex start = new Vertex(theTop.xpos,theTop.ypos);
      
      Vertex end = new Vertex(v.get(i).xpos, v.get(i).ypos);
      
      Line testLine = new Line(start,end, polygonColor, triangulationDelay++);
      
      println("test: " + testLine);
      
      while(isInterior(start, end, v))
      {
        println("draw");
        triangulation_lines.add(testLine);
        lines++;
        
        
        lastPopped = myStack.pop();
        
        if (myStack.top() == null)
          break;
        theTop = myStack.top();
        start = new Vertex(theTop.xpos,theTop.ypos);
        testLine = new Line(start,end, polygonColor, triangulationDelay++);
        
      }
      
      
      //push last popped vertex and v[i]
      myStack.push(lastPopped);
      myStack.push(v.get(i));
      
      print("stack: ");
      myStack.print();
    }
  }
  
  println("triangulation complete: " + lines);
  
}

//sorts points my increasing order based on y axis
void sortPoints(ArrayList<Vertex> v)
{
  for (int i = 1; i < v.size(); i++)
  {
    int j = i;
    Vertex temp = v.get(i);
    while((j>0) && (v.get(j - 1).ypos > temp.ypos))
    {
      v.set(j,v.get(j - 1));
      j--;
    }
    v.set(j,temp);
  }
}
