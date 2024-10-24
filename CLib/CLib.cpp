// CLib.cpp : Defines the exported functions for the DLL.
//

#include "pch.h"
#include "framework.h"
#include "CLib.h"
#include <thread>
#include <vector>


// Funkcja przetwarzaj¹ca obraz
void Dilate(const unsigned char* input, unsigned char* output, int width, int height, int startRow, int endRow) {
    // Operacja dylatacji (z u¿yciem prostego 3x3 filtru)
    for (int y = startRow; y < endRow; ++y) {
        for (int x = 0; x < width; ++x) {
            unsigned char maxValue = 0; // Zmienna do przechowywania maksymalnej wartoœci
            // Iteracja przez s¹siednie piksele
            for (int dy = -1; dy <= 1; ++dy) {
                for (int dx = -1; dx <= 1; ++dx) {
                    int newY = y + dy;
                    int newX = x + dx;
                    // Sprawdzanie granic obrazu
                    if (newY >= 0 && newY < height && newX >= 0 && newX < width) {
                        unsigned char neighborValue = input[newY * width + newX];
                        // Zaktualizuj maxValue, jeœli s¹siedni piksel jest wiêkszy
                        if (neighborValue > maxValue) {
                            maxValue = neighborValue;
                        }
                    }
                }
            }
            output[y * width + x] = maxValue; // Ustawienie maksymalnej wartoœci w dylatacji
        }
    }
}

CLIB_API void ProcessImage(unsigned char* image, unsigned char* result, int width, int height, int numThreads) {
    // Wygenerowanie wynikowego obrazu przez dylatacjê
    std::vector<std::thread> threads;
    int rowsPerThread = height / numThreads;

    for (int i = 0; i < numThreads; ++i) {
        int startRow = i * rowsPerThread;
        int endRow = (i == numThreads - 1) ? height : (i + 1) * rowsPerThread; // Ostatni w¹tek przetwarza resztê

        threads.emplace_back(Dilate, image, result, width, height, startRow, endRow);
    }

    for (auto& thread : threads) {
        thread.join();
    }

    // Odejmowanie oryginalnego obrazu od wyniku dylatacji
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int index = y * width + x;
            result[index] = (result[index] > image[index]) ? (result[index] - image[index]) : 0; // Odejmowanie i zapewnienie wartoœci nieujemnych
        }
    }
}
