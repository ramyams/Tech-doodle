
clc; 
clear; %clears inputs 
%inputs
  img =imread('lena.png');
  imshow(img);
  title('Original Image');
  figure
  S = rgb2gray(img);
  C = S(:);
  d = dec2bin(C);
  data = logical(d - '0'); 
 
   key = [0 1 1 1 1 1 1 1 0 1];

%Function Parameters
    P4 = [2 4 3 1]; 
    P8 = [6 3 7 4 8 5 10 9];
   P10 = [3 5 2 7 4 10 1 9 8 6];
SHIFT1 = [2 3 4 5 1 7 8 9 10 6]; %Shift bits 1 space
SHIFT3 = [4 5 1 2 3 9 10 6 7 8]; %Shifts 3 spaces, used to circumvent 2 + 1 logic
   
    IP = [2 6 3 1 4 8 5 7]; %Initial Permutation
    PI = [4 1 3 5 7 2 8 6]; %Inverse IP ;-)
    EP = [4 1 2 3 2 3 4 1]; 
    FP = [4 1 3 5 7 2 8 6]; %Final Permutation
    
    S0 = [1 0 3 2; 3 2 1 0; 0 2 1 3; 3 1 3 2]; % s-boxes
    S1 = [0 1 2 3; 2 0 1 3; 3 0 1 0; 2 1 0 3];
    
%Key Generation

K1 = key(P10(SHIFT1(P8)));
K2 = key(P10(SHIFT3(P8)));

%Initial Permutation 1
Q=0;
A = 0;  
for i = 1:4096 
data1 = data(i,IP);
 L = data1(1:4);
 R = data1(5:8);
 R1 = xor(R(EP),K1);

%------ Function 1 with key 1
%function gets decimal location for substitution box then converts back to
%binary and places into matrix 
R2 = de2bi(S0((bi2de(R1([1 4]),2,'left-msb')+1),(bi2de(R1([2 3]),2,'left-msb')+1)),2,'left-msb');
R3 = de2bi(S1((bi2de(R1([5 8]),2,'left-msb')+1),(bi2de(R1([6 7]),2,'left-msb')+1)),2,'left-msb');
R3E = [R2,R3];
R3EN = xor(R3E(P4),L);

%Swap
 dataC = [R, R3EN]; %swap halves
 
 %------ Function 1 with key 2
 LK2 = dataC(1:4);
 RK2 = dataC(5:8);
 RKY2 = xor(RK2(EP),K2);
 
RS2 = de2bi(S0((bi2de(RKY2([1 4]),2,'left-msb')+1),(bi2de(RKY2([2 3]),2,'left-msb')+1)),2,'left-msb'); 
RS3 = de2bi(S1((bi2de(RKY2([5 8]),2,'left-msb')+1),(bi2de(RKY2([6 7]),2,'left-msb')+1)),2,'left-msb');
RS3E = [RS2,RS3];
RS3EN = xor(RS3E(P4),LK2); %xor's with left half
 
 %swap halves
 dataEN = [RS3EN, RK2];
 
 %Inverse Permutation
 dataENC = dataEN(PI);
 enc1 =num2str(dataENC);
 enc2 = bin2dec(enc1);

dataD = dataENC(IP);  

 %------------Decryption---------------
 
 %Function with Key 2
 LD = dataD(1:4);
 RD = dataD(5:8);
 RD1 = xor(RD(EP),K2);
%s-box
RD2 = de2bi(S0((bi2de(RD1([1 4]),2,'left-msb')+1),(bi2de(RD1([2 3]),2,'left-msb')+1)),2,'left-msb');
RD3 = de2bi(S1((bi2de(RD1([5 8]),2,'left-msb')+1),(bi2de(RD1([6 7]),2,'left-msb')+1)),2,'left-msb');

RD3E = [RD2,RD3];
RD3EC = xor(RD3E(P4),LD);

dataDE = [RD, RD3EC]; % combine and swap halves

 %Function with Key 1 
 LDE = dataDE(1:4);
 RDE = dataDE(5:8);
 RDE1 = xor(RDE(EP),K1);
 
RDE2 = de2bi(S0((bi2de(RDE1([1 4]),2,'left-msb')+1),(bi2de(RDE1([2 3]),2,'left-msb')+1)),2,'left-msb');
RDE3 = de2bi(S1((bi2de(RDE1([5 8]),2,'left-msb')+1),(bi2de(RDE1([6 7]),2,'left-msb')+1)),2,'left-msb');

RDEC3 = [RDE2,RDE3];
R3DEC = xor(RDEC3(P4),LDE);
 
 dataDEC = [R3DEC, RDE]; %combines and swaps halves
 
 dataDECR = dataDEC(PI);
 dec1 =num2str(dataDECR);
 dec2 = bin2dec(dec1);
 
 A = [A,enc2];
 Q= [Q dec2];
 
end
 t=A(2:length(A));
      w=reshape(t,64,64);
      g=mat2gray(w);
      imshow(g)
      title('Encrypted Image');
figure 

z=Q(2:length(Q));
      x=reshape(z,64,64);
      y=mat2gray(x);
      h=uint8(255*(y));
      rgbimg = cat(3,h,h,h);
      imshow(rgbimg)
title('Decrypted Image');