//Stack class
//
//Creates stack to use for algorithm


public class Stack
{
  private ArrayList<Vertex> stack;
  
  public Stack()
  {
    stack = new ArrayList<Vertex>();
  }
  
  public void push(Vertex v)
  {
    stack.add(v);
  }
  
  public Vertex pop()
  {
    if(stack.size() == 0)
    {
      return null;
    }
    else{
      Vertex temp = stack.get(stack.size()-1);
      stack.remove(stack.size()-1);
      return temp;
    }
  }
  
  public void print()
  {
    for(int i = 0; i < stack.size(); i++)
    {
      println(stack.get(i));
    }
  }
  
  public Vertex top()
  {
    if(stack.size() == 0)
      return null;
    else
      return stack.get(stack.size()-1);
  }
  
  public Vertex bottom()
  {
    
    return stack.get(0);
  }
  
  public int size()
  {
    return stack.size();
  }
  
}
