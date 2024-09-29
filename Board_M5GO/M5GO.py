from m5stack import *
from m5ui import *
from uiflow import *
import wifiCfg
from m5mqtt import M5mqtt
import time
import unit


setScreenColor(0x222222)
pir_0 = unit.get(unit.PIR, unit.PORTB)


state = None
start_hour = None
start_minute = None
end_hour = None
end_minute = None
Notification = None
count = None
now_minute = None
khamoi = None
Sensor = None
now_hour = None
time = None
do = None



state0 = M5Title(title="state", x=10, fgcolor=0xFFFFFF, bgcolor=0x649dd3)
minute = M5TextBox(172, 107, "minute", lcd.FONT_DejaVu40, 0xFFFFFF, rotate=0)
hour = M5TextBox(86, 107, "hour", lcd.FONT_DejaVu40, 0xFFFFFF, rotate=0)
sensor = M5TextBox(284, 17, "sensor", lcd.FONT_Comic, 0xFFFFFF, rotate=0)
s_hour = M5TextBox(19, 200, "s_h", lcd.FONT_Comic, 0xFFFFFF, rotate=0)
s_min = M5TextBox(63, 200, "s_m", lcd.FONT_Comic, 0xFFFFFF, rotate=0)
e_hour = M5TextBox(224, 200, "e_h", lcd.FONT_Comic, 0xFFFFFF, rotate=0)
e_min = M5TextBox(265, 200, "e_m", lcd.FONT_Comic, 0xFFFFFF, rotate=0)

from numbers import Number


# Describe this function...
def check():
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  if state == '1':
    if (pir_0.state) == 1:
      rgb.setColorFrom(6, 10, 0xff0000)
      Sensor = 1
    else:
      Sensor = 0
      count = 0
      rgb.setColorFrom(6, 10, 0x000000)
  else:
    count = 0
  sensor.setText(str(count))
  hour.setText(str(now_hour))
  minute.setText(str(now_minute))
  s_hour.setText(str(start_hour))
  s_min.setText(str(start_minute))
  e_hour.setText(str(end_hour))
  e_min.setText(str(end_minute))


def fun_Ken_M5_State_(topic_data):
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  state = topic_data
  pass

def fun_Ken_M5_Start_hour_(topic_data):
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  start_hour = int(topic_data)
  pass

def fun_Ken_M5_Start_minute_(topic_data):
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  start_minute = int(topic_data)
  pass

def fun_Ken_M5_End_hour_(topic_data):
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  end_hour = int(topic_data)
  pass

def fun_Ken_M5_End_minute_(topic_data):
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  end_minute = int(topic_data)
  pass

def fun_Ken_M5_Notification_State_(topic_data):
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  Notification = int(topic_data)
  pass

def multiBtnCb_AB():
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  # timer1
  timerSch.stop('timer1')
  while not (btnC.isPressed()):
    if btnA.isPressed():
      now_hour = (now_hour if isinstance(now_hour, Number) else 0) + 1
    elif btnB.isPressed():
      now_minute = (now_minute if isinstance(now_minute, Number) else 0) + 1
    if now_minute >= 59:
      now_minute = 0
      now_hour = (now_hour if isinstance(now_hour, Number) else 0) + 1
    if now_hour >= 24:
      now_hour = 0
    hour.setText(str(now_hour))
    minute.setText(str(now_minute))
    wait_ms(100)
  # timer1
  timerSch.run('timer1', 990, 0x00)
  pass
btn.multiBtnCb(btnA,btnB,multiBtnCb_AB)

@timerSch.event('timer3')
def ttimer3():
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  if khamoi == 1:
    count = 0
    sensor.setText(str(count))
    if time < 10 and Notification == 0:
      rgb.setColorFrom(1, 5, 0x000000)
      Sensor = 1
      khamoi = 0
      time = 0
    elif time < 10 and Notification == 1:
      rgb.setColorFrom(1, 5, 0x3333ff)
      speaker.setVolume(0.1)
      speaker.sing(220, 4)
    elif time > 10:
      rgb.setColorFrom(1, 5, 0x000000)
      m5mqtt.publish(str('Ken/M5/Notification/State'), str('0'), 2)
      Sensor = 1
      khamoi = 0
      time = 0
    time = (time if isinstance(time, Number) else 0) + 1
  pass

@timerSch.event('timer2')
def ttimer2():
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  if Sensor == 1:
    count = (count if isinstance(count, Number) else 0) + 1
    if count == 4:
      m5mqtt.publish(str('Ken/M5/Notification/State'), str('1'), 2)
      m5mqtt.publish(str('Ken/M5/Notification/hour'), str(now_hour), 2)
      m5mqtt.publish(str('Ken/M5/Notification/minute'), str(now_minute), 2)
      sensor.setText(str(count))
      count = 0
      Sensor = 0
      time = 0
      khamoi = 1
  pass

@timerSch.event('timer1')
def ttimer1():
  global state, start_hour, start_minute, end_hour, end_minute, Notification, count, now_minute, khamoi, Sensor, now_hour, time, do
  if now_minute >= 59:
    now_minute = -1
    now_hour = (now_hour if isinstance(now_hour, Number) else 0) + 1
    if now_hour >= 24:
      now_hour = 0
  now_minute = (now_minute if isinstance(now_minute, Number) else 0) + 1
  pass


wifiCfg.doConnect('LAPTOP-5NTQAN9K 2013', '5V723m2(')
m5mqtt = M5mqtt('', 'broker.hivemq.com', 1883, '', '', 60)
m5mqtt.subscribe(str('Ken/M5/State'), fun_Ken_M5_State_)
m5mqtt.subscribe(str('Ken/M5/Start/hour'), fun_Ken_M5_Start_hour_)
m5mqtt.subscribe(str('Ken/M5/Start/minute'), fun_Ken_M5_Start_minute_)
m5mqtt.subscribe(str('Ken/M5/End/hour'), fun_Ken_M5_End_hour_)
m5mqtt.subscribe(str('Ken/M5/End/minute'), fun_Ken_M5_End_minute_)
m5mqtt.subscribe(str('Ken/M5/Notification/State'), fun_Ken_M5_Notification_State_)
m5mqtt.start()
state = 0
now_hour = 22
now_minute = 30
start_hour = 23
start_minute = 30
end_hour = 5
end_minute = 0
do = 1
state0.setTitle(str(state))
hour.setText(str(now_hour))
minute.setText(str(now_minute))
s_hour.setText(str(start_hour))
s_min.setText(str(start_minute))
e_hour.setText(str(end_hour))
e_min.setText(str(end_minute))
# timer1
timerSch.run('timer1', 990, 0x00)
# timer2
timerSch.run('timer2', 990, 0x00)
# timer3
timerSch.run('timer3', 990, 0x00)
while True:
  if start_hour > end_hour and (now_hour > start_hour or now_hour < end_hour) or start_hour < end_hour and now_hour > start_hour and now_hour < end_hour or now_hour == start_hour and now_minute >= start_minute or now_hour == end_hour and now_minute <= end_minute:
    if do == 1:
      m5mqtt.publish(str('Ken/M5/State'), str('1'), 2)
      do = 0
  else:
    if do == 0:
      m5mqtt.publish(str('Ken/M5/State'), str('0'), 2)
      do = 1
  check()
  state0.setTitle(str(state))
  wait_ms(2)
