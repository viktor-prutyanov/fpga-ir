import serial

PORT = '/dev/ttyUSB0'
BAUDRATE = 5000000

s = serial.Serial(PORT, BAUDRATE)

while True:
    l = s.readline().decode('ascii')[:-1]
    sign, l = l[0], l[1:]
    dur = int(l, 16)
    print(sign, dur)

