clear all
close all

%%%%% FÁJL BEOLVASÁS
bemenet_mappa = ""; %fájl elérési út
kep_fajlok = dir(fullfile(bemenet_mappa, "*.png"));

eredmeny_mappa = ""; %fájl elérési út

elteresek = []; %eltérés távolsága
iranyok=[]; %eltérés iránya
koordinatak=[]; %háromszög csúcsainak koordinátái

for i = 1:length(kep_fajlok) %1:2
    kep_eleresi_ut = fullfile(bemenet_mappa, kep_fajlok(i).name);

    kep = imread(kep_eleresi_ut);

r = kep(:, :, 1);
g = kep(:, :, 2);
b = kep(:, :, 3);

R = imadjust(r); %intenzitás szabályzása
G = imadjust(g);
B = imadjust(b);

szabalyozott_RGB = cat(3, R, G, B); %csatornák összefűzése

neg_kep=255-szabalyozott_RGB;

[magassag, szelesseg, rgb]=size(neg_kep);

figure()
subplot(131);
imshow(kep);
title("Eredeti");
subplot(132);
imshow(szabalyozott_RGB);
title("Intenzitás szabályozás");
subplot(133);
imshow(neg_kep);
title("Negatív");

if i==1
    sgtitle("1.kamera");
else
    sgtitle("2.kamera");
end

R_=neg_kep(:, :, 1);
G_=neg_kep(:, :, 2);
B_=neg_kep(:, :, 3);

%maszk fehér pixelek felkeresésére:
threshold=200;
feher = (R_ > threshold) & (G_ > threshold) & (B_ > threshold); %RGB_feher=(255,255,255)

[y, x] = find(feher); %y=sor, x=oszlop

%elektróda csúcsának megkeresése:
[max_y, I] = max(y); 
    x_csucs = x(I);
    y_csucs = y(I);

figure;
imshow(neg_kep);
title("Fehér pixelek");
hold on;
plot(x, y, "ro", "MarkerSize", 4, "LineWidth", 2);
hold off;
hold on;
plot(x_csucs, y_csucs, "co", "MarkerSize", 6, "LineWidth", 2);
hold off;

%A_csucs=[x_csucs,y_csucs]; (elektróda csúcsa)
%B_csucs=bal/jobb felső sarok
%C_csucs=bal/jobb szél

%háromszög koordinátáinak kiszámítása
%B,C csúcs meghatározása:

if ((abs(1-x_csucs)) > (abs(szelesseg-x_csucs))) %balra==jobb szélről balra hajlik-->jobb szélhez közelebb van
   
   x_C=szelesseg; %jobb szél
   y_C=y_csucs;

   x_B=szelesseg; %jobb felső sarok
   y_B=1;

   irany="balra";

else  %jobbra==bal szélről jobbra hajlik-->bal szélhez közelebb van
   
   x_C=1; %bal szél
   y_C=y_csucs;

   x_B=1; %bal felső sarok
   y_B=1;

   irany="jobbra";

end

iranyok=[iranyok,irany];
disp(irany);

koordinata=[x_csucs, y_csucs, x_B, y_B, x_C, y_C];
koordinatak=[koordinatak, koordinata];

figure;
imshow(neg_kep);
title("Maszkolt");
hold on;
plot(x, y, "ro", "MarkerSize", 4, "LineWidth", 2);
hold off;
hold on;
plot(x_csucs, y_csucs, "co", "MarkerSize", 6, "LineWidth", 2);
hold off;
hold on;
plot(x_B, y_B, "go", "MarkerSize", 6, "LineWidth", 2);
hold off;
hold on;
plot(x_C, y_C, "yo", "MarkerSize", 6, "LineWidth", 2);
hold off;

%%%ÁBRA MENTÉSE
if i==1
    nev="1.png";
else
    nev="2.png";
end
teljes_eleresi_ut= fullfile(eredmeny_mappa, nev);
saveas(gcf, teljes_eleresi_ut); 

%távolság,szögszámítás
%oldalak hossza
AB=sqrt((koordinata(3)-koordinata(1))^2+(koordinata(4)-koordinata(2))^2); %c oldal
BC=sqrt((koordinata(5)-koordinata(3))^2+(koordinata(6)-koordinata(4))^2); %a oldal
CA=sqrt((koordinata(1)-koordinata(5))^2+(koordinata(2)-koordinata(6))^2); %b oldal

%koszinusz tétel
beta=acos((CA^2-BC^2-AB^2)/(-2*BC*AB));
beta_fok=rad2deg(beta);
disp(beta_fok);

%eltérés kiszámítása:
%(hasonló háromszögek-->sin(beta)=(CA/BA)=(elteres/beultetes_melyseg))

beultetes_melyseg=40000; %merev hordozó: 4 cm
%beultetes_melyseg=2500; %PEG: 0,25 cm

elteres=sin(beta)*beultetes_melyseg;

elteresek=[elteresek, elteres];

end
%%
%%%%3D ÁBRÁZOLÁS

egyenes_top = [0, 0, 0];
egyenes_bottom = [0, 0, -beultetes_melyseg];

x = [egyenes_top(1), egyenes_bottom(1)];
y = [egyenes_top(2), egyenes_bottom(2)];
z = [egyenes_top(3), egyenes_bottom(3)];

 if iranyok(1)=="jobbra" && iranyok(2)=="jobbra"
    elektroda_tip = [elteresek(2), -elteresek(1), -beultetes_melyseg]; %%jobbra jobbra
 elseif iranyok(1)=="balra" && iranyok(2)=="balra"
    elektroda_tip = [-elteresek(2), elteresek(1), -beultetes_melyseg]; %%balra balra
 elseif iranyok(1)=="balra" && iranyok(2)=="jobbra"
    elektroda_tip = [-elteresek(2), -elteresek(1), -beultetes_melyseg]; %%balra jobbra
 else 
    elektroda_tip = [elteresek(2), elteresek(1), -beultetes_melyseg]; %%jobbra balra
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

%%%%ELTÉRÉS KISZÁMÍTÁSA
final_eleres_tav_microm = sqrt(elteresek(1)^2+elteresek(2)^2);
disp(final_eleres_tav_microm);

%%%%ERDMÉNY MENTÉSE
E=[elteresek(1), elteresek(2), final_eleres_tav_microm];
fajlnev = "eredmeny.xlsx";

teljes_eleres = fullfile(eredmeny_mappa, fajlnev);

writematrix(E, teljes_eleres);


%VÉGEREDMÉNY MEGJELENÍTÉSE A 3D ÁBRÁN
%merev hordozó:
text(elektroda_tip(1)-5000, elektroda_tip(2)-5000, elektroda_tip(3), sprintf("%.2f $\\mu$m", final_eleres_tav_microm), "Interpreter", "latex", "FontSize", 8, "Color", "red");

%PEG:
%text(elektroda_tip(1)-500, elektroda_tip(2)-500, elektroda_tip(3), sprintf("%.2f $\\mu$m", final_eleres_tav_microm), "Interpreter", "latex", "FontSize", 8, "Color", "red");

%%%%3D ÁBRA MENTÉSE
neve="3D.png";
telj_eleres= fullfile(eredmeny_mappa, neve);
saveas(gcf, telj_eleres);