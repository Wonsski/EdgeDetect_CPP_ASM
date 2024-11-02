#include "pch.h"
#include "framework.h"
#include "CLib.h"
#include <thread>
#include <vector>
#include <windows.h>
#include <iostream>

// Rêczna funkcja porównawcza dla max
inline unsigned char max_value(unsigned char a, unsigned char b) {
    return a > b ? a : b;
}

// Funkcja przetwarzaj¹ca fragment obrazu na odcienie szaroœci
void ToGrayscaleSegment(const unsigned char* input, unsigned char* output, int width, int startRow, int endRow) {
    for (int y = startRow; y < endRow; ++y) {
        for (int x = 0; x < width; ++x) {
            int index = (y * width + x) * 4; // Indeks w tablicy ARGB
            unsigned char gray = static_cast<unsigned char>(
                0.3 * input[index + 2] +  // R
                0.59 * input[index + 1] + // G
                0.11 * input[index]       // B
                );
            output[y * width + x] = gray; // Zapisz odcieñ szaroœci
        }
    }
}

// Funkcja dylatacji z optymalizacj¹
void Dilate(const unsigned char* input, unsigned char* output, int width, int height, int startRow, int endRow) {
    for (int y = startRow; y < endRow; ++y) {
        for (int x = 0; x < width; ++x) {
            unsigned char maxValue = 0;
            // PrzejdŸ przez s¹siaduj¹ce piksele
            for (int dy = -1; dy <= 1; ++dy) {
                for (int dx = -1; dx <= 1; ++dx) {
                    int newY = y + dy;
                    int newX = x + dx;
                    // Sprawdzenie granic
                    if (newY >= 0 && newY < height && newX >= 0 && newX < width) {
                        unsigned char neighborValue = input[newY * width + newX];
                        maxValue = max_value(maxValue, neighborValue); // U¿ycie naszej funkcji max_value
                    }
                }
            }
            output[y * width + x] = maxValue; // Ustaw maksymaln¹ wartoœæ w wyniku dylatacji
        }
    }
}

// Eksportowana funkcja dla C#
extern "C" __declspec(dllexport) void __stdcall ProcessImageCpp(unsigned char* data, int width, int height, int numThreads) {
    // Zainicjalizowanie buforów
    std::vector<unsigned char> grayscaleData(width * height); // Bufor dla obrazu grayscale
    std::vector<unsigned char> dilatedData(width * height);   // Bufor dla obrazu po dylatacji

    // Konwersja do odcieni szaroœci wielow¹tkowo
    std::vector<std::thread> threads;
    int rowsPerThread = height / numThreads;

    for (int i = 0; i < numThreads; ++i) {
        int startRow = i * rowsPerThread;
        int endRow = (i == numThreads - 1) ? height : (i + 1) * rowsPerThread;
        threads.emplace_back(ToGrayscaleSegment, data, grayscaleData.data(), width, startRow, endRow);
    }

    for (auto& thread : threads) {
        thread.join();
    }

    threads.clear();

    // Dylatacja wielow¹tkowo
    for (int i = 0; i < numThreads; ++i) {
        int startRow = i * rowsPerThread;
        int endRow = (i == numThreads - 1) ? height : (i + 1) * rowsPerThread;
        threads.emplace_back(Dilate, grayscaleData.data(), dilatedData.data(), width, height, startRow, endRow);
    }

    for (auto& thread : threads) {
        thread.join();
    }

    // Odejmowanie obrazu grayscale od wyniku dylatacji
    for (int y = 0; y < height; ++y) {
        for (int x = 0; x < width; ++x) {
            int index = y * width + x;
            unsigned char contourValue = dilatedData[index] > grayscaleData[index] ? dilatedData[index] - grayscaleData[index] : 0;

            data[index * 4] = contourValue;
            data[index * 4 + 1] = contourValue;
            data[index * 4 + 2] = contourValue;
            data[index * 4 + 3] = 255;
        }
    }
}
