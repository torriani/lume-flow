"""Sinais originais de confirmação do LumeFlow, sem amostras externas."""
from pathlib import Path
import math,struct,wave
out=Path(__file__).resolve().parent.parent/'ui/sounds';out.mkdir(exist_ok=True)
for name,notes in [('start',(660,880)),('stop',(880,660))]:
 rate=44100;samples=[]
 for frequency in notes:
  n=int(rate*.075)
  for i in range(n):
   t=i/rate;envelope=math.sin(math.pi*i/(n-1))**2
   samples.append(int(32767*.16*envelope*(math.sin(2*math.pi*frequency*t)+.15*math.sin(4*math.pi*frequency*t))))
 with wave.open(str(out/(name+'.wav')),'wb') as f:
  f.setparams((1,2,rate,0,'NONE','not compressed'));f.writeframes(b''.join(struct.pack('<h',v) for v in samples))
# Alternativas curtas e discretas, sintetizadas localmente.
for theme,freq,length,volume in [('soft',440,.09,.09),('pop',280,.055,.13),('glass',1100,.12,.065)]:
 for kind,scale in [('start',1),('stop',.75)]:
  n=int(rate*length);samples=[]
  for i in range(n):
   t=i/rate;env=math.sin(math.pi*i/(n-1))**2*math.exp(-3*i/n)
   phase=2*math.pi*freq*scale*t
   value=math.sin(phase+(12*t if theme=='pop' else 0))
   if theme=='glass':value+=.25*math.sin(phase*2.76)
   samples.append(int(32767*volume*env*value))
  with wave.open(str(out/(theme+'-'+kind+'.wav')),'wb') as f:
   f.setparams((1,2,rate,0,'NONE','not compressed'));f.writeframes(b''.join(struct.pack('<h',v) for v in samples))
