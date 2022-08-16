# Y-MonotoneDraw

Code by Adam Gerena (main logic and implementation) and Sebastion Hernandez (presentation and animation)

For this project, we decided to create a program that will triangulate any y-monotone polygon.  We implemented this algorithm in Processing, as it gave us the tools to easily visualize polygons, and the steps in the triangulation process.  

Our program allows the user to draw a polygon themselves to be triangulated.  The polygon then gets tested to ensure that it is y-monotone.  Because our triangulation method only works on y-monotone polygons, any polygon that is not y-monotone will display a message indicating that the polygon drawn did not pass the test.  


We developed a couple classes to help us for this project: Vertex, Line, and Stack.  Each point the user creates on the screen gets stored as a Vertex object in an array, which has the attributes you would expect from a vertex, such as X position and Y position.  We also gave vertex a chain identifier attribute to keep track of which vertices belong to which chains.  The list is then sorted in increasing order based on the Y axis.  With this list, we start the triangulation process, which makes use of our Stack class, as expected for this algorithm.  

The Line class is used to store all the line segments of the polygon, which is used later for testing if a line drawn is interior or not.


The program begins with an empty canvas.  As the user clicks their mouse, they can form the polygon.  We implemented a guiding line to follow the mouse as the user creates the polygon.  When the user brings the cursor close to the end of their polygon, a filled line will appear. 

Clicking into this filled line will complete the polygon.  The user can then hit a button on the canvas to initiate the triangulation process. Our program then displays the separate chains of the polygon by displaying each side in a different color.  Then as the lines are considered by the algorithm, they are drawn onto the canvas.



## Main application view:
![image](https://user-images.githubusercontent.com/50191607/184965017-74d73061-b6b6-4ffc-a57d-86151ac3b3ed.png)

## After triangluation:
![image](https://user-images.githubusercontent.com/50191607/184965228-30f63c45-f151-45a4-be89-7735a851a324.png)
