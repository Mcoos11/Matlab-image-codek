clc; clear; close all;

maska = [  1 1 1 1 2  12  18  18
              1 1 1 2 12  18  18  18
              1 1 2 2 12  18  18  26
              1 2 2 12 18  18  26  68
              2 2 12 18 18  26 68 68
              12 18 18 26 68  68 68 99
              18 18 26 68 68 68 99 99
              18 18 26 68 68 99 99 99];

[m, n] = size(maska);

maskowanie = @(block_struct) block_struct.data ./ maska;

obraz = im2double(imread('obrazy/obraz.jpg'));
[wys, szer, kol] = size(obraz);

docWys = wys / 2 - rem((wys / 2), 8) ;
docSzer = szer / 2 - rem((szer / 2), 8) ;

figure,imshow(obraz);
title('Oryginalny');

obraz = imresize(obraz,[docWys, docSzer]);
obrazYCC = rgb2ycbcr(obraz);  

Y  = obrazYCC(:, :, 1);
Cb = obrazYCC(:, :, 2);
Cr = obrazYCC(:, :, 3);

%transformata kosinusowa i maska
Ydct  = blkproc(Y, [m, n], 'dct2');
Cbdct = blkproc(double(Cb), [m, n], 'dct2');
Crdct = blkproc(double(Cr), [m, n], 'dct2');

Ydct  = blockproc(Ydct, [m, n], maskowanie);
Cbdct = blockproc(Cbdct, [m, n], maskowanie);
Crdct = blockproc(Crdct, [m, n], maskowanie);


%zmiana macierzy na ciąg znaków
Ydct =  round(Ydct(:), 1);
Cbdct = round(Cbdct(:), 1);
Crdct = round(Crdct(:), 1);

%kodowanie Hufmman
%słownik
[liczbSymbY, symbY]  = hist(Ydct, unique(Ydct));
[liczbSymbCb, symbCb] = hist(Cbdct, unique(Cbdct));
[liczbSymbCr, symbCr] = hist(Crdct, unique(Crdct));

prawdY = liczbSymbY ./ (docSzer * docWys);
prawdCb = liczbSymbCb ./ (docSzer * docWys);
prawdCr = liczbSymbCr ./ (docSzer * docWys);

sloY =  huffmandict(symbY, prawdY);
sloCb =  huffmandict(symbCb, prawdCb);
sloCr =  huffmandict(symbCr, prawdCr);

%kodowanie
wyjY = huffmanenco(Ydct, sloY);
wyjCb = huffmanenco(Cbdct, sloCb);
wyjCr = huffmanenco(Crdct, sloCr);

%zapis
save('gotowy.jmc', 'sloY', 'sloCb', 'sloCr', 'wyjY', 'wyjCb', 'wyjCr', 'docWys', 'docSzer','-mat');
