//Line class
//
//Creates line object that allows for keeping track of points and checking for intersections


public class Line
{
  private Vertex start;
  private Vertex end;
  private float incrementX, incrementY;
  private float xnow, ynow;
  private int frame = 0;
  private float animDuration = 0.5;
  private int drawDelay = 0;
  
  private String linecolor;
  
  public Line(Vertex s, Vertex e, String linecolor)
  {
    start = s;
    end = e;
    incrementX = (e.xpos - s.xpos) / (frameRate * animDuration);
    incrementY = (e.ypos - s.ypos) / (frameRate * animDuration);
    xnow = s.xpos;
    ynow = s.ypos;
    this.linecolor = linecolor;
  }
  
  public Line(Vertex s, Vertex e, String linecolor, int drawDelay)
  {
    start = s;
    end = e;
    incrementX = (e.xpos - s.xpos) / (frameRate * animDuration);
    incrementY = (e.ypos - s.ypos) / (frameRate * animDuration);
    xnow = s.xpos;
    ynow = s.ypos;
    this.linecolor = linecolor;
    this.drawDelay = round(drawDelay * frameRate);
  }
  
  
  public void draw()
  {
    switch(linecolor) {
      case "black":
        stroke(0);
        break;
      case "red":
        stroke(color(255,0,0));
        break;
      case "blue":
        stroke(color(0,0,255));
        break;
      default:
      stroke(0);
    }
    if (drawDelay ==  0) {
      if (++frame < (frameRate * animDuration)) {
        xnow += incrementX;
        ynow += incrementY;
        if ((start.xpos < end.xpos && xnow > end.xpos) || (start.xpos>= end.xpos && xnow<end.xpos)) {
          xnow = end.xpos;
        }
        if ((start.ypos < end.ypos && ynow > end.ypos) || (start.ypos>= end.ypos && ynow<end.ypos)) {
          ynow = end.ypos;
        }
        line(start.xpos, start.ypos, xnow, ynow);
      } else {
        line(start.xpos, start.ypos, end.xpos, end.ypos);
      }
    } else {
      drawDelay--;
    }
  }
  
  public String toString()
    {
    return start + ":" + end;
  }
  
  //Checks if two lines are intersecting
  public Vertex intersect(Line l2)
    {
    //caclulate a through e for formula
    float a = end.xpos - start.xpos;
    float b = end.ypos - start.ypos;
    float c = l2.end.xpos - l2.start.xpos;
    float d = l2.end.ypos - l2.start.ypos;
    float e = l2.start.xpos - start.xpos;
    float f = l2.start.ypos - start.ypos;
    
    //calculate t
    float t1 = -(c * f - d * e) / (a * d - b * c);
    float t2 = -(a * f - b * e) / (a * d - b * c);
    
    
    //check for intersecting segment
    if ((a * d - b * c) == 0)
      {
      if ((a * f - b * e) == 0)
        {
        float tp = (l2.start.xpos - start.xpos) / a;
        float tq = (l2.end.xpos - start.xpos) / a;
        
        float l = Math.max(Math.min(tp,tq),0);
        float r = Math.min(Math.max(tp,tq),1);
        
        if (l == r)
          {
          float x = start.xpos + (l * a);
          float y = start.ypos + (l * b);
          
          Vertex v = new Vertex(x,y);
          return v;
        }
        else if (l < r)
          {
          float p1x = start.xpos + (l * a);
          float p1y = start.ypos + (l * b);
          
          float p2x = l2.start.xpos + (r * a);
          float p2y = l2.start.ypos + (r * b);
          
          //find center of intersecting segment
          float x = (p1x + p2x) / 2;
          float y = (p1y + p2y) / 2;
          
          //return point
          Vertex v = new Vertex(x,y);
          return v;
        }
      }
    }
    
    //check if t1 and t2 are in bounds
    if ((t1 >= 0 && t1 <= 1) && (t2 >= 0 && t2 <= 1))
      {
      //calculate interstion point
      float x1x = start.xpos + (t1 * a);
      float x1y = start.ypos + (t1 * b);
      
      //float x2x = s2.p.x + (t2*c);
      //float x2y = s2.p.y + (t2*d);
      
      //return point
      Vertex v = new Vertex(x1x, x1y);
      return v;
    }
    else
      {
      return null;
    }
  }
}
