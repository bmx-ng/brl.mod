/*
  Copyright (c) 2024-2025 Bruce A Henderson
  
  This software is provided 'as-is', without any express or implied
  warranty. In no event will the authors be held liable for any damages
  arising from the use of this software.
  
  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:
  
  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.
*/ 
#include "rect_pack.h"

#include "brl.mod/blitz.mod/blitz.h"

extern "C" {

    void brl_rectpacker_TRectPacker__GetSize(BBObject * packer, int index, int * width, int * height, int * id);
    BBArray * brl_rectpacker_TRectPacker__NewSheetArray(int size);
    void brl_rectpacker_TRectPacker__SetSheet(BBArray * sheets, int index, BBObject * sheet);
    BBObject * brl_rectpacker_TPackedSheet__Create(int width, int height, int size);
    void brl_rectpacker_TPackedSheet__SetRect(BBObject * sheet, int index, int id, int x, int y, int width, int height, int rotated);

    BBArray * bmx_rectpacker_pack(BBObject * packer, int packingMethod, int maxSheets, int powerOfTwo, int square, int allowRotate, int alignWidth, int borderPadding, int sheetPadding, int overAllocate, int minWidth, int minHeight, int maxWidth, int maxHeight, int count);
}

BBArray * bmx_rectpacker_pack(BBObject * packer, int packingMethod, int maxSheets, int powerOfTwo, int square, int allowRotate, int alignWidth, int borderPadding, int sheetPadding, int overAllocate, int minWidth, int minHeight, int maxWidth, int maxHeight, int count) {
    rect_pack::Settings settings;
    settings.method = static_cast<rect_pack::Method>(packingMethod);
    settings.max_sheets = maxSheets;
    settings.power_of_two = static_cast<bool>(powerOfTwo);
    settings.square = static_cast<bool>(square);
    settings.allow_rotate = static_cast<bool>(allowRotate);
    settings.align_width = static_cast<bool>(alignWidth);
    settings.border_padding = sheetPadding;
    settings.over_allocate = overAllocate;
    settings.min_width = minWidth;
    settings.min_height = minHeight;
    settings.max_width = maxWidth;
    settings.max_height = maxHeight;

    std::vector<rect_pack::Size> sizes;

    for (int i = 0; i < count; i++) {
        rect_pack::Size s;
        brl_rectpacker_TRectPacker__GetSize(packer, i, &s.width, &s.height, &s.id);
        if ( borderPadding > 0 ) {
            s.width += borderPadding * 2;
            s.height += borderPadding * 2;
        }
        sizes.push_back(s);
    }

    std::vector<rect_pack::Sheet> sheets = rect_pack::pack(settings, sizes);

    BBArray * result = brl_rectpacker_TRectPacker__NewSheetArray(sheets.size());

    for (int i = 0; i < sheets.size(); i++) {
        BBObject * sheet = brl_rectpacker_TPackedSheet__Create(sheets[i].width, sheets[i].height, sheets[i].rects.size());
        for (int j = 0; j < sheets[i].rects.size(); j++) {
            rect_pack::Rect r = sheets[i].rects[j];
            if ( borderPadding > 0 ) {
                r.x += borderPadding;
                r.y += borderPadding;
                r.width -= borderPadding;
                r.height -= borderPadding;
            }
            brl_rectpacker_TPackedSheet__SetRect(sheet, j, r.id, r.x, r.y, r.width, r.height, r.rotated);
        }
        brl_rectpacker_TRectPacker__SetSheet(result, i, sheet);
    }

    return result;
}
