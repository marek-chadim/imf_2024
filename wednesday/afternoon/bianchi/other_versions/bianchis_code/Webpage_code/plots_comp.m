figure
subplot(2,3,1)
plot(B,cDE,B,cSP,'--')
subplot(2,3,2)
plot(B,bpDE,B,bpSP)
title('bonds')
subplot(2,3,3)
plot(B,priceDE)
subplot(2,3,4)
plot(B,V); hold on; plot(B,VSP,'--')
subplot(2,3,5)
plot(B,Wf);  title('welfare')