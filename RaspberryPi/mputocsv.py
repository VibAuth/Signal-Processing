import smbus
import math
import pandas as pd
import csv
import time

# Power management registers
power_mgmt_1 = 0x6b
power_mgmt_2 = 0x6c

def read_byte(adr):
    return bus.read_byte_data(address, adr)

def read_word(adr):
    high = bus.read_byte_data(address, adr)
    low = bus.read_byte_data(address, adr+1)
    # print "address: ",address
    # print "high: ", high, " low: ",low
    val = (high << 8) + low
    return val

def read_word_2c(adr):
    val = read_word(adr)
    # print "val: ", val
    if (val >= 0x8000):
        return -((65535 - val) + 1)
    else:
        return val

def dist(a,b):
    return math.sqrt((a*a)+(b*b))

def get_y_rotation(x,y,z):
    radians = math.atan2(x, dist(y,z))
    return -math.degrees(radians)

def get_x_rotation(x,y,z):
    radians = math.atan2(y, dist(x,z))
    return math.degrees(radians)



bus = smbus.SMBus(1) 
address = 0x68       

xout_list = []
yout_list = []
zout_list = []
xout_scaled_list = []
yout_scaled_list = []
zout_scaled_list = []
count = 0
time_now = []
# Now wake the 6050 up as it starts in sleep mode

bus.write_byte_data(address, power_mgmt_1, 0)

start = time.time()
temp = start
try:
    while True:
        # print "gyro data"
        #  print "---------"
        now = time.time()
        # gyro_xout = read_word_2c(0x43)
        # gyro_yout = read_word_2c(0x45)
        # gyro_zout = read_word_2c(0x47)
        
        # gyro_xout_scaled = gyro_xout / 131
        # gyro_yout_scaled = gyro_yout / 131
        # gyro_zout_scaled = gyro_zout / 131

        #print()
        #print("accelerometer data")
        #print("------------------")

        accel_xout = read_word_2c(0x3b)
        accel_yout = read_word_2c(0x3d)
        accel_zout = read_word_2c(0x3f)
        
        accel_xout_scaled = accel_xout / 16384.0
        accel_yout_scaled = accel_yout / 16384.0
        accel_zout_scaled = accel_zout / 16384.0
       
        xout_list.append(accel_xout)
        yout_list.append(accel_yout)
        zout_list.append(accel_zout)
        xout_scaled_list.append(accel_xout_scaled)
        yout_scaled_list.append(accel_yout_scaled)
        zout_scaled_list.append(accel_zout_scaled)
        time_now.append((now-start)*1000)

        # print("accel_xout: ", accel_xout, " scaled: ", accel_xout_scaled)
        # print("accel_yout: ", accel_yout, " scaled: ", accel_yout_scaled)
        # print("accel_zout: ", accel_zout, " scaled: ", accel_zout_scaled)
        # print("x rotation: " , get_x_rotation(accel_xout_scaled, accel_yout_scaled, accel_zout_scaled))
        # print("y rotation: " , get_y_rotation(accel_xout_scaled, accel_yout_scaled, accel_zout_scaled)) 
        count+=1
        if count == 1000:
            print(now-temp)
            temp = now
            count=0
            # xout_list=[]
            # yout_list=[]
            # zout_list=[]
            # xout_scaled_list=[]
            # yout_scaled_list=[]
            # zout_scaled_list=[]


except KeyboardInterrupt:
    # print(len(time_now))
    # print(len(xout_list))
    # print(len(yout_list))
    # print(len(zout_list))
    data = {'t':time_now,'accel_xout':xout_list, 'accel_yout':yout_list, 'accel_zout':zout_list, 'xout_scaled':xout_scaled_list, 'yout_scaled':yout_scaled_list,'zout_scaled':zout_scaled_list}
    df = pd.DataFrame(data)
    df.to_csv('accel_data_time.csv',index=True,encoding='cp949')



