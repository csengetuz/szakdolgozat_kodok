clear all
close all

%%%%% FÁJL BEOLVASÁS
bemenet_mappa = ""; %fájl elérési út
kep_fajlok = dir(fullfile(bemenet_mappa, "*.png"));

eredmeny_mappa = ""; %fájl elérési út

adatok = []; %% eltérés távolsága
iranyok=[]; %% eltérés iránya
irany=" ";

for i = 1:length(kep_fajlok) %1:2
    kep_eleresi_ut = fullfile(bemenet_mappa, kep_fajlok(i).name);

    kep = imread(kep_eleresi_ut); %%3D mátrix
    
    kep1 = rgb2gray(kep); %%2D mátrix-->szélesség, magasság

[magassag, szelesseg]=size(kep1);

%%%%%% JELÖLŐK KERESÉSE

%%piros
R_1 = 237;  
G_1 = 28;    
B_1 = 36;   

[Y1, X1] = find(kep(:,:,1) == R_1 & kep(:,:,2) == G_1 & kep(:,:,3) == B_1);

%%kék
R_2 = 0;  
G_2 = 162;    
B_2 = 232;   

[Y2, X2] = find(kep(:,:,1) == R_2 & kep(:,:,2) == G_2 & kep(:,:,3) == B_2);

%%zöld
R_3 = 34;  
G_3 = 177;    
B_3 = 76;   

[Y3, X3] = find(kep(:,:,1) == R_3 & kep(:,:,2) == G_3 & kep(:,:,3) == B_3);

%%sárga marker helyének meghatározása
if X3>szelesseg/2   %%jobb szélről balra hajlik
   X4=szelesseg;
   Y4=Y2;

   irany="balra";
else                %%bal szélről jobbra hajlik
   X4=1;
   Y4=Y2;
   irany="jobbra";
end
iranyok=[iranyok, irany];


%%%%% KÉP KIRAJZOLÁSA JELÖLŐKKEL EGYÜTT
figure()
imshow(kep);
hold on
plot(X1, Y1, "ro", "MarkerSize", 10, "LineWidth", 1);
hold off
hold on
plot(X2,Y2, "bo", "MarkerSize", 10, "LineWidth", 1);
hold off
hold on
plot(X3,Y3, "go", "MarkerSize", 10, "LineWidth", 1);
hold off
hold on
plot(X4,Y4, "yo", "MarkerSize", 10, "LineWidth", 1);
hold off

if i==1
    title("1. kamera");
else
    title("2. kamera");
end

%%%% ÁBRA MENTÉSE
if i==1
    nev="1.png";
else
    nev="2.png";
end

teljes_eleresi_ut= fullfile(eredmeny_mappa, nev);
saveas(gcf, teljes_eleresi_ut); 

%%%%%%%% ELTÉRÉS KISZÁMÍTÁSÁHOZ SZÜKSÉGES ADATOK MEGHATÁROZÁSA

%%piros-kék távolság=érzékelők távolsága==100 mikrométer
kalibr_tav_pix= sqrt((X2-X1)^2+(Y2-Y1)^2);
pixel_meret= 100/kalibr_tav_pix;

%%sárga-kék távolság
elteres_tav_pix= sqrt((X4-X2)^2+(Y4-Y2)^2);
elteres_tav_microm= elteres_tav_pix*pixel_meret;

%%kék-zöld távolság
atfogo_hossz_pix=sqrt((X3-X2)^2+(Y3-Y2)^2);
atfogo_hossz_microm=atfogo_hossz_pix*pixel_meret;

beultetes_melyseg=40000; %%merev hordozó: 4 cm
%beultetes_melyseg=2500; %%PEG: 0,25 cm

total_elteres_tav_microm=(elteres_tav_microm*beultetes_melyseg)/atfogo_hossz_microm;

disp(total_elteres_tav_microm);
adatok=[adatok, total_elteres_tav_microm];

end
%%
%%%%%% 3D ÁBRÁZOLÁS
egyenes_top = [0, 0, 0];
egyenes_bottom = [0, 0, -beultetes_melyseg];

x = [egyenes_top(1), egyenes_bottom(1)];
y = [egyenes_top(2), egyenes_bottom(2)];
z = [egyenes_top(3), egyenes_bottom(3)];

egyenes_top = [0, 0, 0];

 if iranyok(1)=="jobbra" && iranyok(2)=="jobbra"
    elektroda_tip = [adatok(2), -adatok(1), -beultetes_melyseg]; %%jobbra jobbra
 elseif iranyok(1)=="balra" && iranyok(2)=="balra"
    elektroda_tip = [-adatok(2), adatok(1), -beultetes_melyseg]; %%balra balra
 elseif iranyok(1)=="balra" && iranyok(2)=="jobbra"
    elektroda_tip = [-adatok(2), -adatok(1), -beultetes_melyseg]; %%balra jobbra
 else 
    elektroda_tip = [adatok(2), adatok(1), -beultetes_melyseg]; %%jobbra balra
 end

x2 = [egyenes_top(1), elektroda_tip(1)];
y2 = [egyenes_top(2), elektroda_tip(2)];
z2 = [egyenes_top(3), elektroda_tip(3)];

figure()
plot3(x,y,z, "Color", "green");
xlabel({"2. kamera","[\mum]"});
ylabel({"1. kamera","[\mum]"});
zlabel("Beültetési mélység [\mum]");
title("Elektróda térbeli helyzete")


xlim([-beultetes_melyseg, beultetes_melyseg]);
ylim([-beultetes_melyseg, beultetes_melyseg]);
zlim([-beultetes_melyseg, 0]);


hold on
plot3(x2,y2,z2, "Color", "blue")


x3=[elektroda_tip(1), egyenes_bottom(1)];
y3=[elektroda_tip(2), egyenes_bottom(2)];
z3=[elektroda_tip(3), egyenes_bottom(3)];

hold on
plot3(x3,y3,z3, "Color", "red")
grid on

legend("elvárt pozíció", "elektróda", "eltérés");

%%%%% ELTÉRÉS KISZÁMÍTÁSA
final_eleres_tav_microm = sqrt(adatok(1)^2+adatok(2)^2);
disp(final_eleres_tav_microm);

%%%%% ERDMÉNY MENTÉSE
E=[adatok(1), adatok(2), final_eleres_tav_microm];
fajlnev = "eredmeny.xlsx";

teljes_eleres = fullfile(eredmeny_mappa, fajlnev);

writematrix(E, teljes_eleres);


%%%%% VÉGEREDMÉNY MEGJELENÍTÉSE A 3D ÁBRÁN
text(elektroda_tip(1)-5000, elektroda_tip(2)-5000, elektroda_tip(3), sprintf("%.2f $\\mu$m", final_eleres_tav_microm), "Interpreter", "latex", "FontSize", 8, "Color", "red");

%%%%% 3D ÁBRA MENTÉSE
neve="3D.png";
telj_eleres= fullfile(eredmeny_mappa, neve);
saveas(gcf, telj_eleres);