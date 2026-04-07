# ES3B2 FPGA Game

## Mark Scheme Requirements Summary

- Multiple objects move and have respect for screen boundaries
- Multiple objects collide or have interactions with each other in different locations of the screen
- Info bar is shown, built using sprites and contain animations
- Makes use of at least button, switches and accelerometer coupled with other peripherals
- Makes use all the available memories for sprites, including animations
- Design is innovative, contains multiple features which are creative, for example own animations, easter eggs, design from scratch features, etc

## Brief

### Overview
The assignment involves design of an interactive game from scratch using the Nexys 4DDR FPGA development board. You will borrow the university board for using during the assignment and the day after your submission the board needs to be returned to room F209. You will lose 5 marks each day if you do not return your board on time.

To do this, you will need to design a VGA controller and additional logic to draw items on screen and manage game logic. Detailed instructions are provided in further lab sheets. The game must have an ‘info box’ that is displayed at all times. The Info bar colours you use must be unique to your group. It must be 100 pixels in height and span the width of the display. The Info bar should display the game name and the ID numbers of the group members. 

The assignment consists of practical design work, undertaken during lab sessions, with supporting work in your own time. Your work will be assessed in two stages, a practical demo of your design followed by a final report. The deadlines for both stages are shown on the cover page above. You will work in pairs for the practical part and write reports individually. Anyone not in a pair by the end of the lab will be paired up.

### Presentation/Demonstration of practical design
The practical part of the assignment will be assessed by the deadline shown on the cover page. You will have to submit the .bit file of your work and a maximum 10 minute video, describing how your game meets the requirements listed below. The video should capture the display, extra features used (leds, seven segment display, etc) and a voice-over describing the design of the game. Up to 50% of the marks will be allocated to this part of the assignment, based on the following marking scheme criteria:

- User control of a moving object on screen with respect for screen boundaries: up to 10%
- A map or multiple objects and interactions between them, e.g. collisions: up to 10%
- Info bar: up to 10%
- Extra features like using other board inputs/outputs: up to 5%
- Use of sprites from a memory block: up to 10%
- Creative design ideas: up to 5%

Both members of each pair will receive the same grade unless there is clear evidence that one individual has contributed more significantly to the work. This will be evaluated based on attendance and participation in lab sessions, and may result in grade adjustments. Same video submission is permitted within the same group, provided that both students are actively involved, either by speaking or visibly appearing on screen.

### Written Report Assessment
The written report must be submitted by the deadlines shown on the cover page. In this report, you are to describe the design you built. A good report would have the following template structure:
- Introduction to VGA
- Game idea and logical procedures:
- Top view of the project with a figure showing how each module is connected to others.
  - Modules design: each module is explained in details separately
  - Extra features
- Testbench and tests
- Conclusion:
  - Reflection

Start from describing the VGA signalling protocol, how you built circuits to generate the correct sync pulses, pixel values and how you designed the info bar. Then, explain how you determined current pixel coordinates, how you drew objects on screen, how they move, collide and interact with each other. You should also discuss how you tested your design. Your report should be written in a formal manner and include excerpts of code where this would assist discussion. Screen captures may also be useful. Include all your Verilog code in an appendix, clearly stating what each source file is for. Do not paste screenshots of code – you must use a syntax highlighting. The report should conclude with a reflective section about what you liked and disliked about the project, what you learned or couldn't understand, and suggestions for improvement in the future. The 50% marks for the report will be distributed based on the following marking scheme criteria:

- Introduction and Background discussion on displays/VGA: up to 5%
- Design description: up to 25%
- Testing description: up to 5%
- Code quality: up to 5%
- Presentation, accordance to report template and references: up to 5%
- Reflection section: up to 5%
