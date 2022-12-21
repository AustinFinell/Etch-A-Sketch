# Etch-A-Sketch
Etch-A-Sketch Programmed in MIPS Assembly

Program Description: 	Functional 512 x 512 etch-a-sketch using the bitmap display that allows color selection between RGB for drawing.
					Additional functions include resetting the board and changing the RGB value of the frame color by gradient
          
- Instructions for use in MARS:
 - Place EtchaSketch.asm and utils.asm in the same folder
 - Open EtchaSketch.asm in the MARS editor
 - Open the bitmap under Tools > Bitmap Display
  
 - Set Bitmap display to these settings:
   - Unit Width in Pixels - 8
   - Unit Height in Pixels - 8
   - Display Width in Pixels - 512
   - Display Height in Pixels - 5512
   - Base address for display - 0x10040000 (heap)
   - Click Connect to MIPS
   
  - Open the Input box under Tools > Keyboard and Display MMIO Simulator
   - Click Connect to MIPS
   
  - Click the Wrench and Screwdriver icon in MARS
  - Click the Green Play button
   
  - Have the Bitmap Display up, and enter the keys into the text box

### Keys: 
  - w - up
  - a - left
  - s - down
  - d - right
  - q - up/left
  - e - up/right
  - z - down/left
  - c - down/right
  - x - clear pointer pposition
  - r - change drawing color to red
  - g - change drawing color to green
  - b - change drawing color to blue
  - o - reset board
  ### Frame Colors
  - y - red value up
  - h - red value down
  - u - green value up
  - j - green value down
  - i - blue value up
  - k - blue value down
