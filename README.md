# FPGA IR

This is IR receiver with UART interface for Altera Cyclone IV FPGA. It works as a simple IR analyzer.

IR receiver like the following is required:
![image](https://user-images.githubusercontent.com/8286747/212570921-4c1ba69d-35cf-41f5-85b2-869bc610357d.png)

Output is in the pulse/space (+/-) format:
 ```
$ python3 read.py
+ 9000
- 4500
+ 570
- 570
+ 570
- 570
+ 570
......
```
