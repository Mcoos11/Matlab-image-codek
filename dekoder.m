clear; clc; close all;

m=8;
n=8;

%odczyt
wej = load('gotowy.jmc','-mat');

wys = wej.docWys * 2;
szer = wej.docSzer *2;

%dekodowanie
dekY = huffmandeco(wej.wyjY, wej.sloY);
dekCb = huffmandeco(wej.wyjCb, wej.sloCb);
dekCr = huffmandeco(wej.wyjCr, wej.sloCr);

dekY = reshape(dekY, [wej.docWys wej.docSzer]);
dekCb = reshape(dekCb, [wej.docWys wej.docSzer]);
dekCr = reshape(dekCr, [wej.docWys wej.docSzer]);

%odwrotna transformata kosinusowa
Y = blkproc(dekY, [m, n], 'idct2');
Cb = blkproc(dekCb, [m, n], 'idct2');
Cr = blkproc(dekCr, [m, n], 'idct2');

Obraz_ycbr = cat(3, Y, Cb, Cr);
Obraz_wyj = ycbcr2rgb(Obraz_ycbr);


% %interpolacja
R = double(zeros(wej.docWys, wej.docSzer, 3));
R(:, :, 1) =  Obraz_wyj(:, : , 1);
G=double(zeros(wej.docWys, wej.docSzer, 3));
G(:, :, 2) =  Obraz_wyj(:, : , 2);
B=double(zeros(wej.docWys, wej.docSzer, 3));
B(:, :, 3) =  Obraz_wyj(:, : , 3);

Rnowy = double(zeros(wys, szer, 3));
Gnowy = double(zeros(wys, szer, 3));
Bnowy = double(zeros(wys, szer, 3));

Obraz_up = double(zeros(wys, szer, 3));

for i = 1:wej.docSzer
    k = 1;
    for j = 1:wys
            if((mod(j, 2) == 0 && mod(i, 2) == 0) || (mod(j, 2) ~= 0 && mod(i, 2) ~= 0))
                    Rnowy(j, i, 1) = 0;
                    Gnowy(j, i, 2) = 0;
                    Bnowy(j, i, 3) = 0;
            else
                    Rnowy(j, i, 1) = R(k, i, 1);
                    Gnowy(j, i, 2) = G(k, i, 2);
                    Bnowy(j, i, 3) = B(k, i, 3);

                    k = k + 1;
            end
    end
end

for i = 1:wej.docSzer
    for j = 1:wys
        if(i == 1 || j == 1 || j == wys || i == wej.docSzer)
            if(((j == 1 && mod(i, 2) ~= 0) || (j == wys && mod(i, 2) == 0)) && i ~= wej.docSzer && i ~= 1)
                Rnowy(j, i, 1) = (Rnowy(j, i + 1, 1) + Rnowy(j, i - 1, 1)) / 2;
                Gnowy(j, i, 2) = (Gnowy(j, i + 1, 2) + Gnowy(j, i - 1, 2)) / 2;
                Bnowy(j, i, 3) = (Bnowy(j, i + 1, 3) + Bnowy(j, i - 1, 3)) / 2;
            elseif(((i == 1 && mod(j, 2) ~= 0) || i == wej.docSzer && mod(j, 2) == 0) && j ~= wys && j ~= 1)
                Rnowy(j, i, 1) = (Rnowy(j + 1, i, 1) + Rnowy(j - 1, i, 1)) / 2;
                Gnowy(j, i, 2) = (Gnowy(j + 1, i, 2) + Gnowy(j - 1, i, 2)) / 2;
                Bnowy(j, i, 3) = (Bnowy(j + 1, i, 3) + Bnowy(j - 1, i, 3)) / 2;
            elseif(i == 1 && j == 1)
                Rnowy(j, i, 1) = (Rnowy(j + 1, i, 1) + Rnowy(j, i + 1, 1)) / 2;
                Gnowy(j, i, 2) = (Gnowy(j + 1, i, 2) + Gnowy(j, i + 1, 2)) / 2;
                Bnowy(j, i, 3) = (Bnowy(j + 1, i, 3) + Bnowy(j, i + 1, 3)) / 2;
            elseif(i == wej.docSzer && j == wys)
                Rnowy(j, i, 1) = (Rnowy(j - 1, i, 1) + Rnowy(j, i - 1, 1)) / 2;
                Gnowy(j, i, 2) = (Gnowy(j - 1, i, 2) + Gnowy(j, i - 1, 2)) / 2;
                Bnowy(j, i, 3) = (Bnowy(j - 1, i, 3) + Bnowy(j, i - 1, 3)) / 2;
            end
        else
            if((mod(j, 2) == 0 && mod(i, 2) == 0) || (mod(j, 2) ~= 0 && mod(i, 2) ~= 0))
                    Rnowy(j, i, 1) = (Rnowy(j - 1, i, 1) + Rnowy(j + 1, i, 1) + Rnowy(j, i - 1, 1) + Rnowy(j, i + 1, 1)) / 4;
                    Gnowy(j, i, 2) = (Gnowy(j - 1, i, 2) + Gnowy(j + 1, i, 2) + Gnowy(j, i - 1, 2) + Gnowy(j, i + 1, 2)) / 4;
                    Bnowy(j, i, 3) = (Bnowy(j - 1, i, 3) + Bnowy(j + 1, i, 3) + Bnowy(j, i - 1, 3) + Bnowy(j, i + 1, 3)) / 4;                
            end
        end
    end
end

Rtmp = double(zeros(wys, szer, 3));
Rtmp(:, :, 1) = Rnowy(:, :, 1);
Gtmp = double(zeros(wys, szer, 3));
Gtmp(:, :, 2) = Gnowy(:, :, 2);
Btmp = double(zeros(wys, szer, 3));
Btmp(:, :, 3) = Bnowy(:, :, 3);

% Obraz_up(:, :, 1) = Rtmp(:, :, 1);
% Obraz_up(:, :, 2) = Gtmp(:, :, 2);
% Obraz_up(:, :, 3) = Btmp(:, :, 3);
% figure, imshow(Obraz_up);


for j = 1:wys
    k = 1;
    for i = 1:szer
            
            if((mod(j, 2) == 0 && mod(i, 2) == 0) || (mod(j, 2) ~= 0 && mod(i, 2) ~= 0))
                    Rnowy(j, i, 1) = 0;
                    Gnowy(j, i, 2) = 0;
                    Bnowy(j, i, 3) = 0;
            else
                    Rnowy(j, i, 1) = Rtmp(j, k, 1);
                    Gnowy(j, i, 2) = Gtmp(j, k, 2);
                    Bnowy(j, i, 3) = Btmp(j, k, 3);

                    k = k + 1;
            end
    end
end

for i = 1:szer
    for j = 1:wys
        if(i == 1 || j == 1 || j == wys || i == szer)
            if(((j == 1 && mod(i, 2) ~= 0) || (j == wys && mod(i, 2) == 0)) && i ~= szer && i ~= 1)
                Rnowy(j, i, 1) = (Rnowy(j, i + 1, 1) + Rnowy(j, i - 1, 1)) / 2;
                Gnowy(j, i, 2) = (Gnowy(j, i + 1, 2) + Gnowy(j, i - 1, 2)) / 2;
                Bnowy(j, i, 3) = (Bnowy(j, i + 1, 3) + Bnowy(j, i - 1, 3)) / 2;
            elseif(((i == 1 && mod(j, 2) ~= 0) || i == szer && mod(j, 2) == 0) && j ~= wys && j ~= 1)
                Rnowy(j, i, 1) = (Rnowy(j + 1, i, 1) + Rnowy(j - 1, i, 1)) / 2;
                Gnowy(j, i, 2) = (Gnowy(j + 1, i, 2) + Gnowy(j - 1, i, 2)) / 2;
                Bnowy(j, i, 3) = (Bnowy(j + 1, i, 3) + Bnowy(j - 1, i, 3)) / 2;
            elseif(i == 1 && j == 1)
                Rnowy(j, i, 1) = (Rnowy(j + 1, i, 1) + Rnowy(j, i + 1, 1)) / 2;
                Gnowy(j, i, 2) = (Gnowy(j + 1, i, 2) + Gnowy(j, i + 1, 2)) / 2;
                Bnowy(j, i, 3) = (Bnowy(j + 1, i, 3) + Bnowy(j, i + 1, 3)) / 2;
            elseif(i == szer && j == wys)
                Rnowy(j, i, 1) = (Rnowy(j - 1, i, 1) + Rnowy(j, i - 1, 1)) / 2;
                Gnowy(j, i, 2) = (Gnowy(j - 1, i, 2) + Gnowy(j, i - 1, 2)) / 2;
                Bnowy(j, i, 3) = (Bnowy(j - 1, i, 3) + Bnowy(j, i - 1, 3)) / 2;
            end
        else
            if((mod(j, 2) == 0 && mod(i, 2) == 0) || (mod(j, 2) ~= 0 && mod(i, 2) ~= 0))
                    Rnowy(j, i, 1) = (Rnowy(j - 1, i, 1) + Rnowy(j + 1, i, 1) + Rnowy(j, i - 1, 1) + Rnowy(j, i + 1, 1)) / 4;
                    Gnowy(j, i, 2) = (Gnowy(j - 1, i, 2) + Gnowy(j + 1, i, 2) + Gnowy(j, i - 1, 2) + Gnowy(j, i + 1, 2)) / 4;
                    Bnowy(j, i, 3) = (Bnowy(j - 1, i, 3) + Bnowy(j + 1, i, 3) + Bnowy(j, i - 1, 3) + Bnowy(j, i + 1, 3)) / 4;                
            end
        end
    end
end

Obraz_up(:, :, 1) = Rnowy(:, :, 1);
Obraz_up(:, :, 2) = Gnowy(:, :, 2);
Obraz_up(:, :, 3) = Bnowy(:, :, 3);

% Obraz_up = imresize(Obraz_wyj,[wys, szer]);

% %filtr medianowy
% for i = 2 : wys - 1       
%     for j = 2 : szer - 1
%         a = 1;
%         b = 1;
%         for x = i - 1 : i + 1
%             for y = j - 1 : j + 1
%                 filtr(a, b) = Obraz_up(x, y);
%                 b = b + 1;
%             end
%             a = a + 1;
%             b = 1;
%         end
%         
%         medianfilter = reshape(filtr', 9, 1); 
%         queue = sort(medianfilter); % w szablonie 3 * 3 piąta wartość to mediana 
%         median = queue(5); % przypisz medianę każdego punktu do wyjściowego obrazu           
%         Obraz_up(i,j) = median;       
%     end
% end

%filtr spolotowy
ksztalt = @(x) (abs(x) < 1/2);

filtrY = ksztalt(linspace(-1, 1, 5)' * linspace(-1, 1, 5));

filtrX = filtrY/sum(filtrY(:));
A = sum(filtrX(:));
Obraz_up = imfilter(Obraz_up, filtrX,'replicate');

%Wyswietlenie wynikow
figure, imshow(Obraz_wyj);
title('Otrzymany');
imwrite(Obraz_wyj,"Otrzymany.jpg");
figure, imshow(Obraz_up);
title('Przetworzony');
imwrite(Obraz_up,"Przetworzony.jpg");